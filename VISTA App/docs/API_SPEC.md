# مواصفات واجهات برمجة التطبيقات (API) لتطبيق Vista

هذه الوثيقة مبنية على نماذج البيانات الظاهرة في تطبيق Flutter الحالي لضمان التوافق بدون أي كسر للواجهات. جميع القيم النصية المعروضة للمستخدم تكون عربية، بينما مفاتيح JSON تبقى إنجليزية ثابتة.

## ملاحظات عامة
- **اللغة الافتراضية**: العربية (RTL).
- **العملات**: `EGP` مع العرض النصي `ج.م` في واجهة التطبيق.
- **تنسيق التاريخ**: النصوص المعروضة للمستخدم تكون عربية (مثل: `منذ 5 دقائق`).
- **أنواع الإشارة**: `buy` | `sell` | `hold` (تعكس القيم المعروضة: شراء/بيع/احتفاظ).
- **مستوى المخاطرة**: `low` | `medium` | `high`.

## المصادقة
> التطبيق الحالي لا يحتوي على تكوين صريح لـ Base URL أو عميل API، لذا يتم تعريف المسارات لتتطابق مع المخطط المستهدف.

### POST `/api/v1/auth/register`
**Request**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "password_confirmation": "string"
}
```

**Response**
```json
{
  "token": "string",
  "user": {
    "id": "string",
    "name": "string",
    "email": "string"
  }
}
```

### POST `/api/v1/auth/login`
**Request**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response**
```json
{
  "token": "string",
  "user": {
    "id": "string",
    "name": "string",
    "email": "string"
  }
}
```

### GET `/api/v1/auth/me`
**Response**
```json
{
  "id": "string",
  "name": "string",
  "email": "string"
}
```

### POST `/api/v1/auth/logout`
**Response**
```json
{
  "message": "تم تسجيل الخروج بنجاح"
}
```

## ملخص السوق (شاشة اليوم)
### GET `/api/v1/market/summary`
**Response**
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

## إشارات اليوم
### GET `/api/v1/signals/today`
**Response**
```json
[
  {
    "id": "1",
    "stockName": "البنك التجاري الدولي",
    "stockSymbol": "COMI",
    "price": 68.5,
    "changePercent": 2.35,
    "signalType": "buy",
    "confidence": 85,
    "riskLevel": "low"
  }
]
```

## جميع الإشارات
### GET `/api/v1/signals/recent`
**Response**
```json
[
  {
    "id": "1",
    "stockName": "البنك التجاري الدولي",
    "stockSymbol": "COMI",
    "price": 68.5,
    "changePercent": 2.35,
    "signalType": "buy",
    "confidence": 85,
    "riskLevel": "low"
  }
]
```

## تفاصيل الإشارة
### GET `/api/v1/signals/{id}`
**Response**
```json
{
  "id": "1",
  "stockName": "البنك التجاري الدولي",
  "stockSymbol": "COMI",
  "price": 68.5,
  "changePercent": 2.35,
  "signalType": "buy",
  "confidence": 85,
  "riskLevel": "low",
  "targetPrice": 75.0,
  "stopLoss": 64.0,
  "reasons": [
    "زيادة في حجم التداول بنسبة 40% عن المتوسط",
    "اختراق مستوى مقاومة رئيسي عند 67.50",
    "مؤشرات فنية إيجابية (RSI, MACD)"
  ],
  "risks": [
    "تقلبات السوق العامة قد تؤثر على السعر",
    "نتائج الربع القادم قد تختلف عن التوقعات"
  ],
  "createdAt": "2024-01-15 10:30"
}
```

## الأسهم (استكشاف)
### GET `/api/v1/stocks`
**Response**
```json
[
  {
    "symbol": "COMI",
    "name": "البنك التجاري الدولي",
    "price": 68.5,
    "change": 2.35,
    "sector": "البنوك",
    "chart": [65.0, 66.0, 67.0, 68.0, 68.5]
  }
]
```

### GET `/api/v1/stocks/{symbol}`
**Response**
```json
{
  "name": "البنك التجاري الدولي",
  "symbol": "COMI",
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
  "chartData": [65.0, 66.0, 67.0, 68.0, 67.5, 68.2, 68.5]
}
```

### GET `/api/v1/stocks/{symbol}/candles?range=1m|3m|6m|1y`
**Response**
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

### GET `/api/v1/stocks/{symbol}/signals`
**Response**
```json
[
  {
    "id": "1",
    "stockName": "البنك التجاري الدولي",
    "stockSymbol": "COMI",
    "price": 68.5,
    "changePercent": 2.35,
    "signalType": "buy",
    "confidence": 85,
    "riskLevel": "low"
  }
]
```

## الصناديق
### GET `/api/v1/funds`
**Response**
```json
[
  {
    "id": "F1",
    "name": "صندوق بنك مصر",
    "nav": 125.5,
    "change": 1.2,
    "type": "أسهم"
  }
]
```

### GET `/api/v1/funds/{id}`
**Response**
```json
{
  "id": "F1",
  "name": "صندوق بنك مصر",
  "nav": 125.5,
  "change": 1.2,
  "type": "أسهم"
}
```

## قائمة المتابعة
### GET `/api/v1/watchlists`
**Response**
```json
{
  "favorites": [
    {
      "symbol": "COMI",
      "name": "البنك التجاري الدولي",
      "price": 68.5,
      "change": 2.35,
      "chart": [65.0, 66.0, 67.0, 68.0, 68.5]
    }
  ],
  "watchlists": [
    {
      "id": "1",
      "name": "البنوك",
      "stocks": [
        {
          "symbol": "COMI",
          "name": "البنك التجاري الدولي",
          "price": 68.5,
          "change": 2.35
        }
      ]
    }
  ]
}
```

### POST `/api/v1/watchlists`
**Request**
```json
{
  "name": "البنوك"
}
```

**Response**
```json
{
  "id": "1",
  "name": "البنوك",
  "stocks": []
}
```

### PUT `/api/v1/watchlists/{id}`
**Request**
```json
{
  "name": "العقارات"
}
```

**Response**
```json
{
  "id": "1",
  "name": "العقارات"
}
```

### DELETE `/api/v1/watchlists/{id}`
**Response**
```json
{
  "message": "تم حذف القائمة بنجاح"
}
```

### POST `/api/v1/watchlists/{id}/items`
**Request**
```json
{
  "symbol": "COMI"
}
```

**Response**
```json
{
  "id": "item_1",
  "symbol": "COMI"
}
```

### DELETE `/api/v1/watchlists/{id}/items/{itemId}`
**Response**
```json
{
  "message": "تم حذف السهم من القائمة"
}
```

## التنبيهات
### GET `/api/v1/alerts`
**Response**
```json
[
  {
    "id": "1",
    "type": "signal",
    "title": "إشارة شراء جديدة",
    "message": "إشارة شراء على سهم البنك التجاري الدولي (COMI)",
    "time": "منذ 5 دقائق",
    "isRead": false
  }
]
```

### PUT `/api/v1/alerts/{id}/read`
**Response**
```json
{
  "id": "1",
  "isRead": true
}
```

## الاشتراك وحالة المزايا
### GET `/api/v1/subscription/status`
**Response**
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
    "advancedAnalytics": true,
    "education": true,
    "paperPortfolio": true
  },
  "trial": {
    "isActive": true,
    "daysRemaining": 12
  }
}
```

### POST `/api/v1/subscription/verify/apple`
**Request**
```json
{
  "receipt": "string"
}
```

### POST `/api/v1/subscription/verify/google`
**Request**
```json
{
  "purchaseToken": "string"
}
```

**Response (التحقق)**
```json
{
  "status": "valid",
  "plan": {
    "code": "pro",
    "name": "احترافي",
    "isActive": true
  },
  "entitlements": {
    "signals": true,
    "alerts": true,
    "advancedAnalytics": true,
    "education": true,
    "paperPortfolio": true
  }
}
```

## ملحوظات التوافق
- حقول الإشارات والتفاصيل مطابقة للمفاتيح المستخدمة في الشاشات (`SignalCard` و`SignalDetailsScreen`).
- بيانات الأسهم والصناديق مطابقة للخرائط في `ExploreScreen` و`StockDetailsScreen`.
- تنبيهات المستخدم مطابقة لبنية `AlertsScreen`.
