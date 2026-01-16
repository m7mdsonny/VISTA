import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// مستوى المخاطرة
enum RiskLevel { low, medium, high }

/// مكون شارة مستوى المخاطرة
class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final bool showIcon;

  const RiskBadge({
    super.key,
    required this.level,
    this.showIcon = true,
  });

  Color get _color {
    switch (level) {
      case RiskLevel.low:
        return AppColors.riskLow;
      case RiskLevel.medium:
        return AppColors.riskMedium;
      case RiskLevel.high:
        return AppColors.riskHigh;
    }
  }

  String get _text {
    switch (level) {
      case RiskLevel.low:
        return AppConstants.riskLow;
      case RiskLevel.medium:
        return AppConstants.riskMedium;
      case RiskLevel.high:
        return AppConstants.riskHigh;
    }
  }

  IconData get _icon {
    switch (level) {
      case RiskLevel.low:
        return Icons.shield_outlined;
      case RiskLevel.medium:
        return Icons.warning_amber_outlined;
      case RiskLevel.high:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _text,
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 4),
            Icon(_icon, color: _color, size: 14),
          ],
        ],
      ),
    );
  }
}
