import 'package:flutter/material.dart';
import '../models/bubble.dart';
import 'dart:math' as math;

class BubbleWidget extends StatelessWidget {
  final Bubble bubble;

  const BubbleWidget({
    super.key,
    required this.bubble,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: bubble.position.dx - bubble.radius,
      top: bubble.position.dy - bubble.radius,
      child: Container(
        width: bubble.radius * 2,
        height: bubble.radius * 2,
        child: CustomPaint(
          painter: _BubblePainter(
            color: bubble.color,
            opacity: bubble.opacity,
            type: bubble.type,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final double opacity;
  final BubbleType type;

  _BubblePainter({
    required this.color,
    required this.opacity,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Main circle
    final paint = Paint()
      ..color = color.withOpacity(opacity * 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Gradient for volume
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.6),
          color.withOpacity(0.3),
          color.withOpacity(0.1),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, gradientPaint);

    // Border
    final borderPaint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, borderPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    final highlightOffset = Offset(
      center.dx - radius * 0.3,
      center.dy - radius * 0.3,
    );

    canvas.drawCircle(highlightOffset, radius * 0.2, highlightPaint);

    // Icon for bubble type
    _drawIcon(canvas, center, radius);
  }

  void _drawIcon(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    String icon;
    Color iconColor;

    switch (type) {
      case BubbleType.oxygen:
        icon = 'O₂';
        iconColor = Colors.white;
        break;
      case BubbleType.toxic:
        icon = '☠';
        iconColor = Colors.white;
        break;
      case BubbleType.neutral:
        icon = '○';
        iconColor = Colors.white70;
        break;
    }

    textPainter.text = TextSpan(
      text: icon,
      style: TextStyle(
        color: iconColor.withOpacity(opacity),
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.color != color ||
        oldDelegate.type != type;
  }
}
