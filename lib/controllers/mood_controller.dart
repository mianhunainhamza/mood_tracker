import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_entry.dart';

class MoodController extends GetxController {
  static const _storageKey = 'mood_entries_v1';

  static const int timelineLimit = 7;

  final RxList<MoodEntry> entries = <MoodEntry>[].obs;

  final Rx<MoodType?> selectedMood = Rx<MoodType?>(null);

  final Rx<MoodEntry?> highlightedEntry = Rx<MoodEntry?>(null);

  final RxBool isLoading = true.obs;

  List<MoodEntry> get timelineEntries =>
      entries.take(timelineLimit).toList(growable: false);


  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }


  void selectMood(MoodType mood) => selectedMood.value = mood;

  Future<void> logMood() async {
    final mood = selectedMood.value;
    if (mood == null) return;

    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moodType: mood,
      timestamp: DateTime.now(),
    );

    entries.insert(0, entry);

    selectedMood.value = null;

    await _saveToStorage();
  }

  void tapTimelineEntry(MoodEntry entry) {
    // Toggling: tapping the same entry dismisses the highlight.
    if (highlightedEntry.value?.id == entry.id) {
      highlightedEntry.value = null;
    } else {
      highlightedEntry.value = entry;
    }
  }

  void clearHighlight() => highlightedEntry.value = null;

  Future<void> deleteEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
    if (highlightedEntry.value?.id == id) highlightedEntry.value = null;
    await _saveToStorage();
  }


  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        entries.assignAll(list);
      }
    } catch (e) {
      entries.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
