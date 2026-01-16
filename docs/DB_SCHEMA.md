# Database Schema - Vista Egyptian AI Market Analysis App

## Overview

MySQL database schema for Vista application. All tables use `id` as primary key (BIGINT UNSIGNED, AUTO_INCREMENT). Timestamps (`created_at`, `updated_at`) are managed by Laravel Eloquent.

## Core Principles

- **Referential Integrity**: Foreign keys with appropriate CASCADE/SET NULL actions
- **Indexes**: Optimized for common query patterns (lookups by date, user_id, stock_id)
- **Audit Trail**: `audit_logs` table tracks all administrative actions
- **Soft Deletes**: Used sparingly (only for user-facing deletions like watchlists)

## Tables

### users

Stores user accounts (mobile app users).

```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NULL,
    language VARCHAR(10) DEFAULT 'ar',
    theme VARCHAR(10) DEFAULT 'light', -- 'light' | 'dark' | 'system'
    fcm_token VARCHAR(255) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_email (email)
) ENGINE=InnoDB;
```

### roles

RBAC roles for authorization.

```sql
CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL, -- 'super_admin' | 'admin' | 'user'
    display_name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
) ENGINE=InnoDB;
```

### user_roles

Many-to-many relationship between users and roles.

```sql
CREATE TABLE user_roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_role (user_id, role_id),
    INDEX idx_user_id (user_id),
    INDEX idx_role_id (role_id)
) ENGINE=InnoDB;
```

### devices

Stores registered FCM devices for push notifications.

```sql
CREATE TABLE devices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    platform VARCHAR(20) NOT NULL, -- 'ios' | 'android'
    fcm_token VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) NULL,
    app_version VARCHAR(20) NULL,
    last_active_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_fcm_token (fcm_token)
) ENGINE=InnoDB;
```

### stocks

Registry of Egyptian Exchange (EGX) stocks.

```sql
CREATE TABLE stocks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(20) UNIQUE NOT NULL, -- 'COMI', 'ORAS', etc.
    name_ar VARCHAR(255) NOT NULL, -- Arabic name
    name_en VARCHAR(255) NULL, -- English name (optional)
    sector VARCHAR(100) NULL, -- 'البنوك', 'العقارات', etc.
    category VARCHAR(50) NULL, -- For admin categorization
    is_active BOOLEAN DEFAULT TRUE, -- Admin can enable/disable visibility
    market_cap BIGINT UNSIGNED NULL, -- Market capitalization (EGP)
    listed_date DATE NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_symbol (symbol),
    INDEX idx_is_active (is_active),
    INDEX idx_sector (sector)
) ENGINE=InnoDB;
```

### funds

Registry of mutual funds.

```sql
CREATE TABLE funds (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NULL,
    type VARCHAR(50) NULL, -- 'أسهم', 'سندات', etc.
    management_company VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_code (code),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB;
```

### candles_daily

Daily OHLCV (Open, High, Low, Close, Volume) candle data.

```sql
CREATE TABLE candles_daily (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stock_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    open DECIMAL(12, 4) NOT NULL,
    high DECIMAL(12, 4) NOT NULL,
    low DECIMAL(12, 4) NOT NULL,
    close DECIMAL(12, 4) NOT NULL,
    volume BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
    UNIQUE KEY unique_stock_date (stock_id, date),
    INDEX idx_date (date),
    INDEX idx_stock_date (stock_id, date)
) ENGINE=InnoDB;
```

### indicators_daily

Technical indicators calculated from candles.

```sql
CREATE TABLE indicators_daily (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stock_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    rsi_14 DECIMAL(8, 4) NULL, -- RSI (14-day period)
    ma_20 DECIMAL(12, 4) NULL, -- Moving Average 20-day
    ma_50 DECIMAL(12, 4) NULL,
    ma_200 DECIMAL(12, 4) NULL,
    macd DECIMAL(12, 4) NULL,
    macd_signal DECIMAL(12, 4) NULL,
    macd_histogram DECIMAL(12, 4) NULL,
    bb_upper DECIMAL(12, 4) NULL, -- Bollinger Band Upper
    bb_middle DECIMAL(12, 4) NULL,
    bb_lower DECIMAL(12, 4) NULL,
    volume_avg_20 DECIMAL(18, 4) NULL, -- Average volume (20-day)
    volume_ratio DECIMAL(8, 4) NULL, -- Current volume / Average volume
    atr_14 DECIMAL(12, 4) NULL, -- Average True Range (14-day)
    volatility DECIMAL(8, 4) NULL, -- Calculated volatility metric
    liquidity_score DECIMAL(8, 4) NULL, -- 0-100 liquidity score
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
    UNIQUE KEY unique_stock_date (stock_id, date),
    INDEX idx_date (date),
    INDEX idx_stock_date (stock_id, date)
) ENGINE=InnoDB;
```

