# Spring Boot Microservices E-Commerce Platform

A production-ready, highly scalable e-commerce platform built with Spring Boot 3.2, Spring Cloud, Docker, and PostgreSQL. It demonstrates modern microservices architecture, including the API Gateway pattern, centralized configuration, service discovery, distributed transactions (Saga Pattern with Transactional Outbox), and asynchronous messaging via RabbitMQ.

---

## 🚀 Start-to-Finish Quickstart Guide

Follow these steps to clone, sync, build, and deploy the entire platform on your local machine using Docker.

### 1. Clone the Repository
Because this platform uses Git Submodules for all 22 microservices, you **must** use the `--recursive` flag to pull the code for every service.

```bash
git clone --recursive git@github.com:MicroEcomm/springboot-platform.git
cd springboot-platform
```

*(If you cloned without `--recursive`, run: `git submodule update --init --recursive`)*

### 2. Synchronize Code (Optional but Recommended)
To ensure you have the absolute latest code across all submodules, use the provided robust sync script. This script automatically handles SSH and GPG fallbacks:

```bash
./git-sync.sh
```

### 3. Deploy with Docker
The platform is fully containerized. A single script handles the entire build and deployment orchestration, including waiting for databases and RabbitMQ to be healthy before starting the services.

```bash
./deploy.sh
```
*(Alternatively, you can manually run: `docker compose up -d --build`)*

**Note on First Boot:** 
- The first build takes ~5-10 minutes as Maven resolves dependencies.
- Submits 16 Postgres databases automatically via `docker/init-multiple-databases.sh`.
- Services may restart 1-2 times as they wait for the Eureka server to fully register them. This is expected self-healing behavior.

---

## 📡 Accessing the Live System

Once the deployment finishes and the system stabilizes (~3 minutes after containers start), you can access the platform via the following URLs:

### Infrastructure
| Component | URL | Credentials / Notes |
|-----------|-----|---------------------|
| **API Gateway** | `http://localhost:8080` | All external API traffic routes here |
| **Eureka Dashboard** | `http://localhost:8761` | View all registered microservices |
| **RabbitMQ Management** | `http://localhost:15672` | `guest` / `guest` |
| **Config Server Health** | `http://localhost:8888/actuator/health` | Verifies YAML config loading |

### Microservices (Swagger UI)
Every business service exposes its own OpenAPI / Swagger documentation page for easy live testing.

| Service | Port | Swagger UI URL |
|---------|------|----------------|
| `auth-service` | 8081 | [http://localhost:8081/swagger-ui/index.html](http://localhost:8081/swagger-ui/index.html) |
| `user-service` | 8082 | [http://localhost:8082/swagger-ui/index.html](http://localhost:8082/swagger-ui/index.html) |
| `product-service` | 8083 | [http://localhost:8083/swagger-ui/index.html](http://localhost:8083/swagger-ui/index.html) |
| `category-service` | 8084 | [http://localhost:8084/swagger-ui/index.html](http://localhost:8084/swagger-ui/index.html) |
| `brand-service` | 8085 | [http://localhost:8085/swagger-ui/index.html](http://localhost:8085/swagger-ui/index.html) |
| `inventory-service` | 8086 | [http://localhost:8086/swagger-ui/index.html](http://localhost:8086/swagger-ui/index.html) |
| `cart-service` | 8087 | [http://localhost:8087/swagger-ui/index.html](http://localhost:8087/swagger-ui/index.html) |
| `wishlist-service` | 8088 | [http://localhost:8088/swagger-ui/index.html](http://localhost:8088/swagger-ui/index.html) |
| `search-service` | 8089 | [http://localhost:8089/swagger-ui/index.html](http://localhost:8089/swagger-ui/index.html) |
| `order-service` | 8090 | [http://localhost:8090/swagger-ui/index.html](http://localhost:8090/swagger-ui/index.html) |
| `payment-service` | 8091 | [http://localhost:8091/swagger-ui/index.html](http://localhost:8091/swagger-ui/index.html) |
| `coupon-service` | 8092 | [http://localhost:8092/swagger-ui/index.html](http://localhost:8092/swagger-ui/index.html) |
| `shipping-service` | 8093 | [http://localhost:8093/swagger-ui/index.html](http://localhost:8093/swagger-ui/index.html) |
| `review-service` | 8094 | [http://localhost:8094/swagger-ui/index.html](http://localhost:8094/swagger-ui/index.html) |
| `notification-service` | 8095 | [http://localhost:8095/swagger-ui/index.html](http://localhost:8095/swagger-ui/index.html) |
| `seller-service` | 8096 | [http://localhost:8096/swagger-ui/index.html](http://localhost:8096/swagger-ui/index.html) |
| `admin-service` | 8097 | [http://localhost:8097/swagger-ui/index.html](http://localhost:8097/swagger-ui/index.html) |
| `report-service` | 8098 | [http://localhost:8098/swagger-ui/index.html](http://localhost:8098/swagger-ui/index.html) |
| `audit-service` | 8099 | [http://localhost:8099/swagger-ui/index.html](http://localhost:8099/swagger-ui/index.html) |

---

## 🏗️ Project Structure (24 Modules)

The platform is divided into 24 distinct Maven modules (2 infrastructure, 1 library, 2 cloud, 19 business).

### Shared & Infrastructure
- `common-lib/`: Shared DTOs (`ApiResponse`), Exceptions, and Global Exception Handlers used by all REST controllers.
- `config-repo/`: Centralized YAML configurations for all services, mounted dynamically by the Config Server.
- `docker/`: Docker initialization scripts, including the multi-database setup script.

### Spring Cloud Core
- `config-server/`: Fetches configurations from `config-repo/` and serves them to microservices dynamically.
- `discovery-server/`: Netflix Eureka server for service registration, health checking, and discovery.
- `api-gateway/`: Spring Cloud Gateway mapping routes `/api/v1/*` to backend load-balanced services.

### Business Microservices (19)
Each service has its own bounded context, its own PostgreSQL database, and communicates synchronously via REST/Gateway or asynchronously via RabbitMQ.
1. `auth-service` (JWT Generation/Validation)
2. `user-service` (User Profiles)
3. `product-service` (Product Catalog)
4. `category-service` (Taxonomies)
5. `brand-service` (Brand Management)
6. `inventory-service` (Stock Management)
7. `cart-service` (Shopping Cart)
8. `wishlist-service` (Saved Items)
9. `search-service` (Product Search)
10. `order-service` (Order Orchestration & Saga Coordinator)
11. `payment-service` (Payment Processing Mock)
12. `coupon-service` (Discounts & Promos)
13. `shipping-service` (Logistics)
14. `review-service` (Product Reviews)
15. `notification-service` (Email/SMS Mock)
16. `seller-service` (Marketplace Vendors)
17. `admin-service` (Admin Dashboard API)
18. `report-service` (Analytics)
19. `audit-service` (Action Auditing)

---

## 📚 Detailed Documentation

Please see the `docs/` directory for in-depth technical documentation:
- [Architecture & Flow Diagram](docs/ARCHITECTURE.md)
- [Database ERDs](docs/DATABASE_ERD.md)
- [API Reference](docs/API_REFERENCE.md)
