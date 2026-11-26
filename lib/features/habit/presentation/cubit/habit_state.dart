import '../../domain/entities/habit.dart';

enum HabitStatus { initial, loading, loaded }

class HabitState {
  final HabitStatus status;
  final List<Habit> habits;
  final String? message;

  const HabitState({
    this.status = HabitStatus.initial,
    this.habits = const [],
    this.message,
  });

  HabitState copyWith({
    HabitStatus? status,
    List<Habit>? habits,
    String? message,
  }) {
    return HabitState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      message: message,
    );
  }
}
