# API Specification - Vista Egyptian AI Market Analysis App

## Base Information

- **Base URL**: `https://api.vista.app` (Production) | `http://localhost:8000` (Development)
- **API Version**: `/api/v1`
- **Content-Type**: `application/json`
- **Authentication**: Laravel Sanctum token-based (Bearer token in `Authorization` header)
- **Response Format**: JSON with Arabic text values for user-facing strings; keys remain English

## Authentication Endpoints

### POST `/api/v1/auth/register`

Register a new user account.

**Request**:
```json
{
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!"
}
```

**Response** (`201 Created`):
```json
{
  "token": "1|abcdefghijklmnopqrstuvwxyz1234567890",
  "user": {
    "id": 1,
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "language": "ar",
    "theme": "light"
  }
}
```

**Validation Errors** (`422 Unprocessable Entity`):
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email has already been taken."],
    "password": ["The password confirmation does not match."]
  }
}
```

### POST `/api/v1/auth/login`

Authenticate and receive access token.

**Request**:
```json
{
  "email": "ahmed@example.com",
  "password": "SecurePassword123!"
}
```

**Response** (`200 OK`):
```json
{
  "token": "1|abcdefghijklmnopqrstuvwxyz1234567890",
  "user": {
    "id": 1,
    "name": "أحمد محمد",
    "email": "ahmed@example.com",
    "language": "ar",
    "theme": "light"
  }
}
```

**Unauthorized** (`401 Unauthorized`):
```json
{
  "message": "Invalid credentials."
}
```

### GET `/api/v1/auth/me`

Get current authenticated user information.

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "id": 1,
  "name": "أحمد محمد",
  "email": "ahmed@example.com",
  "language": "ar",
  "theme": "light",
  "email_verified_at": "2024-01-15T10:30:00.000000Z"
}
```

### POST `/api/v1/auth/logout`

Revoke current access token.

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "message": "تم تسجيل الخروج بنجاح"
}
```

### POST `/api/v1/auth/device/register`

Register device for push notifications (FCM).

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "fcm_token": "fK9xZ...",
  "platform": "android",
  "device_id": "unique-device-id-123",
  "app_version": "1.0.0"
}
```

**Response** (`201 Created`):
```json
{
  "id": 1,
  "platform": "android",
  "fcm_token": "fK9xZ...",
  "device_id": "unique-device-id-123"
}
```

## Market Data Endpoints

### GET `/api/v1/market/summary`

Get EGX market summary (index values, change, chart).

**Response** (`200 OK`):
```json
{
  "indexName": "EGX30",
  "value": 28456.78,
  "change": 234.56,
  "changePercent": 0.83,
  "chartData": [28100.0, 28200.0, 28150.0, 28300.0, 28250.0, 28400.0, 28456.78],
  "lastUpdate": "14:30"
}
```

## Signal Endpoints

### GET `/api/v1/signals/today`

Get signals generated today. Requires subscription entitlement.

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:
- `limit` (optional, default: 50): Maximum number of signals
- `signal_type` (optional): Filter by `buy`, `sell`, or `hold`
- `min_confidence` (optional, default: 0): Minimum confidence level (0-100)

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "id": 1,
      "stock": {
        "symbol": "COMI",
        "name": "البنك التجاري الدولي"
      },
      "price": 68.5,
      "changePercent": 2.35,
      "signalType": "buy",
      "confidence": 85,
      "riskLevel": "low",
      "generatedAt": "2024-01-15T10:30:00.000000Z"
    }
  ],
  "meta": {
    "total": 12,
    "limit": 50,
    "page": 1
  }
}
```

**Feature Gate Error** (`403 Forbidden`):
```json
{
  "message": "This feature requires a Basic or Pro subscription.",
  "required_plan": "basic"
}
```

### GET `/api/v1/signals/recent`

Get recent signals (last 7 days by default). Requires subscription entitlement.

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:
- `days` (optional, default: 7): Number of days to look back
- `stock_symbol` (optional): Filter by stock symbol
- `signal_type` (optional): Filter by signal type

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "id": 1,
      "stock": {
        "symbol": "COMI",
        "name": "البنك التجاري الدولي"
      },
      "price": 68.5,
      "changePercent": 2.35,
      "signalType": "buy",
      "confidence": 85,
      "riskLevel": "low",
      "generatedAt": "2024-01-15T10:30:00.000000Z"
    }
  ]
}
```

### GET `/api/v1/signals/{id}`

