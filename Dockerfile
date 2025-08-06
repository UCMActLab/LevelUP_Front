# Multi-stage build for Vue.js + Vite application
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install pnpm globally and install dependencies
RUN npm install -g pnpm && \
    pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Copy docker environment file
COPY .env.docker .env.production

# Build the application for production with docker config
RUN pnpm run build -- --mode production

# Production stage with Nginx
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built application
COPY --from=build /app/dist /usr/share/nginx/html

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create modules directory and configure nginx for brotli static files
RUN mkdir -p /etc/nginx/conf.d

# Create nginx configuration for SPA and port 3000
RUN echo 'server {\
    listen 3000;\
    server_name localhost;\
    root /usr/share/nginx/html;\
    index index.html;\
    \
    # Handle client-side routing for SPA\
    location / {\
        try_files $uri $uri/ /index.html;\
    }\
    \
    # Unity Build files - Serve as-is, let Unity handle everything\
    location ~* /Build/ {\
        add_header Access-Control-Allow-Origin "*" always;\
        add_header Access-Control-Allow-Methods "GET, HEAD, OPTIONS" always;\
        add_header Access-Control-Allow-Headers "Range" always;\
        try_files $uri =404;\
    }\
    \
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
    # CORS headers (adjust as needed)\
    add_header Access-Control-Allow-Origin "*" always;\
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;\
    add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization" always;\
    \
    # Gzip compression for non-precompressed files\
    gzip on;\
    gzip_vary on;\
    gzip_min_length 1024;\
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;\
}' > /etc/nginx/conf.d/default.conf

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf.orig 2>/dev/null || true

# Expose port 3000 to match docker-compose
EXPOSE 3000

# Health check on port 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Use custom entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
