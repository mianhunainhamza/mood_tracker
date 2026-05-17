import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/mood_controller.dart';
import '../models/mood_entry.dart';
import 'mood_face_widget.dart';

class MoodPickerSection extends StatelessWidget {
  final MoodController controller;

  const MoodPickerSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'How are you feeling?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a face to select, then log it.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 28),

        Obx(
          () => Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: MoodType.values.mapIndexed((index, mood) {
              final isSelected = controller.selectedMood.value == mood;
              return _MoodOption(
                key: ValueKey(mood),
                mood: mood,
                isSelected: isSelected,
                entranceIndex: index,
                onTap: () => controller.selectMood(mood),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 32),

        _LogButton(controller: controller),
      ],
    );
  }
}

extension _IndexedMap<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) f) sync* {
    var i = 0;
    for (final item in this) {
      yield f(i++, item);
    }
  }
}

class _MoodOption extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final int entranceIndex;
  final VoidCallback onTap;

  const _MoodOption({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.entranceIndex,
    required this.onTap,
  });

  @override
  State<_MoodOption> createState() => _MoodOptionState();
}

class _MoodOptionState extends State<_MoodOption>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final AnimationController _rippleController;
  late final Animation<double> _rippleAnim;
  late final AnimationController _pressController;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: widget.entranceIndex * 80), () {
      if (mounted) _entranceController.forward();
    });

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rippleAnim = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _rippleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _pressController.forward().then((_) => _pressController.reverse());
    _rippleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.mood.color;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pressAnim, _rippleAnim]),
            builder: (_, child) {
              return Transform.scale(
                scale: _pressAnim.value,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (_rippleController.isAnimating || _rippleAnim.value > 0)
                      ..._buildRippleParticles(color),

                    // The card itself
                    child!,
                  ],
                ),
              );
            },
            child: _buildCard(color),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? color.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isSelected ? color : Colors.white12,
          width: widget.isSelected ? 2.0 : 1.0,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          MoodFaceWidget(
            moodType: widget.mood,
            size: 64,
            isSelected: widget.isSelected,
            animate: false,
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight:
                  widget.isSelected ? FontWeight.w700 : FontWeight.w500,
              color: widget.isSelected ? color : Colors.white54,
            ),
            child: Text(widget.mood.label),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRippleParticles(Color color) {
    final t = _rippleAnim.value; // 0 → 1
    const particleCount = 8;
    const maxRadius = 55.0;

    return List.generate(particleCount, (i) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = t * maxRadius;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      final particleSize = (4.0 * (1.0 - t * 0.5)).clamp(1.0, 4.0);

      return Positioned(
        left: 55 + math.cos(angle) * distance - particleSize / 2,
        top: 55 + math.sin(angle) * distance - particleSize / 2,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: particleSize,
            height: particleSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }
}


class _LogButton extends StatefulWidget {
  final MoodController controller;

  const _LogButton({required this.controller});

  @override
  State<_LogButton> createState() => _LogButtonState();
}

class _LogButtonState extends State<_LogButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _successController;
  late final Animation<double> _successAnim;

  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  Future<void> _handleLog() async {
    if (widget.controller.selectedMood.value == null) return;

    setState(() => _showSuccess = true);
    await _successController.forward(from: 0);

    await widget.controller.logMood();

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      await _successController.reverse();
      if (mounted) setState(() => _showSuccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedMood = widget.controller.selectedMood.value;

      final hasSelection = selectedMood != null;

      final accentColor =
      hasSelection ? selectedMood.color : Colors.white24;

      return AnimatedBuilder(
        animation: _successAnim,
        builder: (_, __) {
          final successScale = _showSuccess
              ? 1.0 + _successAnim.value * 0.08
              : 1.0;

          return Transform.scale(
            scale: successScale,
            child: GestureDetector(
              onTap: hasSelection && !_showSuccess
                  ? _handleLog
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _showSuccess
                      ? const Color(0xFF06D6A0)
                      : (hasSelection
                      ? accentColor
                      : Colors.transparent),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: _showSuccess
                        ? const Color(0xFF06D6A0)
                        : accentColor,
                    width: 2,
                  ),
                  boxShadow: hasSelection
                      ? [
                    BoxShadow(
                      color: (_showSuccess
                          ? const Color(0xFF06D6A0)
                          : accentColor)
                          .withOpacity(0.45),
                      blurRadius: _showSuccess ? 28 : 20,
                      spreadRadius: _showSuccess ? 4 : 2,
                    )
                  ]
                      : [],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _showSuccess
                      ? Row(
                    key: const ValueKey('success'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.black87,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Logged!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    key: const ValueKey('label'),
                    hasSelection
                        ? 'Log ${selectedMood.label}'
                        : 'Select a mood',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: hasSelection
                          ? Colors.black87
                          : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
