# Security Documentation - Vista Egyptian AI Market Analysis App

## Threat Model

### Identified Threats

1. **Authentication Bypass**
   - Unauthorized access to user accounts
   - Token theft/replay attacks
   - Session hijacking

2. **Subscription Fraud**
   - Fake receipt generation
   - Receipt sharing across accounts
   - Subscription manipulation

3. **API Abuse**
   - Rate limiting bypass
   - Data scraping
   - DDoS attacks

4. **Data Manipulation**
   - Manual signal creation/editing (CRITICAL: Must be prevented)
   - Market data tampering
   - Configuration unauthorized changes

5. **Sensitive Data Exposure**
   - Payment information leaks
   - User PII exposure
   - API keys/secrets in codebase

6. **Webhook Impersonation**
   - Fake Apple/Google webhooks
   - Receipt verification bypass

## Security Architecture

### Authentication & Authorization

#### Laravel Sanctum (Token-Based)

**Implementation**:
- **Access Tokens**: Issued on login/register, stored in `personal_access_tokens` table
- **Token Format**: `{token_id}|{random_40_char_string}`
- **Token Storage**: Database (hashed)
- **Expiration**: Default 24 hours (configurable)

**Token Security**:
```php
// Token generation
$token = $user->createToken('mobile-app', ['*'])->plainTextToken;

// Token validation (automatic via Sanctum middleware)
Route::middleware('auth:sanctum')->group(function () {
    // Protected routes
});
```

**Best Practices**:
- Tokens stored securely on mobile (`flutter_secure_storage`)
- Token refresh mechanism (optional: implement refresh tokens)
- Token revocation on logout
- Token rotation on password change

#### RBAC (Role-Based Access Control)

**Roles**:
- `user`: Standard mobile app users
- `admin`: Admin dashboard access (configuration only)
- `super_admin`: Full admin access (includes user management)

**Authorization Checks**:
```php
// Admin middleware
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // Admin routes
});

// Policy for signal prevention
class SignalPolicy {
    public function create(User $user) {
        return false; // NO ONE can manually create signals
    }
    
    public function update(User $user, Signal $signal) {
        return false; // NO ONE can manually update signals
    }
}
```

### Rate Limiting

**Implementation**:
- Laravel's `throttle` middleware
- Redis-backed (if available), fallback to database

**Limits**:
```php
// api.php routes
Route::middleware(['throttle:60,1'])->group(function () {
    // 60 requests per minute for authenticated users
});

Route::post('/subscription/verify/{platform}', ...)
    ->middleware('throttle:10,1'); // 10 per minute for verification

Route::post('/auth/register', ...)
    ->middleware('throttle:5,1'); // 5 per minute per IP
```

**Rate Limit Headers**:
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1642248000
```

**Response** (`429 Too Many Requests`):
```json
{
  "message": "Too many requests. Please try again later.",
  "retry_after": 60
}
```

### Subscription Receipt Verification

#### Apple App Store Verification

**Backend Verification**:
```php
// Verify with Apple App Store Server API
$response = Http::post('https://buy.itunes.apple.com/verifyReceipt', [
    'receipt-data' => $receipt,
    'password' => env('APPLE_SHARED_SECRET'),
    'exclude-old-transactions' => true,
]);

// Verify production first, then sandbox if needed
if ($response->json()['status'] === 21007) {
    // Sandbox receipt, verify against sandbox
    $response = Http::post('https://sandbox.itunes.apple.com/verifyReceipt', [...]);
}
```

**Security Checks**:
1. **Receipt Signature**: Apple signs receipts cryptographically
2. **Transaction ID Uniqueness**: Prevent receipt reuse across accounts
3. **Bundle ID Validation**: Ensure receipt is for correct app
4. **Subscription Status**: Verify `auto_renew_status` and expiry

**Storage**:
- Receipt data encrypted at rest (Laravel encryption)
- Store `original_transaction_id` for tracking
- Store `latest_receipt_info` for subscription renewal

#### Google Play Billing Verification

**Backend Verification**:
```php
// Verify with Google Play Developer API
use Google\Client;
use Google\Service\AndroidPublisher;

$client = new Client();
$client->setAuthConfig(env('GOOGLE_SERVICE_ACCOUNT_JSON'));
$client->addScope('https://www.googleapis.com/auth/androidpublisher');

$service = new AndroidPublisher($client);
$purchase = $service->purchases_subscriptions->get(
    env('GOOGLE_PACKAGE_NAME'),
    $productId,
    $purchaseToken
);
```

**Security Checks**:
1. **Purchase Token Validation**: Google validates tokens
2. **Subscription Status**: Check `paymentState` (1 = payment received)
3. **Expiry Time**: Verify `expiryTimeMillis`
4. **Transaction ID Uniqueness**: Prevent token reuse

**Storage**:
- Purchase token stored (not sensitive, but still encrypted)
- Store `orderId` for tracking
- Store `purchaseTimeMillis` and `expiryTimeMillis`

#### Webhook Security

**Apple Webhook (Server-to-Server Notifications)**:
```php
// Verify Apple signature
$headerSignature = request()->header('X-Apple-Request-UUID');
$certificateUrl = request()->header('X-Apple-Certificate-URL');
$receiptData = request()->input('unified_receipt.latest_receipt_info');

