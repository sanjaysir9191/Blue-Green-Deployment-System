
# ==============================================
# FILE: scripts/deploy.sh
# ==============================================
# !/bin/bash
set -e

ENVIRONMENT=$1
IMAGE_TAG=${2:-latest}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <blue|green> [image_tag]"
    exit 1
fi

echo "Deploying to $ENVIRONMENT environment with image tag: $IMAGE_TAG"

# Update environment file with new image tag
sed -i "s/IMAGE_TAG=.*/IMAGE_TAG=$IMAGE_TAG/" .env.$ENVIRONMENT

# Deploy using docker-compose
docker-compose -f docker-compose-$ENVIRONMENT.yml down
docker-compose -f docker-compose-$ENVIRONMENT.yml pull
docker-compose -f docker-compose-$ENVIRONMENT.yml up -d

# Wait for health check
echo "Waiting for $ENVIRONMENT environment to be healthy..."
sleep 30

if ./scripts/health-check.sh $ENVIRONMENT; then
    echo "$ENVIRONMENT deployment successful!"
else
    echo "$ENVIRONMENT deployment failed!"
    exit 1
fi




# #!/bin/bash
# # Enhanced deploy script with debugging
# set -e

# ENVIRONMENT=${1:-blue}
# IMAGE_TAG=${2:-latest}

# echo "Deploying to $ENVIRONMENT environment with image tag: $IMAGE_TAG"

# # Set DB_HOST to avoid warnings
# export DB_HOST=${DB_HOST:-localhost}

# # Stop and remove existing containers
# docker-compose -f docker-compose.$ENVIRONMENT.yml down

# # Pull and start new containers
# docker-compose -f docker-compose.$ENVIRONMENT.yml pull
# docker-compose -f docker-compose.$ENVIRONMENT.yml up -d

# echo "Waiting for containers to initialize..."
# sleep 15

# # Debug: Check if container is running
# echo "=== Container Status ==="
# docker-compose -f docker-compose.$ENVIRONMENT.yml ps

# # Debug: Check container logs
# echo "=== Container Logs ==="
# docker-compose -f docker-compose.$ENVIRONMENT.yml logs --tail=20

# # Debug: Check what's listening on ports
# echo "=== Port Status ==="
# netstat -tlnp | grep :808 || echo "No services found on ports 808x"

# # Debug: Check if container port is exposed
# CONTAINER_NAME=$(docker-compose -f docker-compose.$ENVIRONMENT.yml ps -q)
# if [ ! -z "$CONTAINER_NAME" ]; then
#     echo "=== Container Port Mapping ==="
#     docker port $CONTAINER_NAME
# fi

# echo "Waiting for $ENVIRONMENT environment to be healthy..."
# ./scripts/health-check.sh $ENVIRONMENT

# if [ $? -eq 0 ]; then
#     echo "$ENVIRONMENT deployment successful!"
# else
#     echo "$ENVIRONMENT deployment failed!"
#     echo "=== Final Container Logs ==="
#     docker-compose -f docker-compose.$ENVIRONMENT.yml logs --tail=50
#     exit 1
# fi