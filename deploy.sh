#!/bin/bash
echo "Deploying E-Commerce Microservices Cluster..."

# Rebuild Java code (if maven is available, else we rely on Docker multi-stage build)
# mvn clean package -DskipTests

# Build and start Docker containers in detached mode
echo "Spinning up infrastructure..."
docker compose up -d --build

echo ""
echo "Deployment triggered. Please use 'docker ps' or 'lazydocker' to monitor startup."
echo "Note: The discovery-server and config-server will take a few seconds to warm up,"
echo "and other services might restart once or twice until Eureka is available. This is normal."
