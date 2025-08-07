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

# Install brotli for decompression
RUN apk add --no-cache curl brotli

# Copy built application
COPY --from=build /app/dist /usr/share/nginx/html

# CRITICAL: Remove .br files and keep only decompressed versions
RUN echo "=== Processing Unity files ===" && \
    # First, decompress all .br files \
    find /usr/share/nginx/html -name "*.br" -type f | while read file; do \
        echo "Decompressing: $file"; \
        output="${file%.br}"; \
        brotli -d -f "$file" -o "$output" 2>/dev/null || echo "Already decompressed or error"; \
    done && \
    # Then REMOVE all .br files to force Unity to use uncompressed \
    echo "=== Removing .br files ===" && \
    find /usr/share/nginx/html -name "*.br" -type f -delete && \
    # Create symlink from /Build to /Bundle/Build if needed \
    if [ -d "/usr/share/nginx/html/Bundle/Build" ] && [ ! -e "/usr/share/nginx/html/Build" ]; then \
        ln -s /usr/share/nginx/html/Bundle/Build /usr/share/nginx/html/Build; \
        echo "Created symlink: /Build -> /Bundle/Build"; \
    fi && \
    # List final structure \
    echo "=== Final Unity files ===" && \
    ls -lh /usr/share/nginx/html/Bundle/Build/ 2>/dev/null || echo "No Bundle/Build" && \
    ls -lh /usr/share/nginx/html/Build/ 2>/dev/null || echo "No Build"

# Update Unity loader to remove .br extension references
RUN find /usr/share/nginx/html -name "*.loader.js" -type f | while read loader; do \
        echo "Patching loader: $loader"; \
        # Remove .br extension from file references \
        sed -i 's/\.br"/""/g' "$loader"; \
        sed -i "s/\.br'/'/g" "$loader"; \
        sed -i 's/\.br,/,/g' "$loader"; \
        sed -i 's/\.br}/}/g' "$loader"; \
    done

# Simple nginx configuration
RUN cat > /etc/nginx/conf.d/default.conf << 'NGINX_CONFIG'
server {
    listen 3000;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # MIME types for Unity
    types {
        application/wasm wasm;
        application/javascript js;
        application/octet-stream data;
    }

    # Unity Build files location (both paths)
    location /Build/ {
        add_header Access-Control-Allow-Origin "*" always;
        add_header Cache-Control "public, max-age=31536000, immutable" always;

        # Specific MIME types
        location ~ \.wasm$ {
            add_header Content-Type "application/wasm" always;
        }
        location ~ \.js$ {
            add_header Content-Type "application/javascript" always;
        }
        location ~ \.data$ {
            add_header Content-Type "application/octet-stream" always;
        }
    }

    location /Bundle/Build/ {
        add_header Access-Control-Allow-Origin "*" always;
        add_header Cache-Control "public, max-age=31536000, immutable" always;

        location ~ \.wasm$ {
            add_header Content-Type "application/wasm" always;
        }
        location ~ \.js$ {
            add_header Content-Type "application/javascript" always;
        }
        location ~ \.data$ {
            add_header Content-Type "application/octet-stream" always;
        }
    }

    # Template data
    location /Bundle/TemplateData/ {
        add_header Cache-Control "public, max-age=31536000, immutable" always;
    }

    # Vue SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static assets
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Enable gzip for text files
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
NGINX_CONFIG

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
