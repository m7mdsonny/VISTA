# Notification Rules - Vista Egyptian AI Market Analysis App

## Overview

Vista uses Firebase Cloud Messaging (FCM) for push notifications to iOS and Android devices. Notifications are event-driven, rule-based, and respect user preferences, anti-spam logic, quiet hours, and subscription entitlements.

## Notification Types

### 1. Signal Notifications (`signal_new`)

Triggered when a new signal is generated for a stock.

**Conditions**:
- User has active subscription with `signals` entitlement
- Stock is in user's watchlist OR user has alert preferences for this stock
- Signal confidence ≥ threshold (configurable, default: 70)
- User has not received notification for this signal already

**Content**:
```json
{
  "title_ar": "إشارة جديدة",
  "body_ar": "إشارة شراء على سهم البنك التجاري الدولي (COMI) - ثقة 85%",
  "data": {
    "type": "signal_new",
    "signal_id": 123,
    "stock_symbol": "COMI",
    "signal_type": "buy",
    "confidence": 85
  }
}
```

**Priority**: High (if confidence ≥ 85), Normal otherwise

### 2. Alert Notifications (`alert_triggered`)

Triggered when a user-defined alert condition is met.

**Conditions**:
- User has active subscription with `alerts` entitlement
- Alert condition matches (price above/below, volume spike, new signal)
- Alert is active (not already triggered or disabled)
- User has enabled alerts for this stock

**Content**:
```json
{
  "title_ar": "تم تفعيل التنبيه",
  "body_ar": "سعر COMI تجاوز 70.00 ج.م",
  "data": {
    "type": "alert_triggered",
    "alert_id": 456,
    "stock_symbol": "COMI",
    "alert_type": "price_above",
    "threshold_value": 70.0
  }
}
```

**Priority**: Normal

### 3. Subscription Notifications (`subscription_expiring`)

Triggered when subscription is expiring soon.

**Conditions**:
- Subscription expires in 3 days or 1 day (two notifications)
- User has not cancelled subscription
- User has not already received notification for this expiry window

**Content**:
```json
{
  "title_ar": "اشتراكك ينتهي قريباً",
  "body_ar": "سينتهي اشتراكك خلال 3 أيام. تجديد تلقائي مفعل.",
  "data": {
    "type": "subscription_expiring",
    "subscription_id": 789,
    "days_remaining": 3
  }
}
```

**Priority**: Low

### 4. Subscription Notifications (`subscription_expired`)

Triggered when subscription expires.

**Conditions**:
- Subscription status changes to `expired`
- User has active FCM token
- First expiry notification (not sent repeatedly)

**Content**:
```json
{
  "title_ar": "انتهى اشتراكك",
  "body_ar": "تم تعطيل المزايا المميزة. جدد اشتراكك للاستمرار.",
  "data": {
    "type": "subscription_expired",
    "subscription_id": 789
  }
}
```

**Priority**: Normal

### 5. Trial Notifications (`trial_expiring`)

Triggered when free trial is ending.

**Conditions**:
- Trial expires in 2 days or 1 day (two notifications)
- User is on trial (status = `trial`)
- User has not subscribed yet

**Content**:
```json
{
  "title_ar": "فترة التجربة تنتهي قريباً",
  "body_ar": "تبقى يومين على انتهاء فترة التجربة المجانية.",
  "data": {
    "type": "trial_expiring",
    "days_remaining": 2
  }
}
```

**Priority**: Low

### 6. News Notifications (`news_important`)

Triggered for important news affecting watched stocks.

**Conditions**:
- User has active subscription
- News item has `impact_score` ≥ 70
- News is related to stock in user's watchlist
- News sentiment is `positive` or `negative` (not `neutral`)

**Content**:
```json
{
  "title_ar": "أخبار مهمة",
  "body_ar": "أخبار جديدة عن البنك التجاري الدولي (COMI)",
  "data": {
    "type": "news_important",
    "news_id": 101,
    "stock_symbol": "COMI",
    "sentiment": "positive"
  }
}
```

**Priority**: Normal

## Anti-Spam Rules

### Rate Limiting

**Per-User Limits**:
- Maximum 5 notifications per hour (per user)
- Maximum 20 notifications per day (per user)
- Maximum 1 notification per type per stock per 24 hours (prevents duplicate signals)

