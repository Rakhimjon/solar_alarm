import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/plan_task.dart';

class PlannerLocalDataSource {
  static const String _keyTasks = 'solar_planner_tasks_v1';
  final SharedPreferences prefs;

  PlannerLocalDataSource({required this.prefs});

  Future<List<PlanTask>> getTasks() async {
    final raw = prefs.getString(_keyTasks);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) {
        final map = item as Map<String, dynamic>;
        return PlanTask(
          id: map['id'] as String,
          title: map['title'] as String,
          targetMinutes: (map['targetMinutes'] as num?)?.toInt() ?? 25,
          completedMinutes: (map['completedMinutes'] as num?)?.toInt() ?? 0,
          isCompleted: map['isCompleted'] as bool? ?? false,
          createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
              DateTime.now(),
          category: map['category'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<PlanTask> tasks) async {
    final list = tasks.map((t) => {
          'id': t.id,
          'title': t.title,
          'targetMinutes': t.targetMinutes,
          'completedMinutes': t.completedMinutes,
          'isCompleted': t.isCompleted,
          'createdAt': t.createdAt.toIso8601String(),
          'category': t.category,
        }).toList();

    await prefs.setString(_keyTasks, jsonEncode(list));
  }
}
