# System Architecture

This document describes the high-level architecture of the Microservices E-Commerce Platform.

## 1. Network Routing & Service Discovery
All incoming traffic is routed through the Spring Cloud Gateway (`api-gateway`). It acts as a reverse proxy, validates JWT tokens, and forwards the requests to the appropriate downstream microservice using Netflix Eureka (`discovery-server`).

```mermaid
graph TD
    Client((Client)) -->|HTTPS| Gateway[API Gateway :8080]
    
    subgraph Discovery
        Eureka[Eureka Server :8761]
    end
    
    Gateway -->|JWT Validation| Auth[Auth Service]
    Gateway -.->|Routes via Eureka| Eureka
    
    Gateway --> Product[Product Service]
    Gateway --> Order[Order Service]
    Gateway --> Cart[Cart Service]
    Gateway --> Inventory[Inventory Service]
    
    Auth -.->|Registers| Eureka
    Product -.->|Registers| Eureka
    Order -.->|Registers| Eureka
    Cart -.->|Registers| Eureka
    Inventory -.->|Registers| Eureka
```

## 2. Order Saga (Distributed Transactions)
Because databases are completely isolated per microservice, placing an order requires modifying data across `order-service`, `payment-service`, and `inventory-service`. To ensure atomicity and consistency, we use the **Transactional Outbox & Saga Pattern** orchestrated via RabbitMQ.

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
```
