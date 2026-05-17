// lib/models/mood_entry.dart
//
// Immutable data model for a single mood log entry.
// Keeps business data decoupled from UI and state layers.
// Serializes to/from JSON for SharedPreferences persistence.

import 'package:flutter/material.dart';

/// Enum representing the five distinct mood states the user can log.
/// Each carries a semantic label, a canvas color, and a display name.
enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
}

/// Extension so enum values carry their own UI metadata.
/// Avoids switch-statements scattered through UI code.
extension MoodTypeX on MoodType {
  String get label {
    switch (this) {
      case MoodType.veryHappy:
        return 'Ecstatic';
      case MoodType.happy:
        return 'Happy';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.verySad:
        return 'Awful';
    }
  }

  /// Primary accent color associated with each mood — used in
  /// timeline cards, glow effects, and background tints.
  Color get color {
    switch (this) {
      case MoodType.veryHappy:
        return const Color(0xFFFFD166); // warm gold
      case MoodType.happy:
        return const Color(0xFF06D6A0); // mint green
      case MoodType.neutral:
        return const Color(0xFF90A4AE); // blue-grey
      case MoodType.sad:
        return const Color(0xFF64B5F6); // soft blue
      case MoodType.verySad:
        return const Color(0xFFE07A7A); // muted rose
    }
  }

  /// Serialisation key stored in SharedPreferences JSON.
  String get key => name;

  static MoodType fromKey(String key) =>
      MoodType.values.firstWhere((e) => e.name == key,
          orElse: () => MoodType.neutral);
}

/// Single mood log entry — immutable value object.
///
/// [id]        : unique identifier (timestamp-based)
/// [moodType]  : which mood was selected
/// [timestamp] : when the entry was created
/// [note]      : optional user note (future feature, stored but unused)
class MoodEntry {
  final String id;
  final MoodType moodType;
  final DateTime timestamp;
  final String? note;

  const MoodEntry({
    required this.id,
    required this.moodType,
    required this.timestamp,
    this.note,
  });

  // ---------------------------------------------------------------------------
  // Serialisation
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'id': id,
        'moodType': moodType.key,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        id: json['id'] as String,
        moodType: MoodTypeX.fromKey(json['moodType'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
      );

  // ---------------------------------------------------------------------------
  // Value equality — important for GetX reactive list comparisons
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodEntry && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MoodEntry(id: $id, mood: ${moodType.label}, ts: $timestamp)';
}
