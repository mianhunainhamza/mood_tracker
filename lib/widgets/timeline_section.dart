// lib/widgets/timeline_section.dart
//
// Animation upgrades in this file:
//
//   _TimelineCard — now StatefulWidget with:
//     • Slide-in from right + fade on first build (entrance)
//     • Floating lift (translateY -4px) + scale-up when highlighted
//     • Shimmer sweep effect across card on highlight
//     • Smooth AnimatedContainer transitions on all decoration properties

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/mood_controller.dart';
import '../models/mood_entry.dart';
import 'mood_face_widget.dart';

class TimelineSection extends StatelessWidget {
  final MoodController controller;

  const TimelineSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = controller.timelineEntries;

      if (entries.isEmpty) return _EmptyTimeline();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  'Past 7 Entries',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entries.length}',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final entry = entries[index];
                return Obx(() {
                  final isHighlighted =
                      controller.highlightedEntry.value?.id == entry.id;
                  return _TimelineCard(
                    key: ValueKey(entry.id),
                    entry: entry,
                    isHighlighted: isHighlighted,
                    isNewest: index == 0,
                    entranceDelay: Duration(milliseconds: index * 60),
                    onTap: () => controller.tapTimelineEntry(entry),
                  );
                });
              },
            ),
          ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Timeline card — stateful for entrance + shimmer
// ---------------------------------------------------------------------------

class _TimelineCard extends StatefulWidget {
  final MoodEntry entry;
  final bool isHighlighted;
  final bool isNewest;
  final Duration entranceDelay;
  final VoidCallback onTap;

  const _TimelineCard({
    super.key,
    required this.entry,
    required this.isHighlighted,
    required this.isNewest,
    required this.entranceDelay,
    required this.onTap,
  });

  @override
  State<_TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<_TimelineCard>
    with TickerProviderStateMixin {
  // Slide-in from right on first appear
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Shimmer sweep when highlighted
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.entranceDelay, () {
      if (mounted) _entranceController.forward();
    });

    // Shimmer: sweeps left→right when highlighted
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _shimmerAnim = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    if (widget.isHighlighted) _shimmerController.forward(from: 0);
  }

  @override
  void didUpdateWidget(_TimelineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _shimmerController.forward(from: 0);
    }
    if (!widget.isHighlighted && oldWidget.isHighlighted) {
      _shimmerController.reverse();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.entry.moodType.color;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (_, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                width: 125,
                // Lift up slightly when highlighted
                transform: widget.isHighlighted
                    ? (Matrix4.identity()..translate(0.0, -4.0))
                    : Matrix4.identity(),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.isHighlighted
                      ? color.withOpacity(0.18)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isHighlighted ? color : Colors.white12,
                    width: widget.isHighlighted ? 2.0 : 1.0,
                  ),
                  boxShadow: widget.isHighlighted
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.40),
                            blurRadius: 24,
                            spreadRadius: 3,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Stack(
                    children: [
                      child!,
                      // Shimmer overlay — diagonal light sweep
                      if (_shimmerAnim.value > 0)
                        Positioned.fill(
                          child: _ShimmerOverlay(
                            progress: _shimmerAnim.value,
                            color: color,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            child: _buildCardContent(color),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(Color color) {
    final date = widget.entry.timestamp;
    return Column(
      children: [
        // Top accent strip
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.isHighlighted ? 6 : 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(19),
              topRight: Radius.circular(19),
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // NEW badge
                if (widget.isNewest)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),

                // Face with pulse on highlight
                MoodFaceWidget(
                  moodType: widget.entry.moodType,
                  size: 62,
                  animate: widget.isHighlighted,
                  isSelected: false,
                ),

                // Mood label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isHighlighted ? color : Colors.white70,
                  ),
                  child: Text(widget.entry.moodType.label),
                ),

                // Date
                Column(
                  children: [
                    Text(
                      DateFormat('EEE, MMM d').format(date),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10, color: Colors.white30),
                    ),
                    Text(
                      DateFormat('h:mm a').format(date),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 9, color: Colors.white30),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer overlay — diagonal light sweep painted on canvas
// ---------------------------------------------------------------------------

class _ShimmerOverlay extends StatelessWidget {
  final double progress; // 0 → 1
  final Color color;

  const _ShimmerOverlay({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShimmerPainter(progress: progress, color: color),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ShimmerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Sweep a diagonal light band from left to right
    final sweepX = -size.width * 0.5 + progress * size.width * 1.8;
    const bandWidth = 60.0;
    const angle = math.pi / 4; // 45°

    // Build a rotated gradient rectangle
    final rect = Rect.fromLTWH(sweepX - bandWidth / 2, 0, bandWidth, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.18),
          Colors.white.withOpacity(0.12),
          color.withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0, 0.3, 0.5, 0.7, 1],
      ).createShader(rect);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_satisfied_alt_outlined,
              color: Colors.white30, size: 32),
          const SizedBox(height: 8),
          Text(
            'No entries yet — log your first mood!',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: Colors.white30),
          ),
        ],
      ),
    );
  }
}
