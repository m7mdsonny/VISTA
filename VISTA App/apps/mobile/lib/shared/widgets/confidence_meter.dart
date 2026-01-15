import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

/// مكون مقياس نسبة الثقة الدائري
class ConfidenceMeter extends StatelessWidget {
  final int confidence;
  final double size;
  final bool showLabel;
  final double strokeWidth;

  const ConfidenceMeter({
    super.key,
    required this.confidence,
    this.size = 40,
    this.showLabel = false,
    this.strokeWidth = 3,
  });

  Color get _color {
    if (confidence >= 80) return AppColors.positive;
    if (confidence >= 60) return AppColors.warning;
    return AppColors.negative;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMeter(bgColor),
          const SizedBox(width: 6),
          Text(
            '$confidence%',
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return _buildMeter(bgColor);
  }

  Widget _buildMeter(Color bgColor) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ConfidencePainter(
          progress: confidence / 100,
          color: _color,
          backgroundColor: bgColor,
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: !showLabel
              ? Text(
                  '$confidence',
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.3,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _ConfidencePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _ConfidencePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // رسم الخلفية
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // رسم التقدم
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConfidencePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
