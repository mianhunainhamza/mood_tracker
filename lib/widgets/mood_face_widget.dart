
import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import 'painters/mood_face_painter.dart';

class MoodFaceWidget extends StatefulWidget {
  final MoodType moodType;
  final double size;

  final bool animate;

  const MoodFaceWidget({
    super.key,
    required this.moodType,
    this.size = 80,
    this.animate = false,
  });

  @override
  State<MoodFaceWidget> createState() => _MoodFaceWidgetState();
}

class _MoodFaceWidgetState extends State<MoodFaceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.animate) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void didUpdateWidget(MoodFaceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward(from: 0).then((_) => _controller.reverse());
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
      animation: _animation,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: MoodFacePainter(
          moodType: widget.moodType,
          progress: _animation.value,
        ),
      ),
    );
  }
}
