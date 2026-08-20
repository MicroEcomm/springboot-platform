# Database Entity-Relationship Diagrams (ERD)

Because this is a microservices architecture, there are 20 **completely isolated** databases. Foreign keys *cannot* exist between services. We use logical IDs (like `user_id` or `product_id`) to loosely couple data.

## 1. Auth Service Database (`auth_db`)
```mermaid
erDiagram
    users {
        bigint id PK
        varchar username
        varchar email
        varchar password
        boolean enabled
    }
    roles {
        bigint id PK
        varchar name
    }
    user_roles {
        bigint user_id FK
        bigint role_id FK
    }
    users ||--o{ user_roles : "has"
    roles ||--o{ user_roles : "assigned_to"
```

## 2. Product Service Database (`product_db`)
```mermaid
erDiagram
    products {
        bigint id PK
        varchar name
        varchar description
        decimal price
        bigint category_id
        bigint brand_id
    }
    product_images {
        integer id PK
        bigint product_id FK
        varchar image_url
        boolean is_primary
    }
    product_variants {
        bigint id PK
        bigint product_id FK
        varchar sku
        varchar size
        varchar color
    }
    products ||--o{ product_images : "has"
    products ||--o{ product_variants : "has"
```

## 3. Order Service Database (`order_db`)
```mermaid
erDiagram
    orders {
        bigint id PK
        bigint user_id
        decimal total_amount
        varchar status
    }
    order_items {
        bigint id PK
        bigint order_id FK
        bigint product_id
        integer quantity
        decimal price
    }
    outbox_events {
        uuid id PK
        varchar aggregate_type
        varchar aggregate_id
        varchar event_type
        jsonb payload
        boolean published
    }
    orders ||--o{ order_items : "contains"
```

## 4. Inventory Service Database (`inventory_db`)
```mermaid
erDiagram
    inventory {
        bigint id PK
        bigint product_id
        integer quantity
        integer reserved_quantity
    }
```

## 5. Cart Service Database (`cart_db`)
```mermaid
erDiagram
    carts {
        bigint id PK
        bigint user_id
    }
    cart_items {
        bigint id PK
        bigint cart_id FK
        bigint product_id
        integer quantity
    }
    carts ||--o{ cart_items : "contains"
```
