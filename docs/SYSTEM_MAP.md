# System Architecture Map - Vista Egyptian AI Market Analysis App

## Overview

Vista is a production-grade monorepo for an AI-driven Egyptian market analysis application covering stocks (EGX) and mutual funds. The system is designed with strict separation between automated analysis engines and administrative configuration, ensuring all signals are data-driven and reproducible.

## Core Principles

1. **Zero Manual Signal Manipulation**: Admin cannot create, edit, or override signals for specific stocks
2. **Fully Automated Intelligence**: All signals are generated from market data using configurable weights/thresholds
3. **Complete Traceability**: Every signal includes confidence, risk assessment, explanations, and caveats
4. **Legal Safety**: No "Buy" or "Sell" language - only automated analysis with clear disclaimers
5. **Subscription-First**: All premium features gated via Google Play Billing / Apple IAP

## System Components

### 1. Mobile Application (Flutter)
- **Location**: `apps/mobile/`
- **Tech Stack**: Flutter (latest stable), Riverpod, Dio, Freezed, GoRouter, flutter_secure_storage
- **Purpose**: Native iOS/Android client consuming REST APIs
- **Key Features**:
  - Real-time market data visualization
  - Signal cards with confidence, risk, explanations
  - Watchlists and favorites
  - Push notifications via FCM
  - In-app subscriptions (StoreKit + Google Play)
  - Paper portfolio simulation
  - Educational content

### 2. Backend API (Laravel)
- **Location**: `apps/api/`
- **Tech Stack**: Laravel (latest stable), MySQL, Redis, Sanctum, Horizon
- **API Version**: `/api/v1/*`
- **Purpose**: Core business logic, data persistence, authentication, subscription management

### 3. Admin Dashboard (Laravel Blade)
- **Location**: `apps/api/resources/views/admin/`
- **Tech Stack**: Blade templates, Tailwind CSS
- **Purpose**: Administrative interface for configuration, monitoring, and subscription management
- **Limitations**: Cannot manually create/edit signals; configuration only

### 4. Queue System (Laravel Horizon)
- **Purpose**: Async processing of data ingestion, signal generation, notifications
- **Queues**: `default`, `notifications`, `data-ingestion`, `signals`

### 5. Scheduler (Laravel Scheduler)
- **Purpose**: Cron-like jobs for periodic tasks
- **Tasks**: Daily data ingestion, indicator calculations, signal generation, subscription expiry checks

### 6. Notification Service (FCM)
- **Purpose**: Push notifications to mobile devices
- **Anti-Spam**: Rate limiting, quiet hours, priority levels

## Data Flow Architecture

### Phase 1: Market Data Ingestion

```
External Data Provider → MarketDataIngestionService → DataValidationService
                                                          ↓
                                                    candles_daily (if valid)
```

**Flow**:
1. Scheduled job fetches daily OHLCV data from market provider
2. `MarketDataIngestionService` normalizes and validates structure
3. `DataValidationService` checks:
   - Completeness (no missing days)
   - Outlier detection (price/volume spikes)
   - Data quality score (0-100)
4. If quality score ≥ threshold (configurable by admin), data is stored in `candles_daily`
5. Low-quality data triggers alerts to admin (via `audit_logs`)

### Phase 2: Indicator Calculation

```
candles_daily → IndicatorService → indicators_daily
```

**Flow**:
1. After successful candle ingestion, `IndicatorService` calculates:
   - RSI (14-day default, configurable)
   - Moving Averages (MA20, MA50, MA200)
   - MACD (12, 26, 9)
   - Bollinger Bands
   - Volume indicators (avg volume, volume ratio)
   - Volatility (ATR-based)
2. Results stored in `indicators_daily` with unique constraint on `(stock_id, date)`
3. Calculations are deterministic and reproducible

### Phase 3: Signal Generation (AUTOMATED ONLY)

```
indicators_daily + candles_daily + news_items → SignalEngineService → signals
                                                      ↓
                                            signal_explanations
```

**Flow**:
1. `SignalEngineService` runs daily after indicator calculation
2. **CRITICAL**: Engine reads ONLY:
   - Market data (candles, indicators)
   - News sentiment (if available)
   - Admin-configured weights/thresholds (from `admin_settings`)
3. **CRITICAL**: Engine NEVER reads:
   - Admin UI inputs for specific stocks
   - Manual signal recommendations
   - User preferences for signals
4. Signal generation algorithm:
   ```
   signal_confidence = weighted_sum(
       volume_score * volume_weight,
       liquidity_score * liquidity_weight,
       trend_alignment * trend_weight,
       mean_reversion_score * mean_reversion_weight,
       volatility_regime * volatility_weight,
       news_impact * news_weight
   )
   
   if signal_confidence >= buy_threshold:
       signal_type = 'buy'
   elif signal_confidence <= sell_threshold:
       signal_type = 'sell'
   else:
       signal_type = 'hold'
   ```
5. Each signal includes:
   - `confidence` (0-100)
   - `risk_level` ('low'|'medium'|'high') via `RiskAssessmentService`
   - `signal_type` ('buy'|'sell'|'hold')
6. Signal stored in `signals` table with audit trail

### Phase 4: Explainability

```
signals → ExplainabilityService → signal_explanations
```

