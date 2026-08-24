# System Architecture

This document describes the high-level architecture of the Microservices E-Commerce Platform. The platform runs on Spring Boot 3.2.4 and uses Netflix Eureka for service discovery, Spring Cloud Gateway for API routing, PostgreSQL for isolated per-service persistence, and RabbitMQ for asynchronous event-driven choreographies.

## 1. Network Routing & Service Discovery

All incoming external traffic routes through the Spring Cloud Gateway (`api-gateway`). The Gateway acts as a reverse proxy, validates JWT tokens, and dynamically forwards requests to the appropriate downstream microservice using the Netflix Eureka registry (`discovery-server`).

### The Complete Service Topology
```mermaid
graph TD
    Client((Web/Mobile Client)) -->|HTTPS| Gateway[API Gateway :8080]
    
    subgraph Spring Cloud Infrastructure
        Eureka[Eureka Server :8761]
        Config[Config Server :8888]
    end
    
    %% Gateway to Services
    Gateway -->|JWT Validation| Auth[Auth Service]
    Gateway -.->|Routes via Eureka| Eureka
    
    Gateway --> S1[User Service]
    Gateway --> S2[Product Service]
    Gateway --> S3[Category Service]
    Gateway --> S4[Brand Service]
    Gateway --> S5[Inventory Service]
    Gateway --> S6[Cart Service]
    Gateway --> S7[Wishlist Service]
    Gateway --> S8[Search Service]
    Gateway --> S9[Order Service]
    Gateway --> S10[Payment Service]
    Gateway --> S11[Coupon Service]
    Gateway --> S12[Shipping Service]
    Gateway --> S13[Review Service]
    Gateway --> S14[Notification Service]
    Gateway --> S15[Seller Service]
    Gateway --> S16[Admin Service]
    Gateway --> S17[Report Service]
    Gateway --> S18[Audit Service]
    
    %% Config and Discovery Registration
    Auth -.->|Registers| Eureka
    S1 -.->|Registers| Eureka
    S2 -.->|Registers| Eureka
    S5 -.->|Registers| Eureka
    S9 -.->|Registers| Eureka
    S18 -.->|Registers| Eureka
    
    %% To avoid massive arrow clutter, note that ALL services register with Eureka
    %% and fetch configuration from the Config Server on startup.
```

## 2. Infrastructure Layer
- **Config Server (`config-server`)**: On boot, all services reach out to the Config Server via `spring.config.import`. The server loads `config-repo/*.yml` files directly, injecting database credentials and runtime properties.
- **Service Discovery (`discovery-server`)**: A centralized Netflix Eureka dashboard. Services send heartbeats every 30 seconds.
- **Docker Compose**: Uses a custom multi-stage Dockerfile to compile the parent POM, then `common-lib`, and finally the individual target service, resulting in a lightweight JRE Alpine container.
- **PostgreSQL**: Instead of deploying 16 separate database containers, a single Postgres container runs on port 5432 and uses a custom `init-multiple-databases.sh` script to auto-create `auth_db`, `order_db`, `product_db`, etc., upon initial volume creation.

## 3. Order Saga & Asynchronous Messaging

Because microservices do not share databases (Database-per-Service pattern), a distributed transaction like placing an order requires modifying data across `order-service`, `payment-service`, and `inventory-service` safely.

To ensure atomicity and consistency, we use the **Transactional Outbox & Saga Pattern** orchestrated via **RabbitMQ**.

### Outbox Pattern
When the `Order Service` receives a checkout request, it inserts the `Order` into the database and simultaneously inserts an `OutboxEvent` (e.g. `ORDER_CREATED`) in the exact same SQL transaction. A background poller then picks up this event and publishes it to RabbitMQ, ensuring that network failures do not result in lost messages.

### The Saga Flow
```mermaid
sequenceDiagram
    participant C as Client
    participant O as Order Service
    participant DB as Postgres (Order DB)
    participant MQ as RabbitMQ
    participant P as Payment Service
    participant I as Inventory Service

    C->>O: POST /api/v1/orders
    O->>DB: Save Order (PENDING) + OutboxEvent (ORDER_CREATED)
    DB-->>O: Transaction Committed
    O-->>C: 202 Accepted

    loop Every 5 Seconds
        O->>DB: Poll for un-published OutboxEvents
        DB-->>O: Returns ORDER_CREATED
        O->>MQ: Publish 'order.created'
        O->>DB: Mark Event as published
    end

    MQ->>P: Consume 'order.created'
    P->>P: Process Payment
    alt Payment Success
        P->>MQ: Publish 'payment.completed'
    else Payment Failed
        P->>MQ: Publish 'payment.failed'
    end
    
    MQ->>I: Consume 'payment.completed'
    I->>I: Reserve Inventory
    alt Inventory Success
        I->>MQ: Publish 'inventory.reserved'
    else Inventory Failed
        I->>MQ: Publish 'inventory.failed'
    end
    
    MQ->>O: Consume 'inventory.reserved'
    O->>DB: Update Order Status -> CONFIRMED
    
    MQ->>O: Consume 'payment.failed' or 'inventory.failed'
    O->>DB: Update Order Status -> CANCELLED
    
    %% Other Async listeners
    MQ->>N: (Notification Service) Consume events -> Send Emails
    MQ->>A: (Audit Service) Consume events -> Log Audit Trail
```

### Event Consumers
The platform relies heavily on pub/sub for side-effects:
- `notification-service`: Listens to `order.created`, `payment.completed`, `user.registered` to send mock emails/SMS.
- `audit-service`: Listens to various domain events to record user actions securely in an immutable log.
- `report-service`: Materializes views from events to optimize analytical queries without querying the live production transactional databases.
