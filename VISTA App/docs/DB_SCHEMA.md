# مخطط قاعدة البيانات

## الجداول الرئيسية
- users
- roles
- user_roles
- devices
- stocks
- funds
- candles_daily
- indicators_daily
- signals
- signal_explanations
- data_quality_checks
- news_items
- watchlists
- watchlist_items
- alerts
- notification_events
- subscription_plans
- subscriptions
- entitlements
- invoices
- admin_settings
- audit_logs

## الفهارس المهمة
- candles_daily: unique(stock_id, date)
- indicators_daily: unique(stock_id, date)
- signals: index(stock_id, date)
- watchlist_items: unique(watchlist_id, stock_id, fund_id, type)
- alerts: index(user_id, is_read)
- entitlements: index(user_id, plan_code)
