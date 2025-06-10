
ENVIRONMENT=${1:-blue}

# Set port based on environment
if [ "$ENVIRONMENT" = "blue" ]; then
    PORT=8080
elif [ "$ENVIRONMENT" = "green" ]; then
    PORT=8081
else
    echo "Unknown environment: $ENVIRONMENT"
    echo "Usage: $0 <blue|green>"
    exit 1
fi

echo "Checking health of $ENVIRONMENT environment on port $PORT..."

# Port check
echo "=== Port Check ==="
netstat -tlnp | grep :$PORT

# Basic connection test
echo "=== Basic Connection Test ==="
if nc -z localhost $PORT; then
    echo "Port $PORT is reachable"
else
    echo "Port $PORT is not reachable - container may not be running or port not exposed"
fi

# Health check with retry logic
echo "=== Health Check with Retries ==="
MAX_ATTEMPTS=10
SLEEP_INTERVAL=10

for i in $(seq 1 $MAX_ATTEMPTS); do
    echo "=== Attempt $i/$MAX_ATTEMPTS ==="
    
    # Try health endpoint
    if curl -f -s -v http://localhost:$PORT/health; then
        echo ""
        echo "$ENVIRONMENT environment is healthy!"
        exit 0
    fi
    
    echo ""
    echo "Trying root endpoint..."
    if curl -f -s -v http://localhost:$PORT/; then
        echo ""
        echo "$ENVIRONMENT environment is responding (no /health endpoint)"
        exit 0
    fi
    
    if [ $i -lt $MAX_ATTEMPTS ]; then
        echo ""
        echo "Attempt $i/$MAX_ATTEMPTS failed, retrying in $SLEEP_INTERVAL seconds..."
        sleep $SLEEP_INTERVAL
    fi
done

echo ""
echo "$ENVIRONMENT environment health check failed!"
echo ""
echo "=== Final Debug Info ==="
echo "Attempted URL: http://localhost:$PORT/health"
echo "Please verify:"
echo "1. Your application is listening on port $PORT"
echo "2. Your application has a /health endpoint"
echo "3. Docker port mapping is correct in docker-compose-$ENVIRONMENT.yml"
echo ""
echo "=== Container Status ==="
docker-compose -f docker-compose-$ENVIRONMENT.yml ps

echo ""
echo "=== Recent Logs ==="
docker-compose -f docker-compose-$ENVIRONMENT.yml logs --tail=20

exit 1