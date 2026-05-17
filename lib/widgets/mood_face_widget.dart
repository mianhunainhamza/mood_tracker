
import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import 'painters/mood_face_painter.dart';

class MoodFaceWidget extends StatefulWidget {
  final MoodType moodType;
  final double size;

  final bool animate;

  final bool isSelected;

  const MoodFaceWidget({
    super.key,
    required this.moodType,
    this.size = 80,
    this.animate = false,
    this.isSelected = false,
  });

  @override
  State<MoodFaceWidget> createState() => _MoodFaceWidgetState();
}

class _MoodFaceWidgetState extends State<MoodFaceWidget>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final Animation<double> _breathAnim;

  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Breathing: 3s loop
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _breathAnim = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    );

    // Bounce: 700ms elastic spring
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bounceAnim = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );
    if (widget.isSelected) _bounceController.forward(from: 0);

    // Pulse: 600ms forward/reverse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    if (widget.animate) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void didUpdateWidget(MoodFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected && !oldWidget.isSelected) {
      _bounceController.forward(from: 0);
    }
    if (!widget.isSelected && oldWidget.isSelected) {
      _bounceController.reverse();
    }
    if (widget.animate && !oldWidget.animate) {
      _pulseController.forward(from: 0).then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathAnim, _bounceAnim, _pulseAnim]),
      builder: (_, __) {
        // Breathing: ±2.5% when selected, ±1.2% at idle
        final breathScale = widget.isSelected
            ? 1.0 + _breathAnim.value * 0.025
            : 1.0 + _breathAnim.value * 0.012;

        // Bounce: face grows from 85% → 100% with elastic overshoot
        final bounceScale = (widget.isSelected || _bounceAnim.value > 0)
            ? 0.85 + _bounceAnim.value * 0.15
            : 1.0;

        return Transform.scale(
          scale: breathScale * bounceScale,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: MoodFacePainter(
              moodType: widget.moodType,
              progress: _pulseAnim.value,
              breathProgress: _breathAnim.value,
              isSelected: widget.isSelected,
            ),
          ),
        );
      },
    );
  }
}
