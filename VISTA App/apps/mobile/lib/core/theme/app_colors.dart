import 'package:flutter/material.dart';

/// نظام الألوان لتطبيق مصرية ماركت
/// يطابق تماماً ألوان تطبيق React Native الأصلي
class AppColors {
  AppColors._();

  // الألوان الرئيسية
  static const Color primary = Color(0xFF0066CC);
  static const Color primaryLight = Color(0xFF3399FF);
  static const Color primaryDark = Color(0xFF004C99);

  // ألوان الحالة
  static const Color positive = Color(0xFF10B981);
  static const Color negative = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ألوان الخلفية - الوضع الفاتح
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);

  // ألوان الخلفية - الوضع الداكن
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);

  // ألوان النص - الوضع الفاتح
  static const Color foregroundLight = Color(0xFF0F172A);
  static const Color mutedLight = Color(0xFF64748B);
  static const Color subtleLight = Color(0xFF94A3B8);

  // ألوان النص - الوضع الداكن
  static const Color foregroundDark = Color(0xFFF8FAFC);
  static const Color mutedDark = Color(0xFF94A3B8);
  static const Color subtleDark = Color(0xFF64748B);

  // ألوان الحدود
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // ألوان إضافية
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF1F5F9);

  // ألوان مستوى المخاطرة
  static const Color riskLow = Color(0xFF10B981);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color riskHigh = Color(0xFFEF4444);

  // ألوان نوع الإشارة
  static const Color signalBuy = Color(0xFF10B981);
  static const Color signalSell = Color(0xFFEF4444);
  static const Color signalHold = Color(0xFFF59E0B);
}

/// امتداد للحصول على الألوان حسب الثيم
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get background => isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get surface => isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight;
  Color get cardColor => isDarkMode ? AppColors.cardDark : AppColors.cardLight;
  Color get foreground => isDarkMode ? AppColors.foregroundDark : AppColors.foregroundLight;
  Color get muted => isDarkMode ? AppColors.mutedDark : AppColors.mutedLight;
  Color get subtle => isDarkMode ? AppColors.subtleDark : AppColors.subtleLight;
  Color get border => isDarkMode ? AppColors.borderDark : AppColors.borderLight;
}