### signals

Automatically generated signals (BUY/SELL/HOLD).

```sql
CREATE TABLE signals (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stock_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    signal_type ENUM('buy', 'sell', 'hold') NOT NULL,
    confidence TINYINT UNSIGNED NOT NULL, -- 0-100
    risk_level ENUM('low', 'medium', 'high') NOT NULL,
    price_at_signal DECIMAL(12, 4) NOT NULL, -- Price when signal was generated
    target_price DECIMAL(12, 4) NULL, -- Calculated target (optional)
    stop_loss DECIMAL(12, 4) NULL, -- Calculated stop loss (optional)
    calculation_metadata JSON NULL, -- Algorithm inputs for reproducibility
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
    INDEX idx_stock_date (stock_id, date),
    INDEX idx_date (date),
    INDEX idx_signal_type (signal_type),
    INDEX idx_confidence (confidence)
) ENGINE=InnoDB;
```

**Note**: `calculation_metadata` stores the inputs used (weights, thresholds) for audit/reproducibility. Admin CANNOT modify this.

### signal_explanations

Human-readable explanations for signals (Arabic text).

```sql
CREATE TABLE signal_explanations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    signal_id BIGINT UNSIGNED NOT NULL,
    why_reasons JSON NOT NULL, -- Array of 3 Arabic strings
    caveats JSON NOT NULL, -- Array of 2 Arabic strings
    technical_summary TEXT NULL, -- Optional technical details
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (signal_id) REFERENCES signals(id) ON DELETE CASCADE,
    UNIQUE KEY unique_signal (signal_id)
) ENGINE=InnoDB;
```

**Example JSON**:
```json
{
  "why_reasons": [
    "زيادة في حجم التداول بنسبة 40% عن المتوسط",
    "اختراق مستوى مقاومة رئيسي عند 67.50",
    "مؤشرات فنية إيجابية (RSI, MACD)"
  ],
  "caveats": [
    "تقلبات السوق العامة قد تؤثر على السعر",
    "نتائج الربع القادم قد تختلف عن التوقعات"
  ]
}
```

### data_quality_checks

Tracks data quality scores for ingestion validation.

```sql
CREATE TABLE data_quality_checks (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stock_id BIGINT UNSIGNED NOT NULL,
    date DATE NOT NULL,
    quality_score TINYINT UNSIGNED NOT NULL, -- 0-100
    completeness_score TINYINT UNSIGNED NOT NULL, -- 0-100
    outlier_score TINYINT UNSIGNED NOT NULL, -- 0-100
    validation_errors JSON NULL, -- Array of error messages
    is_accepted BOOLEAN DEFAULT FALSE, -- Was data accepted into candles_daily?
    checked_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
    INDEX idx_stock_date (stock_id, date),
    INDEX idx_quality_score (quality_score),
    INDEX idx_is_accepted (is_accepted)
) ENGINE=InnoDB;
```

### news_items

News articles/sentiment affecting stocks.

```sql
CREATE TABLE news_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stock_id BIGINT UNSIGNED NULL, -- NULL if market-wide news
    title_ar VARCHAR(500) NOT NULL,
    content_ar TEXT NULL,
    url VARCHAR(500) NULL,
    sentiment ENUM('positive', 'neutral', 'negative') NULL,
    impact_score TINYINT UNSIGNED NULL, -- 0-100
    published_at TIMESTAMP NOT NULL,
    source VARCHAR(255) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE SET NULL,
    INDEX idx_stock_id (stock_id),
    INDEX idx_published_at (published_at),
    INDEX idx_sentiment (sentiment)
) ENGINE=InnoDB;
```

### watchlists

User-created watchlists.

