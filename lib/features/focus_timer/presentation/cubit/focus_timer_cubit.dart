import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';
import 'focus_timer_state.dart';

class FocusTimerCubit extends Cubit<FocusTimerState> {
  final PlannerCubit plannerCubit;
  Timer? _ticker;

  FocusTimerCubit({required this.plannerCubit})
      : super(const FocusTimerState());

  void setDurationMinutes(int minutes) {
    if (state.status == FocusStatus.running) return;
    final sec = minutes * 60;
    emit(state.copyWith(
      status: FocusStatus.idle,
      totalSeconds: sec,
      remainingSeconds: sec,
    ));
  }

  void attachTask(String? taskId, String? taskTitle) {
    emit(state.copyWith(
      activeTaskId: taskId,
      activeTaskTitle: taskTitle,
    ));
  }

  void start() {
    if (state.status == FocusStatus.running) return;
    emit(state.copyWith(status: FocusStatus.running));
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _ticker?.cancel();
    emit(state.copyWith(status: FocusStatus.paused));
  }

  void reset() {
    _ticker?.cancel();
    emit(state.copyWith(
      status: FocusStatus.idle,
      remainingSeconds: state.totalSeconds,
    ));
  }

  void _tick() {
    if (state.remainingSeconds > 1) {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    } else {
      _ticker?.cancel();
      final finishedMinutes = state.totalSeconds ~/ 60;
      if (state.activeTaskId != null) {
        plannerCubit.recordFocusMinutes(state.activeTaskId!, finishedMinutes);
      }
      emit(state.copyWith(
        status: FocusStatus.completed,
        remainingSeconds: 0,
      ));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
