import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// أنواع البطاقة
enum AppCardVariant {
  /// بطاقة افتراضية بحدود
  defaultCard,
  /// بطاقة مرتفعة بظل
  elevated,
  /// بطاقة بحدود فقط
  outline,
}

/// مكون البطاقة القابل لإعادة الاستخدام
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.defaultCard,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 16,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color bgColor;
    List<BoxShadow>? shadows;
    Border? border;

    switch (variant) {
      case AppCardVariant.elevated:
        bgColor = backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
        shadows = [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
        border = null;
        break;
      case AppCardVariant.outline:
        bgColor = Colors.transparent;
        shadows = null;
        border = Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        );
        break;
      case AppCardVariant.defaultCard:
      default:
        bgColor = backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
        shadows = null;
        border = Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        );
    }

    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
