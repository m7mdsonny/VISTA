import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الخطوط لتطبيق مصرية ماركت
/// يستخدم خط Alexandria للنصوص العربية
class AppTypography {
  AppTypography._();

  /// الحصول على TextTheme مع خط Alexandria
  static TextTheme getTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.dark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);

    final Color mutedColor = brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return TextTheme(
      // العناوين الكبيرة
      displayLarge: GoogleFonts.alexandria(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      displayMedium: GoogleFonts.alexandria(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      displaySmall: GoogleFonts.alexandria(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),

      // العناوين
      headlineLarge: GoogleFonts.alexandria(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.alexandria(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.alexandria(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),

      // العناوين الفرعية
      titleLarge: GoogleFonts.alexandria(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.alexandria(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.alexandria(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),

      // النص الأساسي
      bodyLarge: GoogleFonts.alexandria(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.alexandria(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.alexandria(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: mutedColor,
        height: 1.5,
      ),

      // التسميات
      labelLarge: GoogleFonts.alexandria(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.alexandria(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.alexandria(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: mutedColor,
        height: 1.4,
      ),
    );
  }
}
