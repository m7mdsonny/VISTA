# Admin Panel Guide - Vista Egyptian AI Market Analysis App

## Overview

The Vista Admin Dashboard is a Laravel Blade-based interface for system administrators to configure the application, manage subscriptions, monitor data quality, and review audit logs. **CRITICALLY**, administrators cannot manually create, edit, or override signals for specific stocks—all signals are generated automatically by the Signal Engine.

## Access Control

### Authentication

**Login Route**: `/admin/login`

**Credentials**:
- Default admin user created via seeder (from `.env` variables)
- `ADMIN_DEFAULT_EMAIL`: Admin email address
- `ADMIN_DEFAULT_PASSWORD`: Admin password (change after first login)

**Session-Based**: Uses Laravel Sanctum session authentication (separate from API token auth)

### Authorization

**Roles**:
- `super_admin`: Full access (user management, all configuration)
- `admin`: Configuration access (no user management)

**Middleware**: `auth:sanctum`, `role:admin` on all admin routes

## Dashboard Sections

### 1. Dashboard Overview

**Route**: `/admin/dashboard`

**Metrics Displayed**:
- **Active Users**: Total users with active subscriptions
- **Trial Users**: Users currently in trial period
- **Signals Today**: Number of signals generated today
- **Data Health**: Percentage of stocks with quality data (last 7 days)
- **Revenue**: Monthly recurring revenue (MRR)
- **Churn Rate**: Subscription cancellation rate (last 30 days)

**Charts**:
- User growth (last 30 days)
- Signal generation trend (last 7 days)
- Subscription plan distribution (pie chart)
- Data quality score trend (line chart)

**Recent Activity**:
- Latest admin actions (last 10 from `audit_logs`)
- Failed receipt verifications (alerts)
- Low data quality alerts

### 2. Subscription Management

#### Plans Overview

**Route**: `/admin/subscriptions/plans`

**List View**:
- Plan code, name, price (monthly/yearly)
- Trial days, active status
- Features included (JSON display)
- Actions: Edit, Disable/Enable, View Subscriptions

**Actions**:
- **Create Plan**: Add new subscription plan
- **Edit Plan**: Update plan details (price, trial days, features)
- **Disable Plan**: Hide plan from mobile app (existing subscriptions remain active)
- **Enable Plan**: Show plan in mobile app

**Form Fields**:
- Plan code (unique identifier, e.g., `basic`, `pro`)
- Name (Arabic and English)
- Description (Arabic)
- Monthly price (EGP)
- Yearly price (EGP, optional)
- Trial days (default: 14)
- Features JSON (entitlements)
- Active status (checkbox)

**CRITICAL**: Cannot edit plan features for users with active subscriptions (prevents mid-subscription feature removal). Only future subscriptions are affected.

#### Plan Details

**Route**: `/admin/subscriptions/plans/{id}`

**Information Displayed**:
- Plan details (all fields)
- Active subscriptions count
- Revenue from this plan (monthly/yearly)
- Subscriptions list (paginated, read-only)

**Actions**:
- Edit plan (same restrictions as above)
- View all subscriptions for this plan

#### Subscriptions List

**Route**: `/admin/subscriptions`

**Filters**:
- Plan (dropdown)
- Status (`trial`, `active`, `expired`, `cancelled`)
- Platform (`ios`, `android`)
- Date range (created/expires)

**Columns**:
- User (name, email)
- Plan (code, name)
- Status (badge)
- Platform (icon)
- Started at (date)
- Expires at (date)
- Trial ends at (date)
- Last verified at (timestamp)
- Verification failures count

**Actions**:
- View subscription details (read-only)
- View user profile (link)

**CRITICAL**: Subscriptions are **READ-ONLY** in admin panel. Cannot manually activate/cancel subscriptions. Only payment provider webhooks can modify subscription status.

#### Subscription Details

**Route**: `/admin/subscriptions/{id}`

