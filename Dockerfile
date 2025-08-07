# Multi-stage build for Vue.js + Vite application with Unity WebGL
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml* ./

# Install pnpm globally and install dependencies
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile

# Copy source code INCLUDING Unity Build files
COPY . .

# Copy docker environment file if exists
RUN if [ -f .env.docker ]; then cp .env.docker .env.production; fi

# Build the application for production
RUN pnpm run build

# Production stage with Nginx (sin módulos de brotli problemáticos)
FROM nginx:alpine

# Install curl for health checks only
RUN apk add --no-cache curl

# Copy built application
COPY --from=build /app/dist /usr/share/nginx/html

# Copy Unity Build files if they exist in public folder
COPY --from=build /app/public/Build /usr/share/nginx/html/Build 2>/dev/null || true

# Create nginx configuration WITHOUT brotli modules
RUN echo 'server { \
    listen 3000; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    access_log /var/log/nginx/access.log; \
    error_log /var/log/nginx/error.log; \
    \
    location /Build/ { \
        add_header Access-Control-Allow-Origin "*" always; \
        add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always; \
        add_header Access-Control-Allow-Headers "Range, Content-Encoding, Content-Type" always; \
        \
        location ~ \.br$ { \
            add_header Content-Encoding br always; \
            add_header Vary "Accept-Encoding" always; \
        } \
        \
        location ~ \.js$ { \
            add_header Content-Type "application/javascript" always; \
        } \
        location ~ \.wasm$ { \
            add_header Content-Type "application/wasm" always; \
        } \
        location ~ \.data$ { \
            add_header Content-Type "application/octet-stream" always; \
        } \
        \
        try_files $uri $uri.br =404; \
    } \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    add_header Referrer-Policy "strict-origin-when-cross-origin" always; \
    \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json application/wasm; \
}' > /etc/nginx/conf.d/default.conf

# Remove any existing default.conf
RUN rm -f /etc/nginx/conf.d/default.conf.orig

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