**Implementation**:
```php
class NotificationRulesService {
    public function shouldSendNotification(User $user, string $notificationType, array $data): bool {
        // Check hourly limit
        $hourlyCount = NotificationEvent::where('user_id', $user->id)
            ->where('created_at', '>=', now()->subHour())
            ->count();
        
        if ($hourlyCount >= 5) {
            return false; // Rate limit exceeded
        }
        
        // Check daily limit
        $dailyCount = NotificationEvent::where('user_id', $user->id)
            ->where('created_at', '>=', now()->startOfDay())
            ->count();
        
        if ($dailyCount >= 20) {
            return false;
        }
        
        // Check duplicate prevention
        if ($this->isDuplicate($user, $notificationType, $data)) {
            return false;
        }
        
        return true;
    }
}
```

### Duplicate Prevention

**Signal Notifications**:
- Do not send if user already received notification for same signal_id in last 24 hours

**Alert Notifications**:
- Do not send if same alert was triggered in last 1 hour

**Subscription Notifications**:
- Do not send if same notification type was sent in last 24 hours

### Quiet Hours

**Default**: 10:00 PM - 8:00 AM (Egypt time, UTC+2)

**Configuration**: Stored in `admin_settings`:
- `notification.quiet_hours.start`: "22:00"
- `notification.quiet_hours.end`: "08:00"

**Behavior**:
- Low-priority notifications delayed until after quiet hours
- High-priority notifications (signal with confidence ≥ 85) sent immediately (user can opt-out)

**Implementation**:
```php
public function isQuietHours(): bool {
    $start = config('app.notification.quiet_hours.start', '22:00');
    $end = config('app.notification.quiet_hours.end', '08:00');
    
    $now = now()->setTimezone('Africa/Cairo')->format('H:i');
    
    if ($start > $end) {
        // Quiet hours span midnight
        return $now >= $start || $now < $end;
    } else {
        return $now >= $start && $now < $end;
    }
}

public function shouldDelayNotification(string $priority): bool {
    if ($priority === 'high') {
        return false; // High priority sends immediately
    }
    
    return $this->isQuietHours();
}
```

## Priority Levels

### High Priority

**Usage**:
- Signal notifications with confidence ≥ 85
- Critical system notifications (rare)

**Behavior**:
- Sent immediately (bypasses quiet hours unless user opted out)
- Sound + vibration (default)
- Appears as heads-up notification on Android

**FCM Payload**:
```json
{
  "priority": "high",
  "notification": {
    "title": "...",
    "body": "...",
    "sound": "default"
  },
  "data": {...}
}
```

### Normal Priority

**Usage**:
- Most notifications (signals, alerts, news)
- Default priority

**Behavior**:
- Respects quiet hours (delayed if in quiet hours)
- Sound + vibration (user preference)
- Normal notification display

**FCM Payload**:
```json
{
  "priority": "normal",
  "notification": {
    "title": "...",
    "body": "...",
    "sound": "default"
  },
  "data": {...}
}
```

### Low Priority

**Usage**:
- Subscription/trial reminders
- Marketing notifications (future)

**Behavior**:
- Always delayed during quiet hours
- Silent by default (user can enable sound)
- Less intrusive display

**FCM Payload**:
```json
{
  "priority": "normal",
  "notification": {
    "title": "...",
    "body": "...",
    "sound": null
  },
  "data": {...}
}
```

## User Preferences

### Notification Settings (Stored in User Profile)

**Per-Type Settings**:
- `notifications.signals.enabled`: Boolean (default: true)
- `notifications.alerts.enabled`: Boolean (default: true)
- `notifications.news.enabled`: Boolean (default: false)
- `notifications.subscription.enabled`: Boolean (default: true)

**Global Settings**:
- `notifications.enabled`: Boolean (master toggle, default: true)
- `notifications.quiet_hours_enabled`: Boolean (default: true)
- `notifications.sound_enabled`: Boolean (default: true)
- `notifications.vibration_enabled`: Boolean (default: true)

**Implementation**:
```php
// Check user preferences before sending
if (!$user->preferences['notifications']['signals']['enabled']) {
    return false; // User disabled signal notifications
}
```

## Event Flow

### 1. Event Generation

```php
// When new signal is generated
$signal = Signal::create([...]);

// Queue notification event
dispatch(new GenerateSignalNotificationsJob($signal));
```

### 2. Notification Rules Evaluation

