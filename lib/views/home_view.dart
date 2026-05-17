// lib/views/home_view.dart
//
// Single screen of the app.
// Uses GetView<MoodController> — the idiomatic GetX pattern for views that
// depend on exactly one controller.  `controller` is a getter that calls
// Get.find<MoodController>() under the hood.
//
// Layout (top→bottom):
//   1. App bar with gradient header
//   2. Mood picker section (five drawn faces)
//   3. Horizontal timeline (past 7 entries)
//   4. Subtle footer note

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/mood_controller.dart';
import '../widgets/mood_picker_section.dart';
import '../widgets/timeline_section.dart';

class HomeView extends GetView<MoodController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // deep github-night dark
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white38),
          );
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 900 ? 820.0 : screenWidth;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: SizedBox(
          width: contentWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 56),

                _Header(),

                const SizedBox(height: 48),

                MoodPickerSection(controller: controller),

                const SizedBox(height: 48),
                const _SectionDivider(),

                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TimelineSection(controller: controller),
                ),

                const SizedBox(height: 60),

                _Footer(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD166), Color(0xFF06D6A0)],
          ).createShader(bounds),
          child: const Icon(
            Icons.favorite_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mood Tracker',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A mindful log of how you\'re doing.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Colors.white12, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Timeline',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white24,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Colors.white12, thickness: 1),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Your mood history is stored locally in your browser.',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        color: Colors.white30,
      ),
      textAlign: TextAlign.center,
    );
  }
}
