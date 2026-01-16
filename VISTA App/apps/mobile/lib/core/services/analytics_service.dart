import 'package:shared_preferences/shared_preferences.dart';

/// Analytics Service - تتبع الاستخدام (Privacy-Compliant)
class AnalyticsService {
  static const String _keyPrefix = 'analytics_';
  static const String _sessionKey = '${_keyPrefix}session';
  static const String _eventsKey = '${_keyPrefix}events';

  /// Track screen view
  static Future<void> trackScreenView(String screenName) async {
    await _trackEvent('screen_view', {
      'screen_name': screenName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track user action
  static Future<void> trackAction(String action, {Map<String, dynamic>? properties}) async {
    await _trackEvent('action', {
      'action': action,
      'properties': properties ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track signal interaction
  static Future<void> trackSignalInteraction(String signalId, String action) async {
    await _trackEvent('signal_interaction', {
      'signal_id': signalId,
      'action': action, // 'view', 'share', 'add_to_watchlist'
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Track subscription event
  static Future<void> trackSubscription(String event, String planCode) async {
    await _trackEvent('subscription', {
      'event': event, // 'view_plans', 'start_trial', 'purchase'
      'plan_code': planCode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Internal event tracking
  static Future<void> _trackEvent(String eventType, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);
      
      final events = eventsJson != null
          ? (eventsJson.split('\n').where((e) => e.isNotEmpty).toList())
          : <String>[];

      events.add(
        '${DateTime.now().millisecondsSinceEpoch}|$eventType|${data.toString()}',
      );

      // Keep only last 1000 events
      if (events.length > 1000) {
        events.removeRange(0, events.length - 1000);
      }

      await prefs.setString(_eventsKey, events.join('\n'));
    } catch (e) {
      // Silently fail - analytics is non-critical
    }
  }

  /// Get analytics data (for backend sync)
  static Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey) ?? '';
      
      return {
        'events': eventsJson.split('\n').where((e) => e.isNotEmpty).toList(),
        'session_id': prefs.getString(_sessionKey) ?? '',
      };
    } catch (e) {
      return {};
    }
  }

  /// Clear analytics data (privacy)
  static Future<void> clearAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);
      await prefs.remove(_sessionKey);
    } catch (e) {
      // Ignore errors
    }
  }
}
