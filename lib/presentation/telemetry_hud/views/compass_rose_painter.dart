import 'dart:math';

import 'package:flutter/material.dart';

class CompassRosePainter extends CustomPainter {
  final double azimuthDegrees;
  final Color primaryColor;
  final Color secondaryColor;
  final Color outlineColor;
  final Color textColor;

  CompassRosePainter({
    required this.azimuthDegrees,
    required this.primaryColor,
    required this.secondaryColor,
    required this.outlineColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.0 - 10;

    final circlePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawCircle(center, radius * 0.85, circlePaint..strokeWidth = 0.8);

    // Compass dial rotation
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-azimuthDegrees * (pi / 180.0));

    final tickPaint = Paint()
      ..color = outlineColor
      ..strokeWidth = 1.0;

    // Draw degree ticks
    for (int deg = 0; deg < 360; deg += 15) {
      final rad = deg * (pi / 180.0);
      final isMajor = deg % 90 == 0;
      final isMedium = deg % 45 == 0;
      final tickLength = isMajor ? 14.0 : (isMedium ? 8.0 : 5.0);

      final p1 = Offset(cos(rad) * radius, sin(rad) * radius);
      final p2 = Offset(
        cos(rad) * (radius - tickLength),
        sin(rad) * (radius - tickLength),
      );

      tickPaint.strokeWidth = isMajor ? 2.0 : 1.0;
      tickPaint.color = isMajor ? primaryColor : outlineColor;
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Cardinal Labels: N, E, S, W
    _drawCardinalText(canvas, 'N', 0, radius - 22, primaryColor);
    _drawCardinalText(canvas, 'E', 90, radius - 22, textColor);
    _drawCardinalText(canvas, 'S', 180, radius - 22, textColor);
    _drawCardinalText(canvas, 'W', 270, radius - 22, textColor);

    canvas.restore();

    // Center Fixed Heading Pointer (Needle)
    final needlePaint = Paint()..style = PaintingStyle.fill;

    // North Needle (Primary Color)
    needlePaint.color = primaryColor;
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.65)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    canvas.drawPath(northPath, needlePaint);

    // South Needle (Secondary Color)
    needlePaint.color = secondaryColor.withAlpha(180);
    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.65)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    canvas.drawPath(southPath, needlePaint);

    // Center Cap
    canvas.drawCircle(center, 6, Paint()..color = Colors.white);
    canvas.drawCircle(center, 4, Paint()..color = primaryColor);
  }

  void _drawCardinalText(
    Canvas canvas,
    String text,
    double angleDeg,
    double dist,
    Color color,
  ) {
    // In our coordinate system with 0 deg at top, angle from top is:
    final rad = (angleDeg - 90) * (pi / 180.0);
    final pos = Offset(cos(rad) * dist, sin(rad) * dist);

    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Orient text right-side up relative to the mark
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CompassRosePainter oldDelegate) {
    return oldDelegate.azimuthDegrees != azimuthDegrees ||
        oldDelegate.primaryColor != primaryColor;
  }
}
