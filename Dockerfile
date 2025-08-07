# Multi-stage build for Vue.js + Vite application with Unity WebGL
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install pnpm globally and install dependencies
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile

# Copy source code INCLUDING Unity Build files
COPY . .

# Copy docker environment file
COPY .env.docker .env.production

# Build the application for production with docker config
RUN pnpm run build -- --mode production

# Production stage with Nginx
FROM nginx:alpine

# Install curl for health checks and brotli module
RUN apk add --no-cache curl nginx-mod-http-brotli

# Copy built application INCLUDING all Unity files
COPY --from=build /app/dist /usr/share/nginx/html

# IMPORTANT: If Unity Build files are in public folder, copy them explicitly
# Uncomment and adjust path if your Unity files are in public/Build
# COPY --from=build /app/public/Build /usr/share/nginx/html/Build

# Copy entrypoint script if you have one
# COPY docker-entrypoint.sh /docker-entrypoint.sh
# RUN chmod +x /docker-entrypoint.sh

# Create nginx configuration for SPA and Unity WebGL
RUN echo 'load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;\
load_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;\
\
events {\
    worker_connections 1024;\
}\
\
http {\
    include /etc/nginx/mime.types;\
    default_type application/octet-stream;\
    \
    # Brotli configuration\
    brotli on;\
    brotli_static on;\
    brotli_types text/plain text/css text/xml text/javascript application/javascript application/json application/xml+rss application/wasm;\
    \
    server {\
        listen 3000;\
        server_name localhost;\
        root /usr/share/nginx/html;\
        index index.html;\
        \
        # Logging for debugging\
        access_log /var/log/nginx/access.log;\
        error_log /var/log/nginx/error.log debug;\
        \
        # MIME types for Unity WebGL\
        location ~ \.br$ {\
            add_header Content-Encoding br;\
            add_header Access-Control-Allow-Origin "*";\
            \
            # Detect and set correct MIME type for .br files\
            location ~ \.js\.br$ {\
                default_type "application/javascript";\
            }\
            location ~ \.wasm\.br$ {\
                default_type "application/wasm";\
            }\
            location ~ \.data\.br$ {\
                default_type "application/octet-stream";\
            }\
            location ~ \.framework\.js\.br$ {\
                default_type "application/javascript";\
            }\
        }\
        \
        # Unity Build files - specific handling\
        location /Build/ {\
            # Enable CORS\
            add_header Access-Control-Allow-Origin "*" always;\
            add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always;\
            add_header Access-Control-Allow-Headers "Range, Content-Encoding, Content-Type" always;\
            \
            # Serve pre-compressed .br files if they exist\
            gzip off;\
            \
            # Allow directory listing for debugging (remove in production)\
            autoindex on;\
            \
            # Set correct MIME types\
            location ~ \.js$ {\
                add_header Content-Type "application/javascript";\
            }\
            location ~ \.wasm$ {\
                add_header Content-Type "application/wasm";\
            }\
            location ~ \.data$ {\
                add_header Content-Type "application/octet-stream";\
            }\
            \
            try_files $uri $uri.br =404;\
        }\
        \
        # Handle client-side routing for SPA\
        location / {\
            try_files $uri $uri/ /index.html;\
        }\
        \
        # Cache static assets\
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {\
            expires 1y;\
            add_header Cache-Control "public, immutable";\
        }\
        \
        # Security headers\
        add_header X-Frame-Options "SAMEORIGIN" always;\
        add_header X-Content-Type-Options "nosniff" always;\
        add_header X-XSS-Protection "1; mode=block" always;\
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;\
        \
        # Gzip compression for non-precompressed files\
        gzip on;\
        gzip_vary on;\
        gzip_min_length 1024;\
        gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json application/wasm;\
    }\
}' > /etc/nginx/nginx.conf

# Expose port 3000
EXPOSE 3000

# Health check on port 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Use default nginx command or custom entrypoint if needed
# ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
