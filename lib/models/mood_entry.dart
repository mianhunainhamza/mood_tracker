import 'package:flutter/material.dart';

enum MoodType {
  veryHappy,
  happy,
  neutral,
  sad,
  verySad,
}

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

  Color get color {
    switch (this) {
      case MoodType.veryHappy:
        return const Color(0xFFFFD166);
      case MoodType.happy:
        return const Color(0xFF06D6A0);
      case MoodType.neutral:
        return const Color(0xFF90A4AE);
      case MoodType.sad:
        return const Color(0xFF64B5F6);
      case MoodType.verySad:
        return const Color(0xFFE07A7A);
    }
  }

  String get key => name;

  static MoodType fromKey(String key) =>
      MoodType.values.firstWhere((e) => e.name == key,
          orElse: () => MoodType.neutral);
}

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