```sql
CREATE TABLE watchlists (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE, -- Default watchlist (favorites)
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    deleted_at TIMESTAMP NULL, -- Soft delete
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_deleted_at (deleted_at)
) ENGINE=InnoDB;
```

### watchlist_items

Items (stocks/funds) in watchlists.

```sql
CREATE TABLE watchlist_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    watchlist_id BIGINT UNSIGNED NOT NULL,
    stock_id BIGINT UNSIGNED NULL,
    fund_id BIGINT UNSIGNED NULL,
    type ENUM('stock', 'fund') NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (watchlist_id) REFERENCES watchlists(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
    FOREIGN KEY (fund_id) REFERENCES funds(id) ON DELETE CASCADE,
    UNIQUE KEY unique_watchlist_item (watchlist_id, stock_id, fund_id, type),
    INDEX idx_watchlist_id (watchlist_id),
    CHECK ((stock_id IS NOT NULL AND fund_id IS NULL AND type = 'stock') OR 
           (stock_id IS NULL AND fund_id IS NOT NULL AND type = 'fund'))
) ENGINE=InnoDB;
```

### alerts

User-defined price/event alerts.

```sql
CREATE TABLE alerts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    stock_id BIGINT UNSIGNED NOT NULL,
    alert_type ENUM('price_above', 'price_below', 'signal_new', 'volume_spike') NOT NULL,
    threshold_value DECIMAL(12, 4) NULL, -- For price alerts
    is_active BOOLEAN DEFAULT TRUE,
    triggered_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (stock_id) REFERENCES stocks(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_stock_id (stock_id),
    INDEX idx_is_active (is_active),
    INDEX idx_triggered_at (triggered_at)
) ENGINE=InnoDB;
```

### notification_events

Event log for notifications (before FCM dispatch).

```sql
CREATE TABLE notification_events (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    device_id BIGINT UNSIGNED NULL,
    notification_type VARCHAR(50) NOT NULL, -- 'signal_new', 'alert_triggered', 'subscription_expiring', etc.
    title_ar VARCHAR(255) NOT NULL,
    body_ar TEXT NOT NULL,
    data_payload JSON NULL, -- Additional data for deep linking
    priority ENUM('low', 'normal', 'high') DEFAULT 'normal',
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_is_sent (is_sent),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
```

### subscription_plans

Subscription plan definitions.

```sql
CREATE TABLE subscription_plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL, -- 'free', 'basic', 'pro'
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NULL,
    description_ar TEXT NULL,
    price_monthly DECIMAL(10, 2) NOT NULL, -- EGP
    price_yearly DECIMAL(10, 2) NULL, -- EGP (if yearly plan exists)
    trial_days TINYINT UNSIGNED DEFAULT 14,
    features JSON NOT NULL, -- Entitlements available in this plan
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    INDEX idx_code (code),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB;
```

**Example features JSON**:
```json
{
  "signals": true,
  "alerts": true,
  "watchlists": 5,
  "advancedAnalytics": false,
  "education": true,
  "paperPortfolio": false,
  "backtesting": false
}
```

### subscriptions

Active user subscriptions.

```sql
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    plan_id BIGINT UNSIGNED NOT NULL,
    platform ENUM('ios', 'android') NOT NULL,
    platform_transaction_id VARCHAR(255) NOT NULL, -- Apple/Google transaction ID
    receipt_data TEXT NULL, -- Full receipt (encrypted at rest)
    status ENUM('trial', 'active', 'expired', 'cancelled', 'pending') NOT NULL,
    started_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NULL, -- NULL for active subscriptions
    cancelled_at TIMESTAMP NULL,
    trial_ends_at TIMESTAMP NULL,
    last_verified_at TIMESTAMP NULL,
    verification_failures INT DEFAULT 0,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(id) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at),
    INDEX idx_platform_transaction_id (platform_transaction_id)
) ENGINE=InnoDB;
```

### entitlements

Denormalized table for fast feature gating checks.

```sql
CREATE TABLE entitlements (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    feature_key VARCHAR(100) NOT NULL, -- 'signals', 'alerts', etc.
    feature_value VARCHAR(255) NOT NULL, -- 'true', 'false', or numeric value (e.g., '5' for watchlists)
    expires_at TIMESTAMP NULL, -- NULL for permanent entitlements
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_feature (user_id, feature_key),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB;
```

