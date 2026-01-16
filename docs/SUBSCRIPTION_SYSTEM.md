# نظام الاشتراكات والعروض الترويجية - Vista Egyptian AI Market Analysis App

## 📦 نظرة عامة

نظام اشتراكات احترافي مع عروض ترويجية وخصومات، وإعدادات كاملة لـ API providers للبيانات الحقيقية.

## 🎁 نظام العروض الترويجية (Promotions System)

### الهيكل
- **Promotions Table**: جدول العروض الترويجية
- **User Promotions Table**: تتبع استخدام المستخدمين للعروض
- **Promotion Service**: خدمة لإدارة العروض

### أنواع العروض

#### 1. Percentage Discount (خصم نسبة مئوية)
```php
[
    'code' => 'SUMMER30',
    'type' => 'percentage',
    'discount_value' => 30, // 30% off
    'max_discount_amount' => 500, // Maximum 500 EGP discount (optional)
]
```

#### 2. Fixed Discount (خصم ثابت)
```php
[
    'code' => 'SAVE100',
    'type' => 'fixed',
    'discount_value' => 100, // 100 EGP off
]
```

#### 3. Free Trial Extension (تمديد التجربة المجانية)
```php
[
    'code' => 'TRIAL30',
    'type' => 'free_trial',
    'free_trial_days' => 30, // Extend trial to 30 days
]
```

### إعدادات العروض

- **Code**: كود العرض (unique)
- **Name**: اسم العرض (عربي/إنجليزي)
- **Type**: نوع العرض (percentage, fixed, free_trial)
- **Applies To**: جميع الخطط أو خطط محددة
- **Frequency**: مرة واحدة أو متكرر
- **Usage Limit**: الحد الأقصى لاستخدام العرض
- **Per User Limit**: الحد الأقصى لكل مستخدم
- **Starts At / Ends At**: تاريخ البداية والنهاية
- **Priority**: أولوية العرض (أعلى أولوية = يتم تطبيقه أولاً)

### API Endpoints

#### 1. Validate Promotion
```http
POST /api/v1/subscription/promotion/validate
Authorization: Bearer {token}

{
    "code": "SUMMER30",
    "plan_code": "pro",
    "is_yearly": true
}
```

**Response:**
```json
{
    "valid": true,
    "promotion": {
        "code": "SUMMER30",
        "name": "عرض الصيف - خصم 30%",
        "type": "percentage",
        "discount_value": 30
    },
    "pricing": {
        "original_price": 1200,
        "discount_amount": 360,
        "final_price": 840,
        "trial_days": 14,
        "promotion_applied": true
    }
}
```

#### 2. Get Plans with Promotions
```http
GET /api/v1/subscription/plans
```

**Response:**
```json
{
    "data": [
        {
            "code": "pro",
            "name": "Pro",
            "priceMonthly": 200,
            "priceYearly": 1200,
            "discountedPriceMonthly": 140,  // With 30% discount
            "discountedPriceYearly": 840,   // With 30% discount
            "promotion": {
                "code": "SUMMER30",
                "name": "عرض الصيف - خصم 30%"
            }
        }
    ],
    "promotions": [
        {
            "code": "SUMMER30",
            "name": "عرض الصيف - خصم 30%",
            "type": "percentage",
            "discount_value": 30
        }
    ]
}
```

## 🔧 نظام API Providers

### الهيكل
- **Api Providers Table**: مزودي بيانات الأسهم
- **Api Provider Logs**: تتبع جميع طلبات API
- **Market Data Provider Service**: خدمة لإدارة مزودي البيانات

### أنواع Providers

#### 1. EGX Official (بيانات البورصة الرسمية)
```php
[
    'name' => 'egx_official',
    'type' => 'egx_official',
    'base_url' => 'https://api.egx.com.eg',
    'auth_type' => 'api_key',
]
```

#### 2. Third-party (مزود بيانات خارجي)
```php
[
    'name' => 'market_data_provider',
    'type' => 'third_party',
    'base_url' => 'https://api.marketdata.example.com',
    'auth_type' => 'bearer',
]
```

