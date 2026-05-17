

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mood_tracker/controllers/mood_controller.dart';
import 'package:mood_tracker/models/mood_entry.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  group('MoodController', () {
    test('initial state is empty and not loading after init', () async {
      final ctrl = MoodController();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(ctrl.entries, isEmpty);
      expect(ctrl.isLoading.value, false);
    });

    test('selectMood sets selectedMood', () {
      final ctrl = MoodController();
      ctrl.selectMood(MoodType.happy);
      expect(ctrl.selectedMood.value, MoodType.happy);
    });

    test('logMood adds entry and clears selection', () async {
      final ctrl = MoodController();
      ctrl.selectMood(MoodType.happy);
      await ctrl.logMood();
      expect(ctrl.entries.length, 1);
      expect(ctrl.entries.first.moodType, MoodType.happy);
      expect(ctrl.selectedMood.value, isNull);
    });

    test('logMood is no-op when no mood selected', () async {
      final ctrl = MoodController();
      await ctrl.logMood();
      expect(ctrl.entries, isEmpty);
    });

    test('timelineEntries is capped at 7', () async {
      final ctrl = MoodController();
      for (final mood in [
        ...MoodType.values,
        ...MoodType.values,
        MoodType.happy,
        MoodType.sad,
      ]) {
        ctrl.selectMood(mood);
        await ctrl.logMood();
      }
      expect(ctrl.timelineEntries.length,
          lessThanOrEqualTo(MoodController.timelineLimit));
    });

    test('tapTimelineEntry sets and toggles highlight', () async {
      final ctrl = MoodController();
      ctrl.selectMood(MoodType.neutral);
      await ctrl.logMood();
      final entry = ctrl.entries.first;

      ctrl.tapTimelineEntry(entry);
      expect(ctrl.highlightedEntry.value, entry);

      ctrl.tapTimelineEntry(entry);
      expect(ctrl.highlightedEntry.value, isNull);
    });

    test('deleteEntry removes entry', () async {
      final ctrl = MoodController();
      ctrl.selectMood(MoodType.sad);
      await ctrl.logMood();
      final id = ctrl.entries.first.id;
      await ctrl.deleteEntry(id);
      expect(ctrl.entries, isEmpty);
    });
  });

  group('MoodEntry serialisation', () {
    test('round-trips through JSON', () {
      final entry = MoodEntry(
        id: '123',
        moodType: MoodType.verySad,
        timestamp: DateTime(2024, 5, 1, 10, 30),
      );
      final restored = MoodEntry.fromJson(entry.toJson());
      expect(restored.id, entry.id);
      expect(restored.moodType, entry.moodType);
      expect(restored.timestamp, entry.timestamp);
    });
  });
}
