# System Integration & Auto-Activation Guide

## ✅ نظام التحليلات الذكي - التكامل الكامل

### Pipeline العمل الكامل

```
1. جلب البيانات من API Provider
   ↓
2. حفظ البيانات في قاعدة البيانات
   ↓
3. التحقق من جودة البيانات
   ↓
4. حساب المؤشرات الفنية
   ↓
5. توليد الإشارات (AI Engine)
   ↓
6. إضافة التفسيرات
   ↓
7. إنشاء أحداث الإشعارات
```

### تشغيل Pipeline

```bash
# تشغيل التحليل لتاريخ اليوم
php artisan vista:analysis-run

# تشغيل التحليل لتاريخ محدد
php artisan vista:analysis-run --date=2024-01-15
```

### Scheduled Task (في Kernel.php)

```php
// يجب إضافة في app/Console/Kernel.php
$schedule->command('vista:analysis-run')
    ->dailyAt('18:00') // بعد إغلاق السوق
    ->timezone('Africa/Cairo');
```

## ✅ تفعيل الاشتراك التلقائي

### عند الدفع (Automatic Activation)

#### 1. Apple App Store (iOS)

**الطريقة 1: Mobile App Verification**
- المستخدم يدفع في التطبيق
- التطبيق يرسل `POST /api/v1/subscription/verify/apple`
- `SubscriptionService::verifyAppleReceipt()` يتم استدعاؤه
- ✅ **التفعيل التلقائي**: `updateEntitlements()` يتم استدعاؤه فوراً
- ✅ **إنشاء Invoice**: يتم إنشاء فاتورة تلقائياً
- ✅ **Status = 'active'**: حالة الاشتراك تصبح 'active'

**الطريقة 2: Webhook (Server-to-Server)**
- Apple يرسل webhook إلى `/api/v1/webhooks/apple`
- عند `INITIAL_BUY`: `handleSubscriptionActivation()` يتم استدعاؤه
- ✅ **التفعيل التلقائي**: `updateEntitlements()` يتم استدعاؤه فوراً
- ✅ **Status = 'active'**: حالة الاشتراك تصبح 'active'
- ✅ **إنشاء Invoice**: يتم إنشاء فاتورة تلقائياً

#### 2. Google Play (Android)

**الطريقة 1: Mobile App Verification**
- المستخدم يدفع في التطبيق
- التطبيق يرسل `POST /api/v1/subscription/verify/google`
- `SubscriptionService::verifyGooglePurchase()` يتم استدعاؤه
- ✅ **التفعيل التلقائي**: `updateEntitlements()` يتم استدعاؤه فوراً
- ✅ **إنشاء Invoice**: يتم إنشاء فاتورة تلقائياً
- ✅ **Status = 'active'**: حالة الاشتراك تصبح 'active'

**الطريقة 2: Webhook (Real-time Developer Notifications)**
- Google يرسل webhook إلى `/api/v1/webhooks/google`
- عند `SUBSCRIPTION_PURCHASED` (type=4): `handleGoogleSubscriptionPurchase()` يتم استدعاؤه
- ✅ **التفعيل التلقائي**: `updateEntitlements()` يتم استدعاؤه فوراً
- ✅ **Status = 'active'**: حالة الاشتراك تصبح 'active'
- ✅ **إنشاء Invoice**: يتم إنشاء فاتورة تلقائياً

### Flow التفعيل التلقائي

```
Payment Received (Apple/Google)
         ↓
Webhook or Mobile Verification
         ↓
SubscriptionService::verify*()
         ↓
Subscription::updateOrCreate([
    'status' => 'active',
    'started_at' => now(),
    'expires_at' => calculated_date,
])
         ↓
✅ AUTOMATIC: updateEntitlements()
   - Delete old entitlements
   - Create new entitlements from plan features
         ↓
✅ AUTOMATIC: createInvoice()
   - Create invoice with status 'paid'
         ↓
✅ Log activation event
```

### Entitlements Update

عند تفعيل الاشتراك، يتم تحديث `entitlements` تلقائياً:

```php
// في SubscriptionService::updateEntitlements()
foreach ($plan->features as $featureKey => $featureValue) {
    Entitlement::create([
        'user_id' => $user->id,
        'plan_code' => $plan->code,
        'feature_key' => $featureKey,
        'feature_value' => $featureValue,
        'expires_at' => null, // Permanent until subscription expires
    ]);
}
```