**Information Displayed**:
- User information
- Plan details
- Subscription timeline (started, expires, trial ends)
- Transaction ID (masked)
- Receipt verification history (timestamps, success/failure)
- Invoices (read-only list)

**Actions**:
- View invoices (read-only)
- View user profile (link)

#### Invoices

**Route**: `/admin/subscriptions/invoices`

**Filters**: Same as subscriptions list

**Columns**:
- Invoice number
- User (name, email)
- Plan (code)
- Amount (EGP)
- Status (paid, refunded, failed)
- Platform
- Paid at (date)
- Transaction ID (masked)

**Actions**:
- View invoice details (read-only)
- Export invoice (PDF) - future feature

**CRITICAL**: Invoices are **READ-ONLY**. Cannot manually create/edit invoices. Only generated when subscriptions are activated/renewed via payment providers.

### 3. Analysis Configuration

#### Indicator Weights

**Route**: `/admin/analysis/weights`

**Purpose**: Adjust weights for signal calculation algorithm (affects future signals only)

**Configuration Fields**:
- Volume weight (0.0 - 1.0, default: 0.25)
- Liquidity weight (0.0 - 1.0, default: 0.20)
- Trend alignment weight (0.0 - 1.0, default: 0.25)
- Mean reversion weight (0.0 - 1.0, default: 0.15)
- Volatility regime weight (0.0 - 1.0, default: 0.10)
- News impact weight (0.0 - 1.0, default: 0.05)

**Validation**: Sum of weights must equal 1.0 (100%)

**CRITICAL**: These weights affect **all future signals**. Cannot set weights for individual stocks. Cannot preview signals before generation.

**Storage**: `admin_settings` table:
- `indicator.volume.weight`
- `indicator.liquidity.weight`
- `indicator.trend.weight`
- `indicator.mean_reversion.weight`
- `indicator.volatility.weight`
- `indicator.news.weight`

#### Signal Thresholds

**Route**: `/admin/analysis/thresholds`

**Purpose**: Configure confidence thresholds for signal generation

**Configuration Fields**:
- Buy threshold (0-100, default: 70) - Minimum confidence for "buy" signal
- Sell threshold (0-100, default: 30) - Maximum confidence for "sell" signal
- High confidence threshold (0-100, default: 85) - Minimum for high-priority notifications

**CRITICAL**: These thresholds affect **all future signals**. Cannot set thresholds for individual stocks.

**Storage**: `admin_settings` table:
- `signal.buy_threshold`
- `signal.sell_threshold`
- `signal.high_confidence_threshold`

#### Risk Assessment Configuration

**Route**: `/admin/analysis/risk`

**Purpose**: Configure risk level calculation parameters

**Configuration Fields**:
- Low risk volatility range (0-100, default: 0-20)
- Medium risk volatility range (0-100, default: 20-50)
- High risk volatility range (0-100, default: 50-100)
- Liquidity minimum for low risk (volume threshold)

**Storage**: `admin_settings` table:
- `risk.volatility.low`
- `risk.volatility.medium`
- `risk.volatility.high`
- `risk.liquidity.minimum`

#### Liquidity Filters

**Route**: `/admin/analysis/liquidity`

**Purpose**: Configure minimum liquidity requirements for signal generation

**Configuration Fields**:
- Minimum average daily volume (number)
- Minimum volume ratio (current/average, default: 0.5)
- Excluded stocks (multi-select, stocks with insufficient liquidity)

**Storage**: `admin_settings` table:
- `liquidity.min_avg_volume`
- `liquidity.min_volume_ratio`
- `liquidity.excluded_stocks` (JSON array of stock IDs)

**CRITICAL**: Excluded stocks will not generate signals. Admin can only enable/disable stocks from receiving signals, **not manually create signals** for them.

### 4. Stocks & Funds Registry

#### Stocks List

**Route**: `/admin/stocks`

