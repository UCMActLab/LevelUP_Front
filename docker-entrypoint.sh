#!/bin/sh

# Docker entrypoint script for runtime environment configuration
set -e

# Default values
API_URL=${API_URL:-"http://levelup:8080"}

echo "🔧 Configuring runtime environment..."
echo "📡 API_URL: $API_URL"

# Replace API URL in built JavaScript files
echo "🔄 Updating API configuration in built files..."

# Find and replace the API URL in the built files
find /usr/share/nginx/html -name "*.js" -type f -exec sed -i "s|http://levelup:8080|$API_URL|g" {} \;

# Create runtime config file that can be loaded by the app
cat > /usr/share/nginx/html/config.js << EOF
window.APP_CONFIG = {
  API_BASE_URL: '$API_URL',
  APP_ENV: 'production'
};
EOF

echo "✅ Configuration updated successfully!"

# Start nginx
exec nginx -g 'daemon off;'