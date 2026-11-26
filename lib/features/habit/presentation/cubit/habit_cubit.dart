import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import 'habit_state.dart';

class HabitCubit extends Cubit<HabitState> {
  final HabitRepository repository;

  HabitCubit({required this.repository}) : super(const HabitState()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    emit(state.copyWith(status: HabitStatus.loading));
    final habits = await repository.getHabits();
    emit(state.copyWith(status: HabitStatus.loaded, habits: habits));
  }

  Future<Habit?> createHabit({
    required String name,
    required String emoji,
    required int colorValue,
    required List<int> weekdays,
  }) async {
    if (name.trim().isEmpty) return null;
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      emoji: emoji,
      colorValue: colorValue,
      weekdays: weekdays,
      createdAt: DateTime.now(),
    );
    await repository.saveHabit(habit);
    await loadHabits();
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await repository.saveHabit(habit);
    await loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await repository.deleteHabit(id);
    await loadHabits();
  }

  Future<void> toggleToday(String id) async {
    await repository.toggleCompletion(id, DateTime.now());
    await loadHabits();
  }
}