#### 3. Scraper (Web Scraping)
```php
[
    'name' => 'scraper_provider',
    'type' => 'scraper',
    'base_url' => 'https://www.mubasher.info',
    'auth_type' => 'none',
]
```

### إعدادات Provider

- **Name**: اسم المزود (unique)
- **Display Name**: الاسم المعروض (عربي/إنجليزي)
- **Type**: نوع المزود (egx_official, third_party, custom, scraper)
- **Base URL**: رابط API الأساسي
- **API Key / Secret**: مفاتيح API (مشفرة)
- **Auth Type**: نوع المصادقة (none, api_key, bearer, basic, custom)
- **Headers**: رؤوس HTTP مخصصة
- **Endpoints**: إعدادات endpoints
- **Rate Limits**: حدود الاستخدام (دقيقة/يوم)
- **Timeout / Retry**: إعدادات الوقت والإعادة

### Endpoints Configuration

```json
{
    "daily_candles": "/api/v1/stocks/{symbol}/candles?date={date}",
    "all_stocks": "/api/v1/stocks",
    "funds": "/api/v1/funds"
}
```

### Rate Limiting

- **Per Minute**: عدد الطلبات في الدقيقة
- **Per Day**: عدد الطلبات في اليوم
- **Automatic Tracking**: تتبع تلقائي عبر Cache

### API Logging

جميع طلبات API يتم تسجيلها في `api_provider_logs`:
- Provider ID
- Endpoint
- Status (success, failed, rate_limited, timeout)
- Response Time (ms)
- HTTP Status Code
- Error Message (if any)
- Request/Response Data

## 🎛️ لوحة تحكم الأدمن

### إدارة العروض (Admin > Promotions)

#### Create Promotion
- نموذج كامل لإنشاء عرض ترويجي
- تحديد نوع العرض (percentage, fixed, free_trial)
- تحديد الخطط المطبقة (all أو specific)
- تحديد تواريخ البداية والنهاية
- تحديد حدود الاستخدام

#### Edit Promotion
- تعديل جميع إعدادات العرض
- تفعيل/تعطيل العرض
- عرض إحصائيات الاستخدام

#### List Promotions
- قائمة بجميع العروض
- فلترة حسب الحالة (active, upcoming, expired)
- عرض إحصائيات الاستخدام

### إدارة API Providers (Admin > API Providers)

#### Create Provider
- إضافة مزود API جديد
- تكوين Base URL
- إضافة API Key / Secret (مشفر)
- تحديد نوع المصادقة
- تكوين Endpoints
- تحديد Rate Limits

#### Edit Provider
- تعديل إعدادات المزود
- تحديث API Keys
- تفعيل/تعطيل المزود
- تعيين كمزود افتراضي

#### Test Provider
- اختبار الاتصال بـ API
- عرض النتيجة (success/failed)
- عرض Response Time

#### Provider Logs
- عرض جميع طلبات API
- فلترة حسب الحالة
- عرض Response Times
- عرض Error Messages

#### Statistics
- إجمالي الطلبات
- Success Rate (%)
- Average Response Time (ms)
- Requests Today

## 📊 Integration with Subscription Service

### Applying Promotion to Subscription

```php
// In SubscriptionService::createSubscription()
$promotion = Promotion::where('code', $promoCode)->first();

if ($promotion && $promotion->canBeUsedBy($user, $plan->code)['can_use']) {
    $pricing = $promotionService->applyPromotion($promotion, $plan, $isYearly);
    
    $subscription = Subscription::create([
        'user_id' => $user->id,
        'plan_id' => $plan->id,
        'promotion_id' => $promotion->id,
        'original_price' => $pricing['original_price'],
        'discount_amount' => $pricing['discount_amount'],
        'final_price' => $pricing['final_price'],
        // ... other fields
    ]);
    
    $promotionService->recordUsage($promotion, $user, $subscription, $pricing);
}
```

## 🔗 Integration with Market Data Service

### Using Provider in Market Data Service

```php
// In MarketDataIngestionService
$providerService = new MarketDataProviderService();
$providerService->setProvider('egx_official');

// Fetch daily candles
$candles = $providerService->fetchDailyCandles('COMI', now());

// Fetch all stocks
$stocks = $providerService->fetchAllStocks();
```

