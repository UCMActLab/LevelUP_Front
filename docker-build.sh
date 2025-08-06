#!/bin/bash

# Build script for LevelUP Frontend Docker image
set -e

echo "🚀 Building LevelUP Frontend Docker image..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
IMAGE_NAME="levelup-frontend"
TAG="latest"
ENVIRONMENT="production"
PUSH=false
REGISTRY=""

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -n, --name NAME       Image name (default: levelup-frontend)"
    echo "  -t, --tag TAG         Image tag (default: latest)"
    echo "  -e, --env ENV         Environment (development|production, default: production)"
    echo "  -p, --push            Push image to registry after build"
    echo "  -r, --registry URL    Registry URL for push"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Build production image"
    echo "  $0 -e development                    # Build development image"
    echo "  $0 -t v1.0.0 -p -r docker.io/user   # Build, tag as v1.0.0 and push"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -r|--registry)
            REGISTRY="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate environment
if [[ "$ENVIRONMENT" != "development" && "$ENVIRONMENT" != "production" ]]; then
    echo -e "${RED}❌ Error: Environment must be 'development' or 'production'${NC}"
    exit 1
fi

# Set dockerfile based on environment
if [[ "$ENVIRONMENT" == "development" ]]; then
    DOCKERFILE="Dockerfile.dev"
    TARGET="development"
else
    DOCKERFILE="Dockerfile"
    TARGET=""
fi

# Full image name
if [[ -n "$REGISTRY" ]]; then
    FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}:${TAG}"
else
    FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"
fi

echo -e "${BLUE}📋 Build Configuration:${NC}"
echo -e "  Image: ${GREEN}${FULL_IMAGE_NAME}${NC}"
echo -e "  Environment: ${YELLOW}${ENVIRONMENT}${NC}"
echo -e "  Dockerfile: ${YELLOW}${DOCKERFILE}${NC}"
echo ""

# Build the image
echo -e "${BLUE}🔨 Building Docker image...${NC}"

if [[ -n "$TARGET" ]]; then
    docker build -f $DOCKERFILE --target $TARGET -t $FULL_IMAGE_NAME .
else
    docker build -f $DOCKERFILE -t $FULL_IMAGE_NAME .
fi

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Build completed successfully!${NC}"
    
    # Show image info
    echo -e "${BLUE}📊 Image Information:${NC}"
    docker images $FULL_IMAGE_NAME --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Push if requested
if [[ "$PUSH" == true ]]; then
    if [[ -z "$REGISTRY" ]]; then
        echo -e "${RED}❌ Error: Registry URL required for push operation${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📤 Pushing image to registry...${NC}"
    docker push $FULL_IMAGE_NAME
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ Push completed successfully!${NC}"
    else
        echo -e "${RED}❌ Push failed!${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}🎉 All operations completed successfully!${NC}"
echo -e "${BLUE}💡 To run the container:${NC}"

if [[ "$ENVIRONMENT" == "development" ]]; then
    echo -e "  docker run -p 5173:5173 -v \$(pwd):/app -v /app/node_modules $FULL_IMAGE_NAME"
else
    echo -e "  docker run -p 3000:3000 $FULL_IMAGE_NAME"
fi

echo ""
echo -e "${BLUE}💡 To integrate with your stack:${NC}"
echo -e "  Add this to your main docker-compose.yml:"
echo -e "  levelup-front:"
echo -e "    image: $FULL_IMAGE_NAME"
echo -e "    ports:"
echo -e "      - \"3000:3000\""
echo -e "    environment:"
echo -e "      - BACKEND_URL=http://levelup:8080"