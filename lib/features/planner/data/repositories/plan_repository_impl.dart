import '../../domain/entities/plan_task.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/planner_local_datasource.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlannerLocalDataSource localDataSource;

  PlanRepositoryImpl({required this.localDataSource});

  @override
  Future<List<PlanTask>> getTasks() async {
    return await localDataSource.getTasks();
  }

  @override
  Future<void> saveTask(PlanTask task) async {
    final tasks = await localDataSource.getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.insert(0, task);
    }
    await localDataSource.saveTasks(tasks);
  }

  @override
  Future<void> deleteTask(String id) async {
    final tasks = await localDataSource.getTasks();
    tasks.removeWhere((t) => t.id == id);
    await localDataSource.saveTasks(tasks);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final tasks = await localDataSource.getTasks();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final current = tasks[index];
      tasks[index] = current.copyWith(isCompleted: !current.isCompleted);
      await localDataSource.saveTasks(tasks);
    }
  }

  @override
  Future<void> addFocusDuration(String id, int minutes) async {
    final tasks = await localDataSource.getTasks();
    final index = tasks.indexWhere((t) => t.id == id);
    if (index >= 0) {
      final current = tasks[index];
      final newCompleted = current.completedMinutes + minutes;
      tasks[index] = current.copyWith(
        completedMinutes: newCompleted,
        isCompleted: newCompleted >= current.targetMinutes ? true : current.isCompleted,
      );
      await localDataSource.saveTasks(tasks);
    }
  }
}