Get detailed signal information with explanations.

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "id": 1,
  "stock": {
    "symbol": "COMI",
    "name": "البنك التجاري الدولي",
    "sector": "البنوك"
  },
  "price": 68.5,
  "changePercent": 2.35,
  "signalType": "buy",
  "confidence": 85,
  "riskLevel": "low",
  "targetPrice": 75.0,
  "stopLoss": 64.0,
  "whyReasons": [
    "زيادة في حجم التداول بنسبة 40% عن المتوسط",
    "اختراق مستوى مقاومة رئيسي عند 67.50",
    "مؤشرات فنية إيجابية (RSI, MACD)"
  ],
  "caveats": [
    "تقلبات السوق العامة قد تؤثر على السعر",
    "نتائج الربع القادم قد تختلف عن التوقعات"
  ],
  "technicalSummary": "الإشارة مبنية على تحليل فني شامل يأخذ في الاعتبار عدة مؤشرات...",
  "generatedAt": "2024-01-15T10:30:00.000000Z"
}
```

**Not Found** (`404 Not Found`):
```json
{
  "message": "Signal not found."
}
```

### GET `/api/v1/stocks/{symbol}/signals`

Get all signals for a specific stock.

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:
- `limit` (optional, default: 20)
- `signal_type` (optional)

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "id": 1,
      "signalType": "buy",
      "confidence": 85,
      "riskLevel": "low",
      "price": 68.5,
      "generatedAt": "2024-01-15T10:30:00.000000Z"
    }
  ]
}
```

## Stock Endpoints

### GET `/api/v1/stocks`

Get list of all active stocks.

**Query Parameters**:
- `sector` (optional): Filter by sector
- `search` (optional): Search by symbol or name
- `limit` (optional, default: 100)
- `page` (optional, default: 1)

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "symbol": "COMI",
      "name": "البنك التجاري الدولي",
      "price": 68.5,
      "change": 1.58,
      "changePercent": 2.35,
      "sector": "البنوك",
      "chart": [65.0, 66.0, 67.0, 68.0, 68.5]
    }
  ],
  "meta": {
    "total": 250,
    "per_page": 100,
    "current_page": 1,
    "last_page": 3
  }
}
```

### GET `/api/v1/stocks/{symbol}`

Get detailed stock information.

**Response** (`200 OK`):
```json
{
  "symbol": "COMI",
  "name": "البنك التجاري الدولي",
  "price": 68.5,
  "change": 1.58,
  "changePercent": 2.35,
  "open": 67.2,
  "high": 69.1,
  "low": 66.8,
  "close": 66.92,
  "volume": 2450000,
  "marketCap": 125000000000,
  "pe": 12.5,
  "eps": 5.48,
  "dividend": 2.5,
  "sector": "البنوك",
  "chartData": [65.0, 66.0, 67.0, 68.0, 67.5, 68.2, 68.5],
  "indicators": {
    "rsi14": 65.5,
    "ma20": 67.2,
    "ma50": 66.8,
    "ma200": 65.0
  }
}
```

### GET `/api/v1/stocks/{symbol}/candles`

Get historical candle data.

**Query Parameters**:
- `range` (required): `1m`, `3m`, `6m`, `1y`, or `all`
- `start_date` (optional): ISO date string
- `end_date` (optional): ISO date string

**Response** (`200 OK`):
```json
{
  "symbol": "COMI",
  "range": "1m",
  "candles": [
    {
      "date": "2024-01-15",
      "open": 67.2,
      "high": 69.1,
      "low": 66.8,
      "close": 68.5,
      "volume": 2450000
    }
  ]
}
```

## Fund Endpoints

### GET `/api/v1/funds`

Get list of all active funds.

**Query Parameters**: Same as stocks endpoint

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "id": 1,
      "code": "F001",
      "name": "صندوق بنك مصر",
      "nav": 125.5,
      "change": 1.2,
      "changePercent": 0.96,
      "type": "أسهم"
    }
  ]
}
```

### GET `/api/v1/funds/{id}`

Get detailed fund information.

**Response** (`200 OK`):
```json
{
  "id": 1,
  "code": "F001",
  "name": "صندوق بنك مصر",
  "nav": 125.5,
  "change": 1.2,
  "changePercent": 0.96,
  "type": "أسهم",
  "managementCompany": "بنك مصر",
  "inceptionDate": "2020-01-15"
}
```

## Watchlist Endpoints

### GET `/api/v1/watchlists`

Get all user watchlists (including favorites).

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "favorites": {
    "id": 1,
    "name": "المفضلة",
    "items": [
      {
        "id": 1,
        "type": "stock",
        "stock": {
          "symbol": "COMI",
          "name": "البنك التجاري الدولي",
          "price": 68.5,
          "changePercent": 2.35
        }
      }
    ]
  },
  "watchlists": [
    {
      "id": 2,
      "name": "البنوك",
      "items": [
        {
          "id": 2,
          "type": "stock",
          "stock": {
            "symbol": "COMI",
            "name": "البنك التجاري الدولي",
            "price": 68.5,
            "changePercent": 2.35
          }
        }
      ]
    }
  ]
}
```

### POST `/api/v1/watchlists`

Create a new watchlist.

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "name": "البنوك"
}
```

