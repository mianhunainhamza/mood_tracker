

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/mood_entry.dart';

class MoodFacePainter extends CustomPainter {
  final MoodType moodType;

  final double progress;

  const MoodFacePainter({
    required this.moodType,
    this.progress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.88;

    final scale = 1.0 + progress * 0.12;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    _drawFace(canvas, center, radius);

    canvas.restore();
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    final color = moodType.color;

    if (progress > 0) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.25 * progress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(center, radius + 8, glowPaint);
    }

    final bgPaint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, borderPaint);

    _drawEyes(canvas, center, radius, color);

    _drawEyebrows(canvas, center, radius, color);

    _drawMouth(canvas, center, radius, color);
  }

  void _drawEyes(Canvas canvas, Offset center, double radius, Color color) {
    final eyeY = center.dy - radius * 0.18;
    final eyeOffsetX = radius * 0.32;
    final eyeRadius = radius * 0.10;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dropY = moodType == MoodType.verySad ? radius * 0.06 : 0.0;

    canvas.drawCircle(
        Offset(center.dx - eyeOffsetX, eyeY + dropY), eyeRadius, fillPaint);
    canvas.drawCircle(
        Offset(center.dx + eyeOffsetX, eyeY + dropY), eyeRadius, fillPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final hlRadius = eyeRadius * 0.35;
    canvas.drawCircle(
        Offset(center.dx - eyeOffsetX + hlRadius,
            eyeY + dropY - hlRadius),
        hlRadius,
        highlightPaint);
    canvas.drawCircle(
        Offset(center.dx + eyeOffsetX + hlRadius,
            eyeY + dropY - hlRadius),
        hlRadius,
        highlightPaint);
  }

  void _drawEyebrows(Canvas canvas, Offset center, double radius, Color color) {
    final browPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07
      ..strokeCap = StrokeCap.round;

    final browY = center.dy - radius * 0.42;
    final browOffsetX = radius * 0.32;
    final browHalfW = radius * 0.22;

    final double outerDY;
    final double innerDY;
    switch (moodType) {
      case MoodType.veryHappy:
        outerDY = -radius * 0.13;
        innerDY = radius * 0.04;
        break;
      case MoodType.happy:
        outerDY = -radius * 0.07;
        innerDY = radius * 0.02;
        break;
      case MoodType.neutral:
        outerDY = 0;
        innerDY = 0;
        break;
      case MoodType.sad:
        outerDY = radius * 0.06;
        innerDY = -radius * 0.04;
        break;
      case MoodType.verySad:
        outerDY = radius * 0.12;
        innerDY = -radius * 0.08;
        break;
    }

    canvas.drawLine(
      Offset(center.dx - browOffsetX - browHalfW, browY + outerDY),
      Offset(center.dx - browOffsetX + browHalfW, browY + innerDY),
      browPaint,
    );
    canvas.drawLine(
      Offset(center.dx + browOffsetX - browHalfW, browY + innerDY),
      Offset(center.dx + browOffsetX + browHalfW, browY + outerDY),
      browPaint,
    );
  }

  void _drawMouth(Canvas canvas, Offset center, double radius, Color color) {
    final mouthPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final mouthY = center.dy + radius * 0.28;
    final mouthHalfW = radius * 0.36;

    switch (moodType) {
      case MoodType.veryHappy:
        _drawWideSmile(canvas, center, radius, mouthY, mouthHalfW, mouthPaint, color);
        break;
      case MoodType.happy:
        _drawArcMouth(canvas, mouthY, center, mouthHalfW, radius * 0.22,
            sweepUp: true, paint: mouthPaint);
        break;
      case MoodType.neutral:
        _drawStraightMouth(canvas, mouthY, center, mouthHalfW, mouthPaint);
        break;
      case MoodType.sad:
        _drawArcMouth(canvas, mouthY + radius * 0.10, center, mouthHalfW,
            radius * 0.18,
            sweepUp: false, paint: mouthPaint);
        break;
      case MoodType.verySad:
        _drawWideFrown(canvas, center, radius, mouthY, mouthHalfW, mouthPaint);
        break;
    }
  }

  void _drawWideSmile(Canvas canvas, Offset center, double radius,
      double mouthY, double mouthHalfW, Paint paint, Color color) {
    final smileRect = Rect.fromCenter(
      center: Offset(center.dx, mouthY),
      width: mouthHalfW * 2.4,
      height: radius * 0.55,
    );
    final path = Path()
      ..addArc(smileRect, 0, math.pi);

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    canvas.drawArc(smileRect, 0, math.pi, false, paint);

    final blushPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(center.dx - mouthHalfW * 1.3, mouthY - radius * 0.05),
        radius * 0.10, blushPaint);
    canvas.drawCircle(
        Offset(center.dx + mouthHalfW * 1.3, mouthY - radius * 0.05),
        radius * 0.10, blushPaint);
  }

  void _drawArcMouth(Canvas canvas, double mouthY, Offset center,
      double halfW, double arcHeight,
      {required bool sweepUp, required Paint paint}) {
    final rect = Rect.fromCenter(
      center: Offset(center.dx, mouthY + (sweepUp ? arcHeight : -arcHeight)),
      width: halfW * 2,
      height: arcHeight * 2,
    );
    final startAngle = sweepUp ? math.pi : 0.0;
    canvas.drawArc(rect, startAngle, math.pi, false, paint);
  }

  void _drawStraightMouth(Canvas canvas, double mouthY, Offset center,
      double halfW, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - halfW, mouthY),
      Offset(center.dx + halfW, mouthY),
      paint,
    );
  }

  void _drawWideFrown(Canvas canvas, Offset center, double radius,
      double mouthY, double mouthHalfW, Paint paint) {
    final arcHeight = radius * 0.25;
    final rect = Rect.fromCenter(
      center: Offset(center.dx, mouthY - arcHeight + radius * 0.14),
      width: mouthHalfW * 2.4,
      height: arcHeight * 2,
    );
    canvas.drawArc(rect, 0, math.pi, false, paint);

    final quiverPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth * 0.7
      ..strokeCap = StrokeCap.round;

    final leftCorner = Offset(center.dx - mouthHalfW * 1.2, mouthY + radius * 0.02);
    final rightCorner = Offset(center.dx + mouthHalfW * 1.2, mouthY + radius * 0.02);

    canvas.drawLine(leftCorner,
        leftCorner + Offset(-radius * 0.08, -radius * 0.06), quiverPaint);
    canvas.drawLine(rightCorner,
        rightCorner + Offset(radius * 0.08, -radius * 0.06), quiverPaint);
  }

  @override
  bool shouldRepaint(MoodFacePainter oldDelegate) =>
      oldDelegate.moodType != moodType || oldDelegate.progress != progress;
}
