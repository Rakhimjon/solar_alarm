import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/habit.dart';

class HabitLocalDataSource {
  static const String _keyHabits = 'solar_habits_v1';
  final SharedPreferences prefs;

  HabitLocalDataSource({required this.prefs});

  Future<List<Habit>> getHabits() async {
    final raw = prefs.getString(_keyHabits);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => Habit.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final list = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHabits, jsonEncode(list));
  }
}
