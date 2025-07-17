import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final rippleCount = 4;
    final baseRadius = 20.0;

    for (int i = 1; i <= rippleCount; i++) {
      paint.color = Colors.white.withOpacity(0.08 * (rippleCount - i + 1));
      canvas.drawCircle(center, baseRadius * i.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
