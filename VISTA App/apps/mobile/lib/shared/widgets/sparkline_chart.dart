import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// مكون الرسم البياني المصغر
class SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double strokeWidth;
  final bool showGradient;

  const SparklineChart({
    super.key,
    required this.data,
    required this.color,
    this.strokeWidth = 2,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: _SparklinePainter(
        data: data,
        color: color,
        strokeWidth: strokeWidth,
        showGradient: showGradient,
      ),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;
  final bool showGradient;

  _SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
    required this.showGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range == 0 ? 0.5 : (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // رسم التدرج
    if (showGradient && points.isNotEmpty) {
      final gradientPath = Path.from(path);
      gradientPath.lineTo(size.width, size.height);
      gradientPath.lineTo(0, size.height);
      gradientPath.close();

      final gradient = ui.Gradient.linear(
        Offset(0, 0),
        Offset(0, size.height),
        [
          color.withOpacity(0.3),
          color.withOpacity(0.0),
        ],
      );

      final gradientPaint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.fill;

      canvas.drawPath(gradientPath, gradientPaint);
    }

    // رسم الخط
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // رسم النقطة الأخيرة
    if (points.isNotEmpty) {
      final lastPoint = points.last;
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(lastPoint, strokeWidth * 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
