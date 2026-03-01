import 'dart:math';
import 'package:flutter/material.dart';

class WheelPainter extends CustomPainter {
  WheelPainter({required this.sections, required this.rotationAngle});

  final List<String> sections;
  final double rotationAngle;

  static const List<Color> _palette = [
    Color(0xFFE53935), // red
    Color(0xFF43A047), // green
    Color(0xFF1E88E5), // blue
    Color(0xFFFDD835), // yellow
    Color(0xFF8E24AA), // purple
    Color(0xFFFF8F00), // amber
    Color(0xFF00ACC1), // cyan
    Color(0xFFD81B60), // pink
    Color(0xFF7CB342), // light green
    Color(0xFF3949AB), // indigo
    Color(0xFFFF6D00), // deep orange
    Color(0xFF00897B), // teal
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final sectionAngle = 2 * pi / sections.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    // Draw arcs
    for (var i = 0; i < sections.length; i++) {
      paint.color = _palette[i % _palette.length];
      canvas.drawArc(rect, i * sectionAngle, sectionAngle, true, paint);
    }

    // Draw section borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (var i = 0; i < sections.length; i++) {
      canvas.drawArc(rect, i * sectionAngle, sectionAngle, true, borderPaint);
    }

    // Draw labels
    final fontSize = sections.length <= 6
        ? 28.0
        : sections.length <= 10
        ? 26.0
        : 24.0;

    for (var i = 0; i < sections.length; i++) {
      final midAngle = i * sectionAngle + sectionAngle / 2;
      final color = _palette[i % _palette.length];
      final textColor = color.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;

      canvas.save();
      canvas.rotate(midAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: sections[i],
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 0.6);

      final textOffset = Offset(
        radius * 0.55 - textPainter.width / 2,
        -textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);

      canvas.restore();
    }

    // Center hub
    canvas.drawCircle(
      Offset.zero,
      radius * 0.08,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.08,
      Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.sections != sections;
  }
}