**Response** (`201 Created`):
```json
{
  "id": 2,
  "name": "البنوك",
  "items": []
}
```

**Feature Gate Error** (`403 Forbidden`):
```json
{
  "message": "Maximum watchlists limit reached for your plan.",
  "current_plan": "free",
  "max_watchlists": 1
}
```

### PUT `/api/v1/watchlists/{id}`

Update watchlist name.

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "name": "العقارات"
}
```

**Response** (`200 OK`):
```json
{
  "id": 2,
  "name": "العقارات"
}
```

### DELETE `/api/v1/watchlists/{id}`

Delete a watchlist (soft delete).

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "message": "تم حذف القائمة بنجاح"
}
```

### POST `/api/v1/watchlists/{id}/items`

Add item (stock or fund) to watchlist.

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "type": "stock",
  "symbol": "COMI"
}
```

**Response** (`201 Created`):
```json
{
  "id": 3,
  "type": "stock",
  "stock": {
    "symbol": "COMI",
    "name": "البنك التجاري الدولي"
  }
}
```

### DELETE `/api/v1/watchlists/{id}/items/{itemId}`

Remove item from watchlist.

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "message": "تم حذف السهم من القائمة"
}
```

## Alert Endpoints

### GET `/api/v1/alerts`

Get user alerts (notifications + alerts).

**Headers**: `Authorization: Bearer {token}`

**Query Parameters**:
- `is_read` (optional): Filter by read status (`true`/`false`)
- `limit` (optional, default: 50)

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "id": 1,
      "type": "signal",
      "title": "إشارة جديدة",
      "message": "إشارة شراء على سهم البنك التجاري الدولي (COMI)",
      "time": "منذ 5 دقائق",
      "isRead": false,
      "data": {
        "signal_id": 1,
        "stock_symbol": "COMI"
      }
    }
  ]
}
```

### PUT `/api/v1/alerts/{id}/read`

Mark alert as read.

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "id": 1,
  "isRead": true,
  "readAt": "2024-01-15T10:35:00.000000Z"
}
```

### POST `/api/v1/alerts`

Create a price/event alert.

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "stock_symbol": "COMI",
  "alert_type": "price_above",
  "threshold_value": 70.0
}
```

**Response** (`201 Created`):
```json
{
  "id": 1,
  "stock": {
    "symbol": "COMI",
    "name": "البنك التجاري الدولي"
  },
  "alertType": "price_above",
  "thresholdValue": 70.0,
  "isActive": true
}
```

**Feature Gate Error** (`403 Forbidden`):
```json
{
  "message": "Alerts feature requires a Basic or Pro subscription.",
  "required_plan": "basic"
}
```

## Subscription Endpoints

### GET `/api/v1/subscription/status`

Get current subscription status and entitlements.

**Headers**: `Authorization: Bearer {token}`

**Response** (`200 OK`):
```json
{
  "plan": {
    "code": "pro",
    "name": "احترافي",
    "isActive": true
  },
  "entitlements": {
    "signals": true,
    "alerts": true,
    "watchlists": -1,
    "advancedAnalytics": true,
    "education": true,
    "paperPortfolio": true,
    "backtesting": true
  },
  "trial": {
    "isActive": true,
    "daysRemaining": 12,
    "endsAt": "2024-01-27T00:00:00.000000Z"
  },
  "subscription": {
    "status": "trial",
    "expiresAt": "2024-01-27T00:00:00.000000Z",
    "platform": "ios"
  }
}
```

**Free Plan Response**:
```json
{
  "plan": {
    "code": "free",
    "name": "مجاني",
    "isActive": true
  },
  "entitlements": {
    "signals": false,
    "alerts": false,
    "watchlists": 1,
    "advancedAnalytics": false,
    "education": false,
    "paperPortfolio": false,
    "backtesting": false
  },
  "trial": {
    "isActive": false,
    "daysRemaining": 0
  },
  "subscription": null
}
```

### GET `/api/v1/subscription/plans`

Get all available subscription plans.

**Response** (`200 OK`):
```json
{
  "data": [
    {
      "code": "free",
      "name": "مجاني",
      "description": "خطة مجانية محدودة",
      "priceMonthly": 0,
      "priceYearly": null,
      "trialDays": 0,
      "features": {
        "signals": false,
        "alerts": false,
        "watchlists": 1,
        "advancedAnalytics": false,
        "education": false,
        "paperPortfolio": false,
        "backtesting": false
      },
      "isActive": true
    },
    {
      "code": "basic",
      "name": "أساسي",
      "description": "إشارات كاملة وقوائم متابعة غير محدودة",
      "priceMonthly": 299,
      "priceYearly": 2990,
      "trialDays": 14,
      "features": {
        "signals": true,
        "alerts": true,
        "watchlists": -1,
        "advancedAnalytics": false,
        "education": true,
        "paperPortfolio": false,
        "backtesting": false
      },
      "isActive": true
    },
    {
      "code": "pro",
      "name": "احترافي",
      "description": "جميع المزايا المتقدمة",
      "priceMonthly": 599,
      "priceYearly": 5990,
      "trialDays": 14,
      "features": {
        "signals": true,
        "alerts": true,
        "watchlists": -1,
        "advancedAnalytics": true,
        "education": true,
        "paperPortfolio": true,
        "backtesting": true
      },
      "isActive": true
    }
  ]
}
```

### POST `/api/v1/subscription/verify/apple`

Verify Apple App Store receipt and activate subscription.

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "receipt": "base64-encoded-receipt-data",
  "product_id": "com.vista.basic.monthly",
  "transaction_id": "1000000123456789"
}
```

