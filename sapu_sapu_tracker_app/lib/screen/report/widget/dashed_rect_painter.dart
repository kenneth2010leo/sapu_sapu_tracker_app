import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

// Custom Painter to draw dashed border around a rounded rectangle
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));

    final Path dashedPath = _createDashedPath(path, gap, gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double dashGap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = min(dashLength, metric.length - distance);
        dest.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += len + dashGap;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
