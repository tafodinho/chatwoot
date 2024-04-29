#!/bin/bash

# Define a function to check if a service is healthy
check_service_health() {
    local service_name="$1"
    local timeout="$2"
    local interval="$3"
    local max_attempts=$((timeout / interval))
    local attempt=0

    echo "Waiting for $service_name to be healthy..."

    # Loop until the service is healthy or timeout occurs
    while [ $attempt -lt $max_attempts ]; do
        # Use Docker Compose to check the health of the service
        docker-compose exec -T "$service_name" bash -c 'exit $(docker inspect -f {{.State.Health.Status}} $(docker ps -q --filter ancestor="$1"))' >/dev/null 2>&1

        # If the service is healthy, exit the loop
        if [ $? -eq 0 ]; then
            echo "$service_name is healthy."
            exit 0
        fi

        # Increment the attempt counter and wait for the specified interval
        ((attempt++))
        sleep "$interval"
    done

    # If the timeout is reached, exit with a failure status
    echo "Timeout occurred while waiting for $service_name to be healthy."
    exit 1
}

# Check the health of the base service with a timeout of 300 seconds (5 minutes)
check_service_health "base" 300 5

# Once the base service is healthy, start other services
echo "Base service is healthy. Starting other services..."
docker-compose up -d rails sidekiq webpack postgres redis mailhog

# Exit with success status
exit 0