```php
class GenerateSignalNotificationsJob implements ShouldQueue {
    public function handle(Signal $signal) {
        // Find eligible users (subscription + watchlist match)
        $users = $this->findEligibleUsers($signal);
        
        foreach ($users as $user) {
            // Check rules
            if ($this->notificationRules->shouldSendNotification($user, 'signal_new', [
                'signal_id' => $signal->id,
                'stock_symbol' => $signal->stock->symbol,
            ])) {
                // Create notification event
                NotificationEvent::create([
                    'user_id' => $user->id,
                    'notification_type' => 'signal_new',
                    'title_ar' => 'إشارة جديدة',
                    'body_ar' => "...",
                    'priority' => $this->calculatePriority($signal),
                    'data_payload' => [...],
                ]);
            }
        }
    }
}
```

### 3. FCM Dispatch

```php
class SendNotificationJob implements ShouldQueue {
    public function handle(NotificationEvent $event) {
        $user = $event->user;
        $device = $user->devices()->where('fcm_token', '!=', null)->first();
        
        if (!$device) {
            return; // No device token
        }
        
        // Check quiet hours
        if ($this->notificationRules->shouldDelayNotification($event->priority)) {
            // Schedule for later
            $this->release(3600); // Retry in 1 hour
            return;
        }
        
        // Send via FCM
        $response = Http::withHeaders([
            'Authorization' => 'key=' . env('FCM_SERVER_KEY'),
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $device->fcm_token,
            'notification' => [
                'title' => $event->title_ar,
                'body' => $event->body_ar,
                'sound' => $this->getSound($event->priority),
            ],
            'data' => $event->data_payload,
            'priority' => $event->priority,
        ]);
        
        if ($response->successful()) {
            $event->update([
                'is_sent' => true,
                'sent_at' => now(),
            ]);
        }
    }
}
```

## Notification Center (In-App)

### Display All Notifications

**Endpoint**: `GET /api/v1/alerts`

**Response**:
```json
{
  "data": [
    {
      "id": 1,
      "type": "signal",
      "title": "إشارة جديدة",
      "message": "...",
      "time": "منذ 5 دقائق",
      "isRead": false,
      "data": {
        "signal_id": 123,
        "stock_symbol": "COMI"
      }
    }
  ]
}
```

### Mark as Read

**Endpoint**: `PUT /api/v1/alerts/{id}/read`

**Implementation**:
```php
$notificationEvent->update([
    'is_read' => true,
    'read_at' => now(),
]);
```

### Deep Linking

**Data Payload Structure**:
```json
{
  "type": "signal_new",
  "signal_id": 123,
  "stock_symbol": "COMI",
  "deep_link": "/signals/123"
}
```

**Mobile App Handling**:
```dart
// On notification tap
if (data['type'] == 'signal_new') {
  final signalId = data['signal_id'];
  context.push('/signals/$signalId');
}
```

## Configuration (Admin Dashboard)

### Notification Settings

**Admin Can Configure**:
- Quiet hours (start/end time)
- Rate limits (notifications per hour/day)
- Priority thresholds (confidence level for high priority)
- Default notification preferences for new users

**Admin CANNOT**:
- Send manual notifications to specific users
- Override anti-spam rules for individual users
- Bypass quiet hours for bulk notifications

### Settings Keys (admin_settings table)

- `notification.quiet_hours.start`: "22:00"
- `notification.quiet_hours.end`: "08:00"
- `notification.rate_limit.hourly`: 5
- `notification.rate_limit.daily`: 20
- `notification.priority.threshold_confidence`: 85
- `notification.default.signals_enabled`: true
- `notification.default.alerts_enabled`: true

## Testing & Monitoring

### Notification Delivery Tracking

**Metrics**:
- Total notifications sent (per type)
- Delivery rate (successful FCM responses)
- Read rate (users opening notifications)
- Quiet hours delays count

**Logging**:
- All notification events logged to `notification_events` table
- Failed FCM sends logged with error details
- Rate limit hits logged for monitoring

### A/B Testing (Future)

- Test different notification copy
- Test quiet hours preferences
- Test priority thresholds

## Best Practices

1. **Respect User Preferences**: Always check user settings before sending
2. **Avoid Notification Fatigue**: Use rate limits and duplicate prevention
3. **Prioritize Quality**: Only send notifications for meaningful events
4. **Clear Calls-to-Action**: Notifications should lead to relevant in-app screens
5. **Timely Delivery**: Respect quiet hours, but don't delay high-priority notifications indefinitely
6. **Error Handling**: Gracefully handle FCM failures, retry logic, token invalidation