**Note**: This table is updated automatically when subscriptions change. Provides fast lookup without joining multiple tables.

### invoices

Billing history (read-only after creation).

```sql
CREATE TABLE invoices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    subscription_id BIGINT UNSIGNED NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'EGP',
    platform ENUM('ios', 'android') NOT NULL,
    platform_transaction_id VARCHAR(255) NOT NULL,
    status ENUM('pending', 'paid', 'refunded', 'failed') NOT NULL,
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_status (status)
) ENGINE=InnoDB;
```

### admin_settings

Configuration settings (weights, thresholds, feature flags).

```sql
CREATE TABLE admin_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL, -- 'indicator.volume.weight', 'signal.buy_threshold', etc.
    value JSON NOT NULL,
    description_ar TEXT NULL,
    category VARCHAR(50) NOT NULL, -- 'indicators', 'signals', 'notifications', 'app'
    updated_by BIGINT UNSIGNED NULL, -- Admin user ID
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_key (key),
    INDEX idx_category (category)
) ENGINE=InnoDB;
```

**Example rows**:
- `indicator.volume.weight`: `0.25`
- `signal.buy_threshold`: `70`
- `signal.sell_threshold`: `30`
- `notification.quiet_hours.start`: `"22:00"`
- `notification.quiet_hours.end`: `"08:00"`
- `app.trial_days`: `14`

### audit_logs

Comprehensive audit trail for all admin actions and system events.

```sql
CREATE TABLE audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL, -- NULL for system-generated logs
    action VARCHAR(100) NOT NULL, -- 'plan.created', 'setting.updated', 'signal.generated', etc.
    resource_type VARCHAR(50) NULL, -- 'SubscriptionPlan', 'AdminSetting', 'Signal'
    resource_id BIGINT UNSIGNED NULL,
    old_values JSON NULL, -- Previous state (for updates)
    new_values JSON NULL, -- New state
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    metadata JSON NULL, -- Additional context
    created_at TIMESTAMP NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_resource (resource_type, resource_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;
```

## Indexes Summary

### Critical Performance Indexes

1. **candles_daily**: `(stock_id, date)` - Most common lookup pattern
2. **indicators_daily**: `(stock_id, date)` - Indicator queries
3. **signals**: `(stock_id, date)`, `(date)`, `(signal_type)` - Signal filtering
4. **subscriptions**: `(user_id)`, `(status)`, `(expires_at)` - Subscription checks
5. **entitlements**: `(user_id, feature_key)` - Fast feature gating
6. **watchlist_items**: `(watchlist_id)` - Watchlist rendering
7. **notification_events**: `(user_id)`, `(is_sent)`, `(is_read)` - Notification queries

## Relationships Diagram

```
users
  ├── user_roles → roles
  ├── devices
  ├── watchlists → watchlist_items → stocks/funds
  ├── alerts → stocks
  ├── subscriptions → subscription_plans
  ├── entitlements
  ├── invoices
  └── notification_events

stocks
  ├── candles_daily
  ├── indicators_daily
  ├── signals → signal_explanations
  ├── news_items
  ├── data_quality_checks
  └── watchlist_items

admin_settings → users (updated_by)
audit_logs → users (user_id, nullable)
```

## Data Integrity Rules

1. **Unique Constraints**:
   - `candles_daily`: One record per stock per date
   - `indicators_daily`: One record per stock per date
   - `signals`: Multiple signals per stock per date allowed (if algorithm generates multiple)

2. **Cascade Deletes**:
   - Deleting a user cascades to their subscriptions, watchlists, alerts
   - Deleting a stock cascades to candles, indicators, signals

3. **Check Constraints**:
   - `watchlist_items`: Either `stock_id` OR `fund_id` must be set (mutually exclusive)
   - `confidence`: Must be 0-100 (enforced at application level)

4. **Foreign Key Constraints**:
   - All foreign keys enforce referential integrity
   - `subscriptions.plan_id`: RESTRICT (cannot delete plan with active subscriptions)

## Migration Strategy

All tables are created via Laravel migrations in `apps/api/database/migrations/`. Seeders populate initial data:
- Default roles (`super_admin`, `admin`, `user`)
- Default subscription plans (`free`, `basic`, `pro`)
- Initial admin user (from `.env`)
- Sample stocks (if needed for development)