**Filters**:
- Sector (dropdown)
- Active status (all, active, inactive)
- Search (symbol or name)

**Columns**:
- Symbol
- Name (Arabic, English)
- Sector
- Category
- Active status (badge)
- Last signal date
- Data quality score (last 7 days average)

**Actions**:
- Edit stock (name, sector, category)
- Enable/Disable visibility (toggle active status)
- View stock details

**CRITICAL**: Enabling/disabling a stock only affects its **visibility** in mobile app. Cannot create/edit signals for this stock. Signals are generated automatically if stock is active and has data.

#### Stock Details

**Route**: `/admin/stocks/{id}`

**Information Displayed**:
- Stock details (symbol, name, sector, category)
- Active status
- Market cap, listing date
- Recent signals (last 10, read-only)
- Data quality history (chart)
- Last candle date
- Last indicator calculation date

**Actions**:
- Edit stock details
- Toggle active status
- View signals history (read-only list, paginated)

**CRITICAL**: Signals list is **READ-ONLY**. Cannot create/edit/delete signals. Cannot override signal confidence or type.

#### Funds List

**Route**: `/admin/funds`

**Similar structure to stocks list**:
- Filters (type, active status, search)
- Columns (code, name, type, active status)
- Actions (edit, enable/disable, view details)

**CRITICAL**: Same restrictions as stocks—cannot create/edit signals for funds.

### 5. Notifications Control

#### Notification Types Configuration

**Route**: `/admin/notifications/types`

**Purpose**: Enable/disable notification types globally

**Toggle Switches**:
- Signal notifications (default: enabled)
- Alert notifications (default: enabled)
- News notifications (default: disabled)
- Subscription notifications (default: enabled)
- Trial notifications (default: enabled)

**Storage**: `admin_settings` table:
- `notification.types.signals_enabled`
- `notification.types.alerts_enabled`
- `notification.types.news_enabled`
- `notification.types.subscription_enabled`
- `notification.types.trial_enabled`

#### Priority Rules

**Route**: `/admin/notifications/priority`

**Purpose**: Configure priority calculation rules

**Configuration Fields**:
- High priority confidence threshold (default: 85)
- Normal priority default
- Low priority default

