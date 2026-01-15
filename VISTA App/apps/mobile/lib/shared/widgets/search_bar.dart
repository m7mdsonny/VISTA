import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// مكون شريط البحث
class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? AppConstants.search,
            hintStyle: TextStyle(
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
              fontSize: 15,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
              size: 20,
            ),
            suffixIcon: controller?.text.isNotEmpty == true
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
                      size: 18,
                    ),
                    onPressed: () {
                      controller?.clear();
                      onClear?.call();
                    },
                  )
                : null,
          ),
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