## 🔗 نقاط التكامل

### 1. Market Data Provider Service

```php
// في RunAnalysisPipeline
$providerService = app(MarketDataProviderService::class);
$allStocks = $providerService->fetchAllStocks(); // جلب من API Provider النشط
```

### 2. Signal Engine Service

```php
// في RunAnalysisPipeline
$signalEngine = app(SignalEngineService::class);
$signals = $signalEngine->generateForDate($date); // توليد الإشارات
```

### 3. Subscription Service

```php
// في Mobile App / Webhook
$subscriptionService = app(SubscriptionService::class);
$subscription = $subscriptionService->verifyAppleReceipt($user, $receipt, $productId, $transactionId);
// ✅ Entitlements updated automatically
```

### 4. Feature Gate Service

```php
// في API Controllers
$featureGate = app(FeatureGateService::class);
if (!$featureGate->canAccess($user, 'signals')) {
    return response()->json(['message' => 'ميزة غير متاحة في خطتك'], 403);
}
```

## 📋 Checklist للتكامل الكامل

### ✅ نظام التحليلات
- [x] MarketDataProviderService يتصل بـ API Provider
- [x] MarketDataIngestionService يحفظ البيانات
- [x] IndicatorService يحسب المؤشرات
- [x] SignalEngineService يولد الإشارات
- [x] ExplainabilityService يضيف التفسيرات
- [x] NotificationRulesService ينشئ الأحداث
- [x] RunAnalysisPipeline command يعمل بدون أخطاء

### ✅ نظام الاشتراكات
- [x] SubscriptionService::verifyAppleReceipt() يفعل تلقائياً
- [x] SubscriptionService::verifyGooglePurchase() يفعل تلقائياً
- [x] WebhookController::handleSubscriptionActivation() يفعل تلقائياً
- [x] updateEntitlements() يتم استدعاؤه تلقائياً
- [x] Invoice يتم إنشاؤه تلقائياً
- [x] Status يتم تحديثه إلى 'active' تلقائياً

### ✅ نظام الميزات (Feature Gates)
- [x] FeatureGateService يتحقق من entitlements
- [x] Controllers تستخدم FeatureGateService
- [x] Entitlements يتم تحديثها عند التفعيل

## 🚨 Troubleshooting

### إذا لم يتم تفعيل الاشتراك تلقائياً

1. **تحقق من Logs**:
```bash
tail -f storage/logs/laravel.log | grep "Subscription activated"
```

2. **تحقق من Webhook Signature**:
- تأكد من أن Apple/Google webhook signature صحيح
- في Development: يمكن تعطيل التحقق مؤقتاً

3. **تحقق من Entitlements**:
```php
$entitlements = Entitlement::where('user_id', $userId)->get();
// يجب أن تحتوي على features من الخطة
```

4. **تحقق من Subscription Status**:
```php
$subscription = Subscription::where('user_id', $userId)->latest()->first();
// يجب أن يكون status = 'active'
```

### إذا لم يعمل نظام التحليلات

1. **تحقق من API Provider**:
```bash
php artisan tinker
>>> $provider = \App\Models\ApiProvider::where('is_active', true)->first();
>>> $service = new \App\Services\MarketDataProviderService();
>>> $service->setProvider($provider->name);
>>> $data = $service->fetchAllStocks();
```

2. **تحقق من Command**:
```bash
php artisan vista:analysis-run --date=2024-01-15
# يجب أن يعمل بدون أخطاء
```

3. **تحقق من Logs**:
```bash
tail -f storage/logs/laravel.log | grep "Analysis pipeline"
```

## 📊 Monitoring

### تفعيل الاشتراكات
- Monitor webhook logs
- Track activation events in audit_logs
- Check invoice creation

### نظام التحليلات
- Monitor command execution (success/failure)
- Track signal generation counts
- Check data quality metrics

---

## ✅ النتيجة

**جميع الأنظمة متكاملة وتعمل تلقائياً:**

1. ✅ **نظام التحليلات الذكي** يعمل بدون أخطاء
2. ✅ **التفعيل التلقائي** يتم فور الدفع
3. ✅ **Entitlements** يتم تحديثها تلقائياً
4. ✅ **Invoices** يتم إنشاؤها تلقائياً
5. ✅ **Webhooks** تعمل بشكل صحيح

النظام جاهز للإنتاج! 🚀
