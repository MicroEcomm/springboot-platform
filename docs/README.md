# Microservices E-Commerce Platform

A highly scalable, highly available E-Commerce platform built using 20+ Spring Boot microservices, Netflix Eureka, RabbitMQ, Redis, PostgreSQL, and Spring Cloud Gateway.

## Overview
This platform employs a highly distributed architecture designed for maximum fault tolerance. Key features include:
- **Centralized Routing & Security**: API Gateway handles routing and JWT validation, stripping the load off individual microservices.
- **Service Discovery**: Netflix Eureka allows services to dynamically discover and call each other.
- **Transactional Outbox & Saga Pattern**: Distributed transactions (like Order -> Payment -> Inventory) are managed via RabbitMQ to ensure absolute data consistency.
- **Database per Service**: 20 independent PostgreSQL databases (housed on a single PG cluster for local dev) ensure no single point of failure and true microservice isolation.

## Architecture & Schemas
Please view the detailed architectural diagrams and schemas in the `docs/` folder:
- [ARCHITECTURE.md](./ARCHITECTURE.md): Contains Mermaid.js diagrams for network routing, service discovery, and Saga event orchestration.
- [DATABASE_ERD.md](./DATABASE_ERD.md): Contains the Entity-Relationship Diagrams (ERD) mapping the schemas of all 20 microservices.
- [API_REFERENCE.md](./API_REFERENCE.md): Documentation of the core REST APIs across the platform.

## Getting Started (Local Development)

### Prerequisites
- Docker Engine & Docker Compose
- 16GB+ RAM (24GB recommended due to the sheer size of the cluster)

### Installation
1. Clone this repository:
   ```bash
   git clone <repo-url>
   cd springboot
   ```
2. Trigger the deployment script (this will rebuild the Java images using multi-stage Docker builds and start the cluster):
   ```bash
   ./deploy.sh
   ```
3. (Optional) Check the status of the containers using Lazydocker:
   ```bash
   lazydocker
   ```

### Important Endpoints
- **API Gateway (Entrypoint):** `http://localhost:8080`
- **Eureka Dashboard:** `http://localhost:8761`
- **RabbitMQ Dashboard:** `http://localhost:15672` (guest / guest)

## Version Control Management
Because of the size of the repository, we have included helper scripts:
- `./git-sync.sh`: Automates pulling changes from remote, staging everything, committing, and pushing back to remote.

## Known Limitations
- The current Docker Compose setup caps JVMs at `-Xmx256m` and restricts DB Connection Pools to `3` per service to prevent OOM errors on standard developer laptops.
- For true production deployment, use Kubernetes (K8s) manifests to orchestrate the containers dynamically.
