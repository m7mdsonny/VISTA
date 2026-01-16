import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Offline Cache Service للعمل بدون إنترنت
class OfflineCacheService {
  static const _storage = FlutterSecureStorage();
  static const _cachePrefix = 'vista_cache_';
  static const _cacheExpiryPrefix = 'vista_cache_expiry_';
  static const _defaultExpiryHours = 24;

  /// Cache data with expiry
  static Future<void> cacheData(
    String key,
    Map<String, dynamic> data, {
    int expiryHours = _defaultExpiryHours,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final expiryKey = '$_cacheExpiryPrefix$key';

      await prefs.setString(cacheKey, jsonEncode(data));
      await prefs.setInt(
        expiryKey,
        DateTime.now().add(Duration(hours: expiryHours)).millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silently fail - offline cache is optional
      print('Cache error: $e');
    }
  }

  /// Get cached data if not expired
  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final expiryKey = '$_cacheExpiryPrefix$key';

      final cachedData = prefs.getString(cacheKey);
      final expiry = prefs.getInt(expiryKey);

      if (cachedData == null || expiry == null) {
        return null;
      }

      // Check if expired
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await clearCache(key);
        return null;
      }

      return jsonDecode(cachedData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Clear specific cache
  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cacheExpiryPrefix$key');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheExpiryPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check if data is cached and valid
  static Future<bool> isCached(String key) async {
    final cached = await getCachedData(key);
    return cached != null;
  }
}