**Storage**: `admin_settings` table`:
- `notification.priority.high_threshold`

#### Quiet Hours

**Route**: `/admin/notifications/quiet-hours`

**Purpose**: Set default quiet hours for all users

**Configuration Fields**:
- Start time (HH:mm, default: 22:00)
- End time (HH:mm, default: 08:00)
- Timezone (default: Africa/Cairo)

**Storage**: `admin_settings` table:
- `notification.quiet_hours.start`
- `notification.quiet_hours.end`
- `notification.quiet_hours.timezone`

**CRITICAL**: Users can override quiet hours in mobile app settings. This is the default.

#### Rate Limits

**Route**: `/admin/notifications/rate-limits`

**Purpose**: Configure anti-spam rate limits

**Configuration Fields**:
- Maximum notifications per hour (default: 5)
- Maximum notifications per day (default: 20)
- Duplicate prevention window (hours, default: 24)

**Storage**: `admin_settings` table:
- `notification.rate_limit.hourly`
- `notification.rate_limit.daily`
- `notification.rate_limit.duplicate_window`

**CRITICAL**: Rate limits apply globally. Cannot override for individual users.

### 6. App Configuration

#### Feature Flags

**Route**: `/admin/app/features`

**Purpose**: Enable/disable features globally

**Toggle Switches**:
- Paper portfolio (default: enabled)
- Backtesting (default: enabled)
- Education content (default: enabled)
- Advanced analytics (default: enabled)

**Storage**: `admin_settings` table:
- `app.features.paper_portfolio`
- `app.features.backtesting`
- `app.features.education`
- `app.features.advanced_analytics`

**CRITICAL**: Feature flags gate **access** to features. Subscriptions still control entitlements. If feature is disabled, no user (even Pro) can access it.

#### Maintenance Mode

**Route**: `/admin/app/maintenance`

**Purpose**: Enable maintenance mode for mobile app

**Configuration Fields**:
- Maintenance mode enabled (checkbox)
- Maintenance message (Arabic text)
- Estimated downtime (optional, datetime)

**Storage**: `admin_settings` table:
- `app.maintenance.enabled`
- `app.maintenance.message`
- `app.maintenance.estimated_end`

**API Response** (when enabled):
```json
{
  "maintenance": {
    "enabled": true,
    "message": "نقوم بإجراء صيانة على الخادم. سنعود قريباً.",
    "estimated_end": "2024-01-15T12:00:00Z"
  }
}
```

#### Legal Text

**Route**: `/admin/app/legal`

**Purpose**: Manage legal disclaimers and terms

**Text Editors**:
- Terms of Service (Arabic, Markdown)
- Privacy Policy (Arabic, Markdown)
- Disclaimer (Arabic, Markdown) - Shown on signal cards

**Storage**: `admin_settings` table:
- `app.legal.terms`
- `app.legal.privacy`
- `app.legal.disclaimer`

#### Banners

**Route**: `/admin/app/banners`

**Purpose**: Display promotional/informational banners in mobile app

**Banner Configuration**:
- Title (Arabic)
- Message (Arabic)
- Link URL (optional)
- Active status (checkbox)
- Start date (datetime)
- End date (datetime)
- Priority (1-10, higher = shown first)

**Storage**: `banners` table (future migration)

**CRITICAL**: Banners cannot promote specific stocks or signal "buy/sell" actions. Only general app features, subscriptions, or legal updates.

### 7. Data Quality Monitoring

#### Data Quality Dashboard

**Route**: `/admin/data-quality`

**Metrics**:
- Overall data quality score (last 7 days average)
- Stocks with low quality data (score < 70)
- Missing data days (gaps in candles_daily)
- Outlier detection alerts

**Charts**:
- Data quality trend (last 30 days)
- Quality score distribution (histogram)
- Stocks with quality issues (table)

**Actions**:
- View stock quality details
- Manually trigger data re-ingestion (future feature)

#### Quality Checks List

**Route**: `/admin/data-quality/checks`

**Filters**:
- Stock (dropdown)
- Date range
- Quality score threshold (slider)

**Columns**:
- Stock (symbol, name)
- Date
- Quality score (badge, color-coded)
- Completeness score
- Outlier score
- Validation errors (JSON display)
- Accepted status (yes/no)

**Actions**:
- View check details (JSON display)

**CRITICAL**: Quality checks are **READ-ONLY**. Cannot manually accept/reject data. Only `DataValidationService` can accept/reject data based on quality score.

### 8. Security & Logs

#### Audit Logs

**Route**: `/admin/security/audit-logs`

**Filters**:
- User (admin user, dropdown)
- Action (typeahead search)
- Resource type (dropdown)
- Date range

**Columns**:
- Timestamp
- User (name, email)
- Action (badge)
- Resource (type, ID)
- IP address
- Old values (JSON display, expandable)
- New values (JSON display, expandable)

**Actions**:
- View log details (full JSON)
- Export logs (CSV, future feature)

**CRITICAL**: Audit logs are **READ-ONLY**. Cannot delete or modify logs.

#### Failed Verifications

**Route**: `/admin/security/failed-verifications`

**Purpose**: Monitor suspicious receipt verification failures

**Filters**:
- Platform (iOS, Android)
- User (dropdown)
- Date range

**Columns**:
- User (name, email)
- Platform
- Subscription ID
- Verification failures count
- Last failed at (timestamp)
- Transaction ID (masked)

**Actions**:
- View subscription details
- View user profile

**Alerts**: Display warning badge if verification failures > 5

#### Admin Action History

**Route**: `/admin/security/admin-actions`

**Purpose**: Review all admin configuration changes

**Same structure as audit logs**, filtered to admin actions:
- `setting.updated`
- `plan.created`
- `plan.updated`
- `stock.enabled`
- `stock.disabled`
- etc.

## CRITICAL RESTRICTIONS

### What Admin CANNOT Do

1. **Cannot Create Signals**: No route, no button, no way to manually create signals for any stock
2. **Cannot Edit Signals**: Signal confidence, type, or risk level cannot be manually modified
3. **Cannot Override Signal Results**: Cannot force a "buy" signal for a stock that algorithm calculated as "hold"
4. **Cannot Set Stock-Specific Weights**: Indicator weights apply globally, not per stock
5. **Cannot Assign Manual Recommendations**: No UI element or API endpoint for manual recommendations
6. **Cannot Modify Signal Explanations**: Explanations are auto-generated, cannot be edited
7. **Cannot Activate/Cancel Subscriptions Manually**: Only payment provider webhooks can modify subscriptions

### What Admin CAN Do

1. **Configure Algorithm Parameters**: Adjust weights, thresholds, risk sensitivity (affects future signals)
2. **Enable/Disable Stocks**: Control visibility, not signal generation for specific stocks
3. **Manage Subscription Plans**: Create/edit plans, adjust prices, trial duration
4. **Configure Notifications**: Set quiet hours, rate limits, priority rules
5. **Feature Flags**: Enable/disable app features globally
6. **Monitor Data Quality**: View quality scores, detect issues
7. **Review Audit Logs**: Track all admin actions and system events

## UI/UX Guidelines

### Design System

**Framework**: Laravel Blade + Tailwind CSS

**Color Palette**:
- Primary: Blue (`#0066CC`)
- Success: Green (`#10B981`)
- Warning: Amber (`#F59E0B`)
- Danger: Red (`#EF4444`)
- Neutral: Gray scale

