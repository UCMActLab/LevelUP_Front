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

# Production stage - Simple nginx
FROM nginx:alpine

# Copy built application
COPY --from=build /app/dist /usr/share/nginx/html

# Simple nginx configuration that serves everything as-is
RUN echo 'server { \
    listen 3000; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Serve everything without modifications \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 3000
EXPOSE 3000

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
