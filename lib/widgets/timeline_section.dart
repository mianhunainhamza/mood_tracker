
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

      if (entries.isEmpty) {
        return _EmptyTimeline();
      }

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
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entries.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 170,
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
                    entry: entry,
                    isHighlighted: isHighlighted,
                    isNewest: index == 0,
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


class _TimelineCard extends StatelessWidget {
  final MoodEntry entry;
  final bool isHighlighted;
  final bool isNewest;
  final VoidCallback onTap;

  const _TimelineCard({
    required this.entry,
    required this.isHighlighted,
    required this.isNewest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = entry.moodType.color;
    final date = entry.timestamp;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 120,
        decoration: BoxDecoration(
          color: isHighlighted
              ? color.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted ? color : Colors.white12,
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: isHighlighted
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
            Container(
              height: 5,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isNewest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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

                    MoodFaceWidget(
                      moodType: entry.moodType,
                      size: 60,
                      animate: isHighlighted,
                    ),

                    Text(
                      entry.moodType.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isHighlighted ? color : Colors.white70,
                      ),
                    ),

                    Column(
                      children: [
                        Text(
                          DateFormat('EEE, MMM d').format(date),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: Colors.white30,
                          ),
                        ),
                        Text(
                          DateFormat('h:mm a').format(date),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            color: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _EmptyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
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
              fontSize: 13,
              color: Colors.white30,
            ),
          ),
        ],
      ),
    );
  }
}