**Components**:
- Tables: Responsive, sortable, paginated
- Forms: Validation, error messages
- Modals: Confirmation dialogs for destructive actions
- Alerts: Success, warning, error notifications

### Navigation

**Sidebar Navigation**:
- Dashboard
- Subscriptions
  - Plans
  - Subscriptions
  - Invoices
- Analysis Configuration
  - Weights
  - Thresholds
  - Risk
  - Liquidity
- Stocks & Funds
  - Stocks
  - Funds
- Notifications
  - Types
  - Priority
  - Quiet Hours
  - Rate Limits
- App Configuration
  - Features
  - Maintenance
  - Legal
  - Banners
- Data Quality
  - Dashboard
  - Checks
- Security & Logs
  - Audit Logs
  - Failed Verifications
  - Admin Actions

## Implementation Notes

### Routes Structure

```php
// routes/web.php
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'index']);
    
    Route::prefix('subscriptions')->group(function () {
        Route::resource('plans', SubscriptionPlanController::class);
        Route::get('/subscriptions', [SubscriptionController::class, 'index']);
        Route::get('/subscriptions/{id}', [SubscriptionController::class, 'show']);
        Route::get('/invoices', [InvoiceController::class, 'index']);
    });
    
    Route::prefix('analysis')->group(function () {
        Route::get('/weights', [AnalysisConfigController::class, 'weights']);
        Route::put('/weights', [AnalysisConfigController::class, 'updateWeights']);
        // ... other analysis routes
    });
    
    // ... other route groups
});
```

### Policies & Authorization

```php
// Policies prevent manual signal manipulation
class SignalPolicy {
    public function create(User $user) {
        return false; // NO ONE can create signals
    }
}

// Admin middleware checks
Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // Admin routes
});
```

### Audit Logging

```php
// Log all admin actions
AuditLogService::log('setting.updated', 'AdminSetting', $setting->id, $oldValues, $newValues);
```
