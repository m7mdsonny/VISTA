import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// أنواع الزر
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  danger,
  ghost,
}

/// أحجام الزر
enum AppButtonSize {
  small,
  medium,
  large,
}

/// مكون الزر القابل لإعادة الاستخدام
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconLeading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // تحديد الألوان حسب النوع
    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = Colors.white;
        borderColor = null;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark 
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.primary.withOpacity(0.1);
        foregroundColor = AppColors.primary;
        borderColor = null;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.negative;
        foregroundColor = Colors.white;
        borderColor = null;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
        borderColor = null;
        break;
    }

    // تحديد الأحجام
    double height;
    double fontSize;
    EdgeInsetsGeometry padding;

    switch (size) {
      case AppButtonSize.small:
        height = 36;
        fontSize = 13;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case AppButtonSize.large:
        height = 52;
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 28);
        break;
      case AppButtonSize.medium:
      default:
        height = 44;
        fontSize = 15;
        padding = const EdgeInsets.symmetric(horizontal: 20);
    }

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null && iconLeading) ...[
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
        if (icon != null && !iconLeading && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: foregroundColor),
        ],
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : () {
            HapticFeedback.lightImpact();
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