**Flow**:
1. `ExplainabilityService` generates human-readable explanations
2. **Why** (3 bullets): Technical reasons for the signal (e.g., "Volume increase 40% above average", "RSI below 30 suggests oversold")
3. **Caveats** (2 bullets): Risks and disclaimers (e.g., "Market volatility may impact performance", "Past performance doesn't guarantee future results")
4. Explanations stored in `signal_explanations` with Arabic text for user display
5. JSON keys remain English for API consistency

### Phase 5: Notification Generation

```
signals → NotificationRulesService → notification_events → FCM → Mobile App
```

**Flow**:
1. When new signal is generated, `NotificationRulesService` evaluates:
   - User subscriptions (`entitlements`)
   - Watchlist matches (`watchlist_items`)
   - Alert preferences (`alerts`)
   - Anti-spam rules (rate limits, quiet hours)
2. If conditions met, creates `notification_events` record
3. Queue job processes event and sends via FCM
4. User receives push notification on mobile device

### Phase 6: User Consumption

```
Mobile App → API Request → SubscriptionService → FeatureGateService → Response
```

**Flow**:
1. User opens app, requests signals/watchlists/etc.
2. `SubscriptionService` checks active `subscriptions` and `entitlements`
3. `FeatureGateService` gates features by plan:
   - Free: Limited signals (3/day), basic watchlist
   - Basic: Full signals, unlimited watchlists, alerts
   - Pro: All features, backtesting, paper portfolio
4. API returns data based on entitlements
5. Mobile app renders UI with feature gating

## Separation of Concerns

### Automated Analysis Layer
- **Services**: `MarketDataIngestionService`, `IndicatorService`, `SignalEngineService`, `ExplainabilityService`, `RiskAssessmentService`
- **Responsibility**: Pure data-driven analysis, no manual intervention
- **Data Sources**: Market data, indicators, news sentiment
- **Output**: Signals with confidence, risk, explanations

### Configuration Layer
- **Services**: `AdminConfigService`
- **Admin Dashboard**: Indicator weights, thresholds, signal sensitivity, liquidity filters
- **Responsibility**: Adjusting algorithm parameters, NOT stock-specific signals
- **Storage**: `admin_settings` table

### Subscription & Access Control
- **Services**: `SubscriptionService`, `FeatureGateService`
- **Responsibility**: Plan management, receipt verification, feature gating
- **Storage**: `subscription_plans`, `subscriptions`, `entitlements`

### Notification Layer
- **Services**: `NotificationRulesService`
- **Responsibility**: Rule-based notification dispatch, anti-spam, quiet hours
- **Storage**: `notification_events`, `alerts`

## Security Boundaries

### Admin Dashboard Access
- **Authentication**: Laravel Sanctum session-based
- **Authorization**: RBAC via `roles` table (`super_admin`, `admin`)
- **Audit Trail**: All admin actions logged to `audit_logs`

### API Access
- **Authentication**: Laravel Sanctum token-based
- **Rate Limiting**: Configured per endpoint (default: 60/min for authenticated)
- **Webhooks**: Signature verification for payment provider callbacks

### Signal Integrity
- **Database Constraints**: Foreign keys ensure data consistency
- **Service Policies**: `SignalPolicy` prevents manual creation/editing from admin
- **Audit Logging**: All signal generation events logged

## Deployment Architecture

### Development
```
Local Machine:
  - Laravel API (php artisan serve :8000)
  - Horizon (php artisan horizon)
  - Scheduler (php artisan schedule:work)
  - Flutter App (flutter run)
  - MySQL (localhost:3306)
  - Redis (localhost:6379)
```

### Production (Target)
```
App Server:
  - Laravel API (Nginx + PHP-FPM)
  - Horizon (Supervisor)
  - Scheduler (Cron: * * * * * php artisan schedule:run)

Worker Server:
  - Horizon workers (scalable)

Database Server:
  - MySQL (Primary + Replica)

Cache Server:
  - Redis (Session + Cache + Queue)

Mobile Apps:
  - iOS (App Store)
  - Android (Google Play)
```

## Monitoring & Observability

### Logs
- **Application Logs**: `storage/logs/laravel.log`
- **Audit Logs**: `audit_logs` table (admin actions, signal generation)
- **Error Tracking**: Integration-ready for Sentry/Rollbar

### Metrics
- **Horizon Dashboard**: Queue performance, job failures
- **Data Quality**: `data_quality_checks` table tracks ingestion health
- **Subscription Metrics**: Active users, trial conversions, churn

### Alerts
- **Data Quality**: Low scores trigger admin notifications
- **Queue Failures**: Horizon alerts on job failures
- **Subscription Issues**: Failed receipt verifications logged

## Scalability Considerations

### Horizontal Scaling
- **API Servers**: Stateless, can run multiple instances behind load balancer
- **Queue Workers**: Horizon workers can scale across multiple servers
- **Database**: MySQL read replicas for reporting queries

### Caching Strategy
- **Redis Cache**: Frequently accessed data (market summaries, user entitlements)
- **Query Optimization**: Indexed queries on `signals`, `candles_daily`, `subscriptions`

### Rate Limiting
- **API Endpoints**: Per-user rate limits to prevent abuse
- **Notification Service**: Anti-spam rules prevent notification flooding

## Future Extensibility

### Additional Data Sources
- Real-time tick data (WebSocket integration)
- Social sentiment analysis (Twitter/X, Reddit)
- Earnings calendar integration

### Advanced Features
- Portfolio backtesting engine
- Risk-adjusted return calculations
- Multi-timeframe analysis

### Analytics
- User behavior tracking (privacy-compliant)
- A/B testing framework for UI/UX improvements
