# API Reference

All requests must be prefixed with `http://localhost:8080` (API Gateway).
All secured routes require a JWT passed in the `Authorization: Bearer <token>` header.

## Authentication (`/api/v1/auth`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/auth/register` | Register a new user | No |
| POST   | `/api/v1/auth/login` | Login and receive a JWT | No |

## Products (`/api/v1/products`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/products` | Create a new product | Yes (Admin) |
| GET    | `/api/v1/products` | List all products | No |
| GET    | `/api/v1/products/{id}` | Get product details | No |

## Categories (`/api/v1/categories`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/categories` | Create a new category | Yes (Admin) |
| GET    | `/api/v1/categories` | List all categories | No |

## Cart (`/api/v1/cart`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/cart/items` | Add item to cart | Yes |
| GET    | `/api/v1/cart` | View current cart | Yes |

## Orders (`/api/v1/orders`)
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/orders` | Place a new order | Yes |
| GET    | `/api/v1/orders/{id}` | View order details | Yes |
