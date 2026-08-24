# Global API Reference

All external requests must be prefixed with `http://localhost:8080` (The API Gateway). The Gateway automatically routes `/api/v1/{service}/**` to the correct backend microservice via Eureka.

> [!TIP]
> **Live Swagger UI Testing**
> Every single microservice generates its own live Swagger documentation. If you are running the platform via Docker, you can instantly test all these endpoints interactively by going to `http://localhost:808{1-9}/swagger-ui/index.html` (e.g., Auth is 8081, User is 8082).

## Authentication (`/api/v1/auth`) -> `auth-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/auth/register` | Register a new user | No |
| POST   | `/api/v1/auth/login` | Login and receive a JWT | No |

## Users (`/api/v1/users`) -> `user-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/users/me` | Get currently logged in user profile | Yes |
| PUT    | `/api/v1/users/me` | Update profile | Yes |

## Products (`/api/v1/products`) -> `product-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/products` | Create a new product | Yes (Admin) |
| GET    | `/api/v1/products` | List all products (with pagination) | No |
| GET    | `/api/v1/products/{id}` | Get specific product details | No |

## Categories (`/api/v1/categories`) -> `category-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/categories` | Create a new category | Yes (Admin) |
| GET    | `/api/v1/categories` | List all categories | No |

## Brands (`/api/v1/brands`) -> `brand-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/brands` | Create a new brand | Yes (Admin) |
| GET    | `/api/v1/brands` | List all brands | No |

## Inventory (`/api/v1/inventory`) -> `inventory-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/inventory/{productId}` | Check stock availability | No |
| POST   | `/api/v1/inventory/reserve` | Reserve stock (internal) | Yes |

## Cart (`/api/v1/cart`) -> `cart-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/cart/items` | Add item to cart | Yes |
| GET    | `/api/v1/cart` | View current user's cart | Yes |
| DELETE | `/api/v1/cart/items/{id}` | Remove item from cart | Yes |

## Wishlist (`/api/v1/wishlists`) -> `wishlist-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/wishlists/{productId}` | Add item to wishlist | Yes |
| GET    | `/api/v1/wishlists` | View wishlist | Yes |

## Search (`/api/v1/search`) -> `search-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/search` | Search products via ElasticSearch | No |

## Orders (`/api/v1/orders`) -> `order-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/orders` | Place a new order (Triggers Saga) | Yes |
| GET    | `/api/v1/orders/{id}` | View order details | Yes |
| GET    | `/api/v1/orders` | View user's order history | Yes |

## Payments (`/api/v1/payments`) -> `payment-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/payments/{orderId}` | Check payment status | Yes |
| POST   | `/api/v1/payments/webhook` | Mock payment gateway webhook | No |

## Coupons (`/api/v1/coupons`) -> `coupon-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/coupons/validate` | Validate promo code | Yes |
| POST   | `/api/v1/coupons` | Create promo code | Yes (Admin) |

## Shipping (`/api/v1/shipping`) -> `shipping-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/shipping/track/{id}` | Track order shipment | Yes |

## Reviews (`/api/v1/reviews`) -> `review-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/reviews` | Leave a product review | Yes |
| GET    | `/api/v1/reviews/product/{id}`| Get product reviews | No |

## Notifications (`/api/v1/notifications`) -> `notification-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/notifications` | Get user notifications | Yes |

## Sellers (`/api/v1/sellers`) -> `seller-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST   | `/api/v1/sellers/register` | Register as a vendor | Yes |
| GET    | `/api/v1/sellers/{id}` | Get seller profile | No |

## Admin (`/api/v1/admin`) -> `admin-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/admin/dashboard` | Get platform metrics | Yes (Admin) |

## Reports (`/api/v1/reports`) -> `report-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/reports/sales` | Get sales analytics | Yes (Admin) |

## Audit Logs (`/api/v1/audit`) -> `audit-service`
| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET    | `/api/v1/audit` | View platform audit logs | Yes (Admin) |
