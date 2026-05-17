import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Color accentColor;

  const AnimatedBackground({super.key, required this.accentColor});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Color _currentColor = const Color(0xFF1A1F2E);
  Color _targetColor = const Color(0xFF1A1F2E);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accentColor != widget.accentColor) {
      _targetColor = widget.accentColor;
      _animateColor();
    }
  }

  Future<void> _animateColor() async {
    final start = _currentColor;
    final end = _targetColor;
    for (int i = 1; i <= 60; i++) {
      await Future.delayed(const Duration(milliseconds: 7));
      if (!mounted) return;
      setState(() {
        _currentColor = Color.lerp(start, end, i / 60)!;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _BackgroundPainter(
          progress: _controller.value,
          accentColor: _currentColor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0 looping
  final Color accentColor;

  const _BackgroundPainter({
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = progress * 2 * math.pi;

    final orbs = [
      _Orb(
        x: w * 0.15 + math.sin(t * 0.7) * w * 0.12,
        y: h * 0.20 + math.cos(t * 0.5) * h * 0.10,
        radius: w * 0.28,
        opacity: 0.12,
      ),
      _Orb(
        x: w * 0.80 + math.sin(t * 0.4 + 1.2) * w * 0.10,
        y: h * 0.15 + math.cos(t * 0.6 + 0.8) * h * 0.12,
        radius: w * 0.22,
        opacity: 0.10,
      ),
      _Orb(
        x: w * 0.65 + math.sin(t * 0.9 + 2.5) * w * 0.08,
        y: h * 0.72 + math.cos(t * 0.3 + 1.5) * h * 0.08,
        radius: w * 0.20,
        opacity: 0.08,
      ),
      _Orb(
        x: w * 0.25 + math.sin(t * 0.5 + 3.1) * w * 0.09,
        y: h * 0.78 + math.cos(t * 0.8 + 0.3) * h * 0.06,
        radius: w * 0.18,
        opacity: 0.07,
      ),
    ];

    for (final orb in orbs) {
      final paint = Paint()
        ..color = accentColor.withOpacity(orb.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, orb.radius * 0.6);
      canvas.drawCircle(Offset(orb.x, orb.y), orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.progress != progress || old.accentColor != accentColor;
}

class _Orb {
  final double x, y, radius, opacity;
  const _Orb({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}
