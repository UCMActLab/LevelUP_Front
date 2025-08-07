# Multi-stage build for Vue.js + Vite application with Unity WebGL
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install dependencies
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile

# Copy ALL source files
COPY . .

# Copy docker environment file if exists
RUN if [ -f .env.docker ]; then cp .env.docker .env.production; fi

# Build the application
RUN pnpm run build

# Production stage
FROM nginx:alpine

# Copy built application
COPY --from=build /app/dist /usr/share/nginx/html

# Create Build directory as copy of Bundle/Build if needed
RUN if [ -d "/usr/share/nginx/html/Bundle/Build" ] && [ ! -d "/usr/share/nginx/html/Build" ]; then \
        cp -r /usr/share/nginx/html/Bundle/Build /usr/share/nginx/html/Build; \
        echo "Copied Bundle/Build to Build"; \
    fi

# Nginx configuration with proper Brotli headers
RUN echo 'server { \
    listen 3000; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Specific handling for .br files in Build directory \
    location ~ ^/Build/(.+)\.br$ { \
        # Force correct headers for Brotli files \
        add_header Content-Encoding br always; \
        add_header Vary Accept-Encoding always; \
        \
        # Set correct MIME type based on original file extension \
        if ($request_uri ~ \.js\.br$) { \
            add_header Content-Type application/javascript always; \
        } \
        if ($request_uri ~ \.wasm\.br$) { \
            add_header Content-Type application/wasm always; \
        } \
        if ($request_uri ~ \.data\.br$) { \
            add_header Content-Type application/octet-stream always; \
        } \
        \
        # CORS headers \
        add_header Access-Control-Allow-Origin * always; \
        add_header Access-Control-Allow-Methods "GET, OPTIONS" always; \
        \
        # Cache headers \
        add_header Cache-Control "public, max-age=31536000, immutable" always; \
        \
        # Prevent Cloudflare from modifying response \
        add_header CDN-Cache-Control "no-transform" always; \
        add_header Cache-Tag "unity-build" always; \
    } \
    \
    # Same for Bundle/Build \
    location ~ ^/Bundle/Build/(.+)\.br$ { \
        add_header Content-Encoding br always; \
        add_header Vary Accept-Encoding always; \
        \
        if ($request_uri ~ \.js\.br$) { \
            add_header Content-Type application/javascript always; \
        } \
        if ($request_uri ~ \.wasm\.br$) { \
            add_header Content-Type application/wasm always; \
        } \
        if ($request_uri ~ \.data\.br$) { \
            add_header Content-Type application/octet-stream always; \
        } \
        \
        add_header Access-Control-Allow-Origin * always; \
        add_header Access-Control-Allow-Methods "GET, OPTIONS" always; \
        add_header Cache-Control "public, max-age=31536000, immutable" always; \
        add_header CDN-Cache-Control "no-transform" always; \
    } \
    \
    # Regular files in Build \
    location /Build/ { \
        add_header Access-Control-Allow-Origin * always; \
        add_header Cache-Control "public, max-age=31536000, immutable" always; \
    } \
    \
    location /Bundle/ { \
        add_header Access-Control-Allow-Origin * always; \
        add_header Cache-Control "public, max-age=31536000, immutable" always; \
    } \
    \
    # Vue app \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
