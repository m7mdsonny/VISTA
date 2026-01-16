/// App Configuration - إعدادات التطبيق
class AppConfig {
  AppConfig._();

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = true;

  // App Information
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Cache Configuration
  static const int cacheExpiryHours = 24;
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB

  // Network Configuration
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Search
  static const Duration searchDebounceDuration = Duration(milliseconds: 500);

  // Refresh
  static const Duration pullToRefreshDuration = Duration(seconds: 2);
}