### Automatic Rate Limiting

```php
// Automatically checks rate limits before each request
if (!$providerService->checkRateLimit($provider)) {
    // Rate limit exceeded - log and skip
    return null;
}
```

### Automatic Logging

جميع طلبات API يتم تسجيلها تلقائياً:
- Request Time
- Response Time
- Status (success/failed)
- Error Messages

## 📝 Database Schema

### promotions
- id
- code (unique)
- name_ar, name_en
- type (percentage, fixed, free_trial)
- discount_value
- applies_to (all, specific_plans)
- applicable_plan_codes (JSON)
- usage_limit, per_user_limit
- starts_at, ends_at
- is_active, priority

### user_promotions
- id
- user_id
- promotion_id
- subscription_id
- discount_applied
- original_price, final_price
- used_at

### api_providers
- id
- name (unique)
- display_name_ar, display_name_en
- type (egx_official, third_party, custom, scraper)
- base_url
- api_key, api_secret (encrypted)
- headers, endpoints (JSON)
- auth_type
- rate_limit_per_minute, rate_limit_per_day
- is_active, is_default

### api_provider_logs
- id
- provider_id
- endpoint
- status (success, failed, rate_limited, timeout)
- response_time_ms
- http_status_code
- error_message
- request_data, response_data (JSON)
- requested_at

## 🚀 Seeders

### PromotionsSeeder
يضيف عروض ترويجية افتراضية:
- `NEWUSER50` - خصم 50% للمستخدمين الجدد
- `SUMMER30` - خصم 30% على جميع الخطط
- `TRIAL30` - تجربة مجانية 30 يوم
- `PRO25` - خصم 25% على خطة Pro
- `SAVE100` - خصم ثابت 100 جنيه

### ApiProvidersSeeder
يضيف مزودي API افتراضيين:
- `egx_official` - بيانات البورصة الرسمية
- `market_data_provider` - مزود بيانات خارجي
- `scraper_provider` - Web Scraping

## 📌 Usage Examples

### Create Promotion (Admin)
```php
Promotion::create([
    'code' => 'WINTER50',
    'name_ar' => 'خصم 50% في الشتاء',
    'type' => 'percentage',
    'discount_value' => 50,
    'applies_to' => 'all',
    'starts_at' => now(),
    'ends_at' => now()->addMonths(2),
    'is_active' => true,
]);
```

### Validate Promotion (API)
```php
$result = $promotionService->validateAndApply('WINTER50', $user, 'pro');
if ($result['valid']) {
    $pricing = $promotionService->applyPromotion($result['promotion'], $plan, true);
    // Use pricing['final_price']
}
```

### Add API Provider (Admin)
```php
ApiProvider::create([
    'name' => 'custom_provider',
    'display_name_ar' => 'مزود مخصص',
    'type' => 'third_party',
    'base_url' => 'https://api.example.com',
    'api_key' => 'your-api-key',
    'auth_type' => 'bearer',
    'endpoints' => [
        'daily_candles' => '/v1/candles/{symbol}',
        'all_stocks' => '/v1/stocks',
    ],
    'rate_limit_per_minute' => 60,
    'is_active' => true,
    'is_default' => true,
]);
```

### Use Provider (Service)
```php
$service = new MarketDataProviderService();
$service->setProvider('custom_provider');
$data = $service->fetchDailyCandles('COMI');
```

## 🔒 Security

- **API Keys**: مشفرة في قاعدة البيانات
- **Rate Limiting**: حماية من الإفراط في الاستخدام
- **Audit Logging**: تسجيل جميع إجراءات الأدمن
- **Input Validation**: التحقق من جميع المدخلات

## 📈 Monitoring

- **Promotion Usage**: تتبع استخدام العروض
- **API Performance**: Response Times, Success Rates
- **Error Tracking**: تتبع الأخطاء والـ timeouts
- **Rate Limit Monitoring**: مراقبة حدود الاستخدام

---

هذا النظام يوفر إدارة احترافية للاشتراكات والعروض، وإعدادات كاملة لـ API providers للبيانات الحقيقية.