**Response** (`200 OK`):
```json
{
  "status": "valid",
  "plan": {
    "code": "basic",
    "name": "أساسي",
    "isActive": true
  },
  "entitlements": {
    "signals": true,
    "alerts": true,
    "watchlists": -1,
    "advancedAnalytics": false,
    "education": true,
    "paperPortfolio": false,
    "backtesting": false
  },
  "subscription": {
    "status": "trial",
    "expiresAt": "2024-01-29T00:00:00.000000Z",
    "trialEndsAt": "2024-01-29T00:00:00.000000Z"
  }
}
```

**Invalid Receipt** (`400 Bad Request`):
```json
{
  "message": "Invalid receipt or receipt already processed.",
  "status": "invalid"
}
```

### POST `/api/v1/subscription/verify/google`

Verify Google Play purchase and activate subscription.

**Headers**: `Authorization: Bearer {token}`

**Request**:
```json
{
  "purchase_token": "opaque-token-up-to-150-characters",
  "product_id": "com.vista.basic.monthly",
  "transaction_id": "GPA.1234-5678-9012-34567"
}
```

**Response**: Same format as Apple verification endpoint.

### POST `/api/v1/subscription/webhook/apple`

Webhook endpoint for Apple App Store Server-to-Server Notifications (called by Apple).

**Security**: Requires valid Apple signature verification.

**Note**: This endpoint is called by Apple, not by the mobile app. Implementation details in `SECURITY.md`.

### POST `/api/v1/subscription/webhook/google`

Webhook endpoint for Google Play real-time notifications (called by Google).

**Security**: Requires valid Google signature verification.

**Note**: This endpoint is called by Google, not by the mobile app.

## Error Responses

All error responses follow this format:

```json
{
  "message": "Human-readable error message in Arabic",
  "errors": {
    "field_name": ["Validation error messages"]
  }
}
```

### HTTP Status Codes

- `200 OK`: Success
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Authentication required or invalid token
- `403 Forbidden`: Authorization failed (feature gating, insufficient permissions)
- `404 Not Found`: Resource not found
- `422 Unprocessable Entity`: Validation errors
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

## Rate Limiting

- **Authenticated endpoints**: 60 requests per minute per user
- **Verification endpoints** (`/subscription/verify/*`): 10 requests per minute per user
- **Registration/Login**: 5 requests per minute per IP
- **Admin endpoints**: 120 requests per minute per admin

Rate limit headers included in responses:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1642248000
```

## Pagination

Paginated responses include `meta` object:

```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 10,
    "per_page": 20,
    "to": 20,
    "total": 200
  },
  "links": {
    "first": "http://api.vista.app/api/v1/stocks?page=1",
    "last": "http://api.vista.app/api/v1/stocks?page=10",
    "prev": null,
    "next": "http://api.vista.app/api/v1/stocks?page=2"
  }
}
```

## Language Support

- **API Keys**: Always English (e.g., `signalType`, `confidence`, `riskLevel`)
- **User-Facing Values**: Arabic text (e.g., `"name": "البنك التجاري الدولي"`)
- **Error Messages**: Arabic (user-facing) or English (developer-facing based on `Accept-Language` header)

## Versioning

API version is included in URL path (`/api/v1/`). Future breaking changes will use `/api/v2/`. Non-breaking additions (new optional fields) remain in `/api/v1/`.
