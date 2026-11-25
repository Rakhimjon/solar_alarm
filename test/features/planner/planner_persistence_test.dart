import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_alarm/features/planner/data/datasources/planner_local_datasource.dart';
import 'package:solar_alarm/features/planner/data/repositories/plan_repository_impl.dart';
import 'package:solar_alarm/features/planner/domain/entities/plan_task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late PlanRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = PlanRepositoryImpl(
      localDataSource: PlannerLocalDataSource(prefs: prefs),
    );
  });

  test('No-timer task and direct completion persist', () async {
    final task = PlanTask(
      id: 'plain',
      title: 'Oddiy reja',
      useTimer: false,
      createdAt: DateTime(2026, 11, 25),
    );
    await repository.saveTask(task);
    await repository.toggleTaskCompletion(task.id);

    final restored = await repository.getTasks();

    expect(restored.single.useTimer, isFalse);
    expect(restored.single.isCompleted, isTrue);
  });

  test(
    'Timed task completes and persists after target focus minutes',
    () async {
      final task = PlanTask(
        id: 'timed',
        title: 'Timerli reja',
        targetMinutes: 25,
        createdAt: DateTime(2026, 11, 25),
      );
      await repository.saveTask(task);

      await repository.addFocusDuration(task.id, 10);
      expect((await repository.getTasks()).single.isCompleted, isFalse);

      await repository.addFocusDuration(task.id, 15);
      final restored = await repository.getTasks();

      expect(restored.single.completedMinutes, 25);
      expect(restored.single.isCompleted, isTrue);
      expect(restored.single.useTimer, isTrue);
    },
  );
}
