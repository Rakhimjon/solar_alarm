import '../../domain/entities/plan_task.dart';

enum PlannerStatus { initial, loading, loaded, error }

class PlannerState {
  final PlannerStatus status;
  final List<PlanTask> tasks;
  final String? activeTaskId;
  final String? message;

  const PlannerState({
    this.status = PlannerStatus.initial,
    this.tasks = const [],
    this.activeTaskId,
    this.message,
  });

  PlanTask? get activeTask {
    if (activeTaskId == null) return null;
    try {
      return tasks.firstWhere((t) => t.id == activeTaskId);
    } catch (_) {
      return null;
    }
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get totalMinutesFocused =>
      tasks.fold(0, (acc, t) => acc + t.completedMinutes);

  PlannerState copyWith({
    PlannerStatus? status,
    List<PlanTask>? tasks,
    String? activeTaskId,
    String? message,
    bool clearActiveTask = false,
  }) {
    return PlannerState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      activeTaskId: clearActiveTask
          ? null
          : (activeTaskId ?? this.activeTaskId),
      message: message,
    );
  }
}