// Validate signature (implement Apple's verification process)
if (!verifyAppleWebhookSignature($headerSignature, $certificateUrl, $receiptData)) {
    abort(401, 'Invalid webhook signature');
}
```

**Google Webhook (Real-time Developer Notifications)**:
```php
// Verify Google signature (Pub/Sub message signature)
$message = request()->input('message');
$signature = request()->header('X-Goog-Signature');

if (!verifyGooglePubSubSignature($message, $signature)) {
    abort(401, 'Invalid webhook signature');
}
```

**Webhook Rate Limiting**:
- Separate rate limit for webhooks (higher, e.g., 1000/min)
- IP allowlisting (optional: restrict to Apple/Google IP ranges)

### Data Protection

#### Encryption at Rest

**Database Encryption**:
- Sensitive fields encrypted using Laravel's `encrypted` cast:
```php
class Subscription extends Model {
    protected $casts = [
        'receipt_data' => 'encrypted',
        'platform_transaction_id' => 'encrypted',
    ];
}
```

**Key Management**:
- `APP_KEY` stored in `.env` (never in version control)
- Rotate keys periodically: `php artisan key:generate --force`

#### Encryption in Transit

**HTTPS**:
- TLS 1.2+ required for all API endpoints
- HSTS headers enabled:
```php
// public/index.php or middleware
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
```

**Certificate Pinning (Mobile)**:
- Implement SSL pinning for production API calls
- Fallback mechanism for certificate updates

#### PII Protection

**User Data**:
- Email addresses hashed for analytics (SHA-256)
- Phone numbers encrypted if stored
- Passwords hashed with bcrypt (Laravel default)

**Data Minimization**:
- Only collect necessary user data
- Delete unused user accounts after 1 year of inactivity
- GDPR-compliant data export/deletion

### Signal Integrity (CRITICAL)

#### Prevention of Manual Signal Manipulation

**Database Constraints**:
```php
// signals table migration
Schema::create('signals', function (Blueprint $table) {
    $table->id();
    $table->foreignId('stock_id')->constrained()->onDelete('cascade');
    $table->date('date');
    // ... other fields
    // No admin_id or manual_override fields
});
```

**Service Layer Protection**:
```php
class SignalEngineService {
    public function generateSignal(Stock $stock, Carbon $date): Signal {
        // ONLY reads from:
        // - candles_daily
        // - indicators_daily
        // - news_items (sentiment)
        // - admin_settings (weights/thresholds)
        
        // NEVER reads from:
        // - Admin UI inputs for specific stocks
        // - Manual recommendations
        
        $confidence = $this->calculateConfidence($stock, $date);
        $signalType = $this->determineSignalType($confidence);
        
        return Signal::create([
            'stock_id' => $stock->id,
            'date' => $date,
            'signal_type' => $signalType,
            'confidence' => $confidence,
            // ... other fields
        ]);
    }
}
```

**Policy Enforcement**:
```php
// SignalPolicy.php
class SignalPolicy {
    public function create(User $user) {
        // NO ONE can manually create signals
        return false;
    }
    
    public function update(User $user, Signal $signal) {
        // NO ONE can manually update signals
        return false;
    }
    
