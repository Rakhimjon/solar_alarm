import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_datasource.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Habit>> getHabits() async {
    return await localDataSource.getHabits();
  }

  @override
  Future<void> saveHabit(Habit habit) async {
    final habits = await localDataSource.getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      habits[index] = habit;
    } else {
      habits.insert(0, habit);
    }
    await localDataSource.saveHabits(habits);
  }

  @override
  Future<void> deleteHabit(String id) async {
    final habits = await localDataSource.getHabits();
    habits.removeWhere((h) => h.id == id);
    await localDataSource.saveHabits(habits);
  }

  @override
  Future<void> toggleCompletion(String id, DateTime date) async {
    final habits = await localDataSource.getHabits();
    final index = habits.indexWhere((h) => h.id == id);
    if (index < 0) return;

    final habit = habits[index];
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final completed = Set<String>.from(habit.completedDates);
    if (completed.contains(key)) {
      completed.remove(key);
    } else {
      completed.add(key);
    }
    habits[index] = habit.copyWith(completedDates: completed);
    await localDataSource.saveHabits(habits);
  }
}
