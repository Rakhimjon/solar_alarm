import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/plan_task.dart';
import '../../domain/repositories/plan_repository.dart';
import 'planner_state.dart';

class PlannerCubit extends Cubit<PlannerState> {
  final PlanRepository repository;

  PlannerCubit({required this.repository}) : super(const PlannerState()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    emit(state.copyWith(status: PlannerStatus.loading));
    final tasks = await repository.getTasks();
    emit(state.copyWith(status: PlannerStatus.loaded, tasks: tasks));
  }

  Future<PlanTask?> createTask(
    String title,
    int targetMinutes, {
    String? category,
    bool useTimer = true,
  }) async {
    if (title.trim().isEmpty) return null;
    final task = PlanTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      targetMinutes: targetMinutes,
      category: category,
      useTimer: useTimer,
      createdAt: DateTime.now(),
    );
    await repository.saveTask(task);
    await loadTasks();
    return task;
  }

  Future<void> toggleDone(String id) async {
    await repository.toggleTaskCompletion(id);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await repository.deleteTask(id);
    if (state.activeTaskId == id) {
      emit(state.copyWith(clearActiveTask: true));
    }
    await loadTasks();
  }

  void setActiveTask(String? id) {
    emit(state.copyWith(activeTaskId: id, clearActiveTask: id == null));
  }

  Future<void> recordFocusMinutes(String id, int minutes) async {
    await repository.addFocusDuration(id, minutes);
    await loadTasks();
  }
}
