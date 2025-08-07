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

# Ensure Unity Build files are in dist (if they exist in public)
RUN if [ -d "public/Build" ] && [ ! -d "dist/Build" ]; then \
        cp -r public/Build dist/Build; \
    fi && \
    if [ -d "public/Bundle" ] && [ ! -d "dist/Bundle" ]; then \
        cp -r public/Bundle dist/Bundle; \
    fi

# Production stage with Nginx
FROM nginx:alpine

# Install curl and brotli for decompression
RUN apk add --no-cache curl brotli

# Copy built application
COPY --from=build /app/dist /usr/share/nginx/html

# CRITICAL: Decompress all .br files
RUN echo "=== Decompressing Brotli files ===" && \
    find /usr/share/nginx/html -name "*.br" -type f | while read file; do \
        echo "Processing: $file"; \
        # Get the filename without .br extension \
        output="${file%.br}"; \
        # Decompress the file \
        brotli -d -f "$file" -o "$output"; \
        # Keep the .br file as backup \
        echo "Decompressed to: $output"; \
    done && \
    echo "=== Decompression complete ===" && \
    # List all Build files to verify \
    echo "=== Unity Build files ===" && \
    find /usr/share/nginx/html -path "*/Build/*" -type f -exec ls -lh {} \;

# Create nginx configuration for serving decompressed files
RUN echo 'server { \
    listen 3000; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    access_log /var/log/nginx/access.log; \
    error_log /var/log/nginx/error.log; \
    \
    # Serve both compressed and uncompressed versions \
    location /Build/ { \
        add_header Access-Control-Allow-Origin "*" always; \
        add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always; \
        add_header Access-Control-Allow-Headers "Range, Content-Type" always; \
        add_header Cache-Control "public, max-age=31536000, immutable" always; \
        \
        # Try uncompressed first, then .br version \
        try_files $uri $uri.br =404; \
        \
        # Set correct MIME types for Unity files \
        location ~ \.js$ { \
            add_header Content-Type "application/javascript" always; \
        } \
        location ~ \.wasm$ { \
            add_header Content-Type "application/wasm" always; \
        } \
        location ~ \.data$ { \
            add_header Content-Type "application/octet-stream" always; \
        } \
    } \
    \
    # Same for Bundle/Build if that path exists \
    location /Bundle/Build/ { \
        add_header Access-Control-Allow-Origin "*" always; \
        add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always; \
        add_header Access-Control-Allow-Headers "Range, Content-Type" always; \
        add_header Cache-Control "public, max-age=31536000, immutable" always; \
        \
        try_files $uri $uri.br =404; \
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
    } \
    \
    # Handle client-side routing for Vue SPA \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    # Cache static assets \
    location ~* \.(css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # Security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    add_header Referrer-Policy "strict-origin-when-cross-origin" always; \
    \
    # Enable gzip for text files \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json; \
}' > /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
