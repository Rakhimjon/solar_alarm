import '../entities/plan_task.dart';

abstract class PlanRepository {
  Future<List<PlanTask>> getTasks();
  Future<void> saveTask(PlanTask task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
  Future<void> addFocusDuration(String id, int minutes);
}
