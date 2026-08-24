#!/bin/bash
# =============================================================================
# deploy.sh — Full production deployment script
# Builds all Docker images and starts the entire ecommerce platform
# =============================================================================

set -e

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║     MicroEcomm Platform — Docker Deployment         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
command -v docker &>/dev/null || { echo "ERROR: Docker not found. Install Docker first."; exit 1; }
command -v docker compose &>/dev/null || { echo "ERROR: Docker Compose v2 not found."; exit 1; }

# Ensure the init script is executable
chmod +x docker/init-multiple-databases.sh 2>/dev/null || true

echo "→ Cleaning up old containers (if any)..."
docker compose down --remove-orphans 2>/dev/null || true

echo ""
echo "→ Building all service images (this takes 5-10 minutes on first run)..."
docker compose build --parallel

echo ""
echo "→ Starting infrastructure services first..."
docker compose up -d postgres redis rabbitmq
echo "  Waiting for infrastructure health checks..."
sleep 10

echo ""
echo "→ Starting Spring Cloud infrastructure (Config Server + Eureka)..."
docker compose up -d config-server
echo "  Waiting for config-server to be healthy (up to 60s)..."
timeout 90 bash -c 'until docker inspect config-server --format="{{.State.Health.Status}}" 2>/dev/null | grep -q healthy; do sleep 5; echo "  ... waiting for config-server"; done' || echo "  WARNING: config-server may still be starting"

docker compose up -d discovery-server
echo "  Waiting for discovery-server to be healthy (up to 60s)..."
timeout 90 bash -c 'until docker inspect discovery-server --format="{{.State.Health.Status}}" 2>/dev/null | grep -q healthy; do sleep 5; echo "  ... waiting for discovery-server"; done' || echo "  WARNING: discovery-server may still be starting"

echo ""
echo "→ Starting all business services..."
docker compose up -d

echo ""
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  Deployment complete! Services are starting up.                     ║"
echo "╠══════════════════════════════════════════════════════════════════════╣"
echo "║  Note: Services may take 2-3 minutes to fully register with Eureka  ║"
echo "╠══════════════════════════════════════════════════════════════════════╣"
echo "║                                                                      ║"
echo "║  📡 Eureka Dashboard:    http://localhost:8761                       ║"
echo "║  🔀 API Gateway:         http://localhost:8080                       ║"
echo "║  🐰 RabbitMQ Mgmt:       http://localhost:15672  (guest/guest)      ║"
echo "║  🗄️  Config Server:       http://localhost:8888/actuator/health      ║"
echo "║                                                                      ║"
echo "║  Swagger UI (per service):                                           ║"
echo "║    Auth:        http://localhost:8081/swagger-ui/index.html          ║"
echo "║    User:        http://localhost:8082/swagger-ui/index.html          ║"
echo "║    Product:     http://localhost:8083/swagger-ui/index.html          ║"
echo "║    Category:    http://localhost:8084/swagger-ui/index.html          ║"
echo "║    Brand:       http://localhost:8085/swagger-ui/index.html          ║"
echo "║    Inventory:   http://localhost:8086/swagger-ui/index.html          ║"
echo "║    Cart:        http://localhost:8087/swagger-ui/index.html          ║"
echo "║    Wishlist:    http://localhost:8088/swagger-ui/index.html          ║"
echo "║    Search:      http://localhost:8089/swagger-ui/index.html          ║"
echo "║    Order:       http://localhost:8090/swagger-ui/index.html          ║"
echo "║    Payment:     http://localhost:8091/swagger-ui/index.html          ║"
echo "║    Coupon:      http://localhost:8092/swagger-ui/index.html          ║"
echo "║    Shipping:    http://localhost:8093/swagger-ui/index.html          ║"
echo "║    Review:      http://localhost:8094/swagger-ui/index.html          ║"
echo "║    Notification:http://localhost:8095/swagger-ui/index.html          ║"
echo "║    Seller:      http://localhost:8096/swagger-ui/index.html          ║"
echo "║    Admin:       http://localhost:8097/swagger-ui/index.html          ║"
echo "║    Report:      http://localhost:8098/swagger-ui/index.html          ║"
echo "║    Audit:       http://localhost:8099/swagger-ui/index.html          ║"
echo "║                                                                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""
echo "  Tip: Run 'docker compose ps' to check container status"
echo "  Tip: Run 'docker compose logs -f <service-name>' to view logs"
echo ""
