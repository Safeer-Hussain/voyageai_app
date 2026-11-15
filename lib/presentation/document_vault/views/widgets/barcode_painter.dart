import 'package:flutter/material.dart';

class BarcodePainter extends CustomPainter {
  final String payload;
  final Color barColor;

  BarcodePainter({required this.payload, this.barColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final hash = payload.hashCode.abs();
    final barCount = 48;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      // Deterministic pseudo-random pattern based on payload hash
      final bit = ((hash * (i + 13)) ^ (i * 37)) % 7;
      if (bit != 0 && bit != 2) {
        final left = i * barWidth;
        final right = left + (barWidth * (bit == 1 ? 0.6 : 0.85));
        canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) {
    return oldDelegate.payload != payload || oldDelegate.barColor != barColor;
  }
}
