
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
            children: MoodType.values.map((mood) {
              final isSelected = controller.selectedMood.value == mood;
              return _MoodOption(
                mood: mood,
                isSelected: isSelected,
                onTap: () => controller.selectMood(mood),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 32),

        Obx(
          () {
            final hasSelection = controller.selectedMood.value != null;
            final accentColor = hasSelection
                ? controller.selectedMood.value!.color
                : Colors.white24;

            return AnimatedScale(
              scale: hasSelection ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: hasSelection ? controller.logMood : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 16),
                  decoration: BoxDecoration(
                    color: hasSelection ? accentColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: accentColor,
                      width: 2,
                    ),
                    boxShadow: hasSelection
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.45),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    hasSelection
                        ? 'Log ${controller.selectedMood.value!.label}'
                        : 'Select a mood',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color:
                          hasSelection ? Colors.black87 : Colors.white38,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodOption({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = mood.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.30),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.10 : 1.0,
              duration: const Duration(milliseconds: 220),
              child: MoodFaceWidget(
                moodType: mood,
                size: 64,
                animate: isSelected,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mood.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
