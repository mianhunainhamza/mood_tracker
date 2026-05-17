// lib/widgets/painters/mood_face_painter.dart
//
// Draws a mood face entirely with Flutter's Canvas API.
// No images, no emoji, no icon fonts — just drawCircle, drawArc, drawPath,
// and drawLine as required by the task brief.
//
// Three animation inputs drive different visual layers:
//   [progress]      — timeline tap pulse  (0→1→0 one-shot)
//   [breathProgress]— idle breathing loop (0→1→0 repeating)
//   [isSelected]    — picker selection state (brightens fill, intensifies glow)
//
// All geometry is normalised to paint bounds — faces scale cleanly
// at 60px (timeline) or 64px (picker) with identical logic.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/mood_entry.dart';

class MoodFacePainter extends CustomPainter {
  final MoodType moodType;

  /// Timeline tap pulse. 0.0 = idle, 1.0 = peak of pulse.
  final double progress;

  /// Idle breathing loop value. 0.0 → 1.0 → 0.0 repeating.
  final double breathProgress;

  /// Whether this face is currently selected in the picker.
  final bool isSelected;

  const MoodFacePainter({
    required this.moodType,
    this.progress = 0.0,
    this.breathProgress = 0.0,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.88;
    _drawFace(canvas, center, radius);
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    final color = moodType.color;

    // Combined animation intensity — pulse dominates, breath fills the gaps
    final intensity = math.max(progress, breathProgress * 0.4);

    // ------------------------------------------------------------------
    // 1. Outer glow ring — brightens on selection, breathes at idle
    // ------------------------------------------------------------------
    if (intensity > 0 || isSelected) {
      final glowOpacity = isSelected
          ? 0.20 + intensity * 0.25
          : intensity * 0.20;
      final glowRadius = radius + 6 + intensity * 6;
      final glowPaint = Paint()
        ..color = color.withOpacity(glowOpacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 + intensity * 8);
      canvas.drawCircle(center, glowRadius, glowPaint);
    }

    // ------------------------------------------------------------------
    // 2. Face background — fills more richly when selected
    // ------------------------------------------------------------------
    final bgOpacity = isSelected
        ? 0.22 + breathProgress * 0.06
        : 0.12 + breathProgress * 0.04;
    final bgPaint = Paint()
      ..color = color.withOpacity(bgOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // ------------------------------------------------------------------
    // 3. Border — thicker and brighter when selected
    // ------------------------------------------------------------------
    final borderWidth = isSelected
        ? radius * 0.07 + breathProgress * radius * 0.015
        : radius * 0.05;
    final borderPaint = Paint()
      ..color = color.withOpacity(isSelected ? 1.0 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, borderPaint);

    // ------------------------------------------------------------------
    // 4. Eyes
    // ------------------------------------------------------------------
    _drawEyes(canvas, center, radius, color);

    // ------------------------------------------------------------------
    // 5. Eyebrows
    // ------------------------------------------------------------------
    _drawEyebrows(canvas, center, radius, color);

    // ------------------------------------------------------------------
    // 6. Mouth
    // ------------------------------------------------------------------
    _drawMouth(canvas, center, radius, color);

    // ------------------------------------------------------------------
    // 7. Inner shine — a crescent highlight arc at top of face when selected
    //    This gives the face a "lit from above" premium glass effect.
    // ------------------------------------------------------------------
    if (isSelected || progress > 0) {
      final shineOpacity = isSelected
          ? 0.12 + breathProgress * 0.08
          : progress * 0.15;
      final shinePaint = Paint()
        ..color = Colors.white.withOpacity(shineOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.12
        ..strokeCap = StrokeCap.round;
      // Small arc across the top quarter of the face
      final shineRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.15),
        width: radius * 1.0,
        height: radius * 0.5,
      );
      canvas.drawArc(shineRect, math.pi + 0.4, math.pi - 0.8, false, shinePaint);
    }
  }

  // -----------------------------------------------------------------------
  // Eyes
  // -----------------------------------------------------------------------
  void _drawEyes(Canvas canvas, Offset center, double radius, Color color) {
    final eyeY = center.dy - radius * 0.18;
    final eyeOffsetX = radius * 0.32;
    final eyeRadius = radius * 0.10;

    // Eyes brighten slightly when selected
    final eyeColor = isSelected ? color : color.withOpacity(0.85);

    final fillPaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.fill;

    final dropY = moodType == MoodType.verySad ? radius * 0.06 : 0.0;

    canvas.drawCircle(
        Offset(center.dx - eyeOffsetX, eyeY + dropY), eyeRadius, fillPaint);
    canvas.drawCircle(
        Offset(center.dx + eyeOffsetX, eyeY + dropY), eyeRadius, fillPaint);

    // White sparkle in each eye
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.fill;
    final hlRadius = eyeRadius * 0.35;
    canvas.drawCircle(
        Offset(center.dx - eyeOffsetX + hlRadius, eyeY + dropY - hlRadius),
        hlRadius, highlightPaint);
    canvas.drawCircle(
        Offset(center.dx + eyeOffsetX + hlRadius, eyeY + dropY - hlRadius),
        hlRadius, highlightPaint);
  }

  // -----------------------------------------------------------------------
  // Eyebrows
  // -----------------------------------------------------------------------
  void _drawEyebrows(Canvas canvas, Offset center, double radius, Color color) {
    final browPaint = Paint()
      ..color = color.withOpacity(isSelected ? 1.0 : 0.8)
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

  // -----------------------------------------------------------------------
  // Mouth
  // -----------------------------------------------------------------------
  void _drawMouth(Canvas canvas, Offset center, double radius, Color color) {
    final mouthPaint = Paint()
      ..color = color.withOpacity(isSelected ? 1.0 : 0.85)
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
    final path = Path()..addArc(smileRect, 0, math.pi);

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(isSelected ? 0.70 : 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    canvas.drawArc(smileRect, 0, math.pi, false, paint);

    // Blush circles — more vivid when selected
    final blushPaint = Paint()
      ..color = color.withOpacity(isSelected ? 0.38 : 0.25)
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
    canvas.drawArc(rect, sweepUp ? math.pi : 0.0, math.pi, false, paint);
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

    final leftCorner =
        Offset(center.dx - mouthHalfW * 1.2, mouthY + radius * 0.02);
    final rightCorner =
        Offset(center.dx + mouthHalfW * 1.2, mouthY + radius * 0.02);

    canvas.drawLine(leftCorner,
        leftCorner + Offset(-radius * 0.08, -radius * 0.06), quiverPaint);
    canvas.drawLine(rightCorner,
        rightCorner + Offset(radius * 0.08, -radius * 0.06), quiverPaint);
  }

  @override
  bool shouldRepaint(MoodFacePainter old) =>
      old.moodType != moodType ||
      old.progress != progress ||
      old.breathProgress != breathProgress ||
      old.isSelected != isSelected;
}