    public function delete(User $user, Signal $signal) {
        // Only system/admin can delete (for data cleanup)
        return $user->hasRole('super_admin');
    }
}
```

**Admin Dashboard Restrictions**:
```php
// Admin routes - NO signal creation/editing routes
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    // Config endpoints only
    Route::get('/settings', [AdminController::class, 'settings']);
    Route::put('/settings/{key}', [AdminController::class, 'updateSetting']);
    
    // NO signal endpoints:
    // Route::post('/signals', ...); // FORBIDDEN
    // Route::put('/signals/{id}', ...); // FORBIDDEN
});
```

### Audit Logging

**Comprehensive Logging**:
```php
// AuditLogService.php
class AuditLogService {
    public function log(string $action, $resourceType = null, $resourceId = null, array $oldValues = [], array $newValues = []) {
        AuditLog::create([
            'user_id' => auth()->id(),
            'action' => $action, // 'setting.updated', 'plan.created', 'signal.generated'
            'resource_type' => $resourceType,
            'resource_id' => $resourceId,
            'old_values' => $oldValues,
            'new_values' => $newValues,
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
        ]);
    }
}
```

**Logged Actions**:
- Admin setting changes
- Subscription plan modifications
- User management (create/update/delete)
- Signal generation (system events)
- Subscription verifications (failures only)
- Failed login attempts

**Log Retention**:
- Keep audit logs for 2 years
- Archive old logs to cold storage

### Input Validation & Sanitization

**Laravel Validation**:
```php
// Request validation
class StoreSubscriptionRequest extends FormRequest {
    public function rules() {
        return [
            'receipt' => ['required', 'string', 'max:10000'],
            'product_id' => ['required', 'string', 'in:com.vista.basic.monthly,com.vista.pro.monthly'],
            'transaction_id' => ['required', 'string', 'max:255'],
        ];
    }
}
```

**SQL Injection Prevention**:
- Laravel Eloquent ORM (parameterized queries)
- No raw SQL queries unless absolutely necessary

**XSS Prevention**:
- Blade templates auto-escape output: `{{ $variable }}`
- JSON responses: Automatic escaping
- Admin dashboard: Sanitize all user inputs

### API Security Headers

**Middleware**:
```php
// app/Http/Middleware/SecureHeaders.php
public function handle($request, Closure $next) {
    $response = $next($request);
    
    $response->headers->set('X-Content-Type-Options', 'nosniff');
    $response->headers->set('X-Frame-Options', 'DENY');
    $response->headers->set('X-XSS-Protection', '1; mode=block');
    $response->headers->set('Referrer-Policy', 'strict-origin-when-cross-origin');
    $response->headers->set('Permissions-Policy', 'geolocation=(), microphone=(), camera=()');
    
    return $response;
}
```

### CORS Configuration

**Allowed Origins**:
```php
// config/cors.php
'allowed_origins' => [
    env('MOBILE_APP_ORIGIN', '*'), // Restrict in production
],

'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
'max_age' => 86400,
```

**Production Settings**:
- Only allow specific mobile app origins
- No wildcard origins

### Environment Variables Security

**.env File Protection**:
- Never commit `.env` to version control (in `.gitignore`)
- Use `.env.example` with placeholder values
- Rotate secrets periodically

**Sensitive Variables**:
```env
APP_KEY=base64:...  # Laravel encryption key
DB_PASSWORD=...
REDIS_PASSWORD=...
APPLE_SHARED_SECRET=...
GOOGLE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
FCM_SERVER_KEY=...
```

**Secrets Management (Production)**:
- Use secret management service (AWS Secrets Manager, HashiCorp Vault)
- Or environment variables on server (not in code)

### Mobile App Security

#### Token Storage

**flutter_secure_storage**:
```dart
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);

await storage.write(key: 'auth_token', value: token);
```

#### Certificate Pinning

**Implementation**:
```dart
// dio_certificate_pinning
final dio = Dio();
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
  client.badCertificateCallback = (cert, host, port) {
    // Validate certificate fingerprint
    return cert.sha1.toString() == 'EXPECTED_FINGERPRINT';
  };
  return client;
};
```

#### Root/Jailbreak Detection

**Optional**: Detect rooted/jailbroken devices and warn users or restrict features.

### Security Monitoring

#### Failed Verification Tracking

```php
// Track failed receipt verifications
if (!$isValid) {
    Subscription::where('id', $subscription->id)
        ->increment('verification_failures');
    
    if ($subscription->verification_failures > 5) {
        // Alert admin
        Log::warning('Multiple verification failures', [
            'user_id' => $subscription->user_id,
            'subscription_id' => $subscription->id,
        ]);
    }
}
```

#### Error Logging

**Laravel Logging**:
- Log all errors to `storage/logs/laravel.log`
- Use external service (Sentry, Rollbar) for production error tracking
- Monitor for suspicious patterns (brute force, SQL injection attempts)

### Incident Response Plan

1. **Detection**: Monitor logs for anomalies
2. **Containment**: Disable affected accounts/services
3. **Investigation**: Review audit logs, identify attack vector
4. **Remediation**: Patch vulnerability, reset credentials
5. **Communication**: Notify affected users if PII compromised
6. **Documentation**: Document incident in security log

## Security Checklist

- [ ] All API endpoints use HTTPS (TLS 1.2+)
- [ ] Authentication tokens stored securely (flutter_secure_storage)
- [ ] Rate limiting enabled on all endpoints
- [ ] Receipt verification implemented for Apple & Google
- [ ] Webhook signatures verified
- [ ] No manual signal creation/editing routes
- [ ] Signal policies enforce automated-only generation
- [ ] Admin settings changes logged to audit_logs
- [ ] Sensitive data encrypted at rest
- [ ] PII protected (GDPR-compliant)
- [ ] SQL injection prevented (Eloquent ORM)
- [ ] XSS prevented (Blade auto-escaping)
- [ ] Security headers configured
- [ ] CORS restricted in production
- [ ] .env not in version control
- [ ] Audit logging for all admin actions
- [ ] Failed verification tracking
- [ ] Error logging/monitoring (Sentry/Rollbar)
