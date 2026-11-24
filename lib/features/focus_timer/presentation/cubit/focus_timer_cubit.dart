import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/core/services/kiosk_service.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';
import 'focus_timer_state.dart';

class FocusTimerCubit extends Cubit<FocusTimerState> {
  final PlannerCubit plannerCubit;
  final KioskService kioskService;
  Timer? _ticker;

  FocusTimerCubit({
    required this.plannerCubit,
    required this.kioskService,
  }) : super(const FocusTimerState());

  void toggleDeepWork(bool value) {
    emit(state.copyWith(isDeepWorkEnabled: value));
  }

  void clearWarning() {
    emit(state.copyWith(clearWarning: true));
  }

  void setDurationMinutes(int minutes) {
    if (state.status == FocusStatus.running) return;
    final sec = minutes * 60;
    emit(state.copyWith(
      status: FocusStatus.idle,
      totalSeconds: sec,
      remainingSeconds: sec,
      clearWarning: true,
    ));
  }

  void attachTask(String? taskId, String? taskTitle) {
    emit(state.copyWith(
      activeTaskId: taskId,
      activeTaskTitle: taskTitle,
    ));
  }

  void start() async {
    if (state.status == FocusStatus.running) return;

    bool locked = false;
    if (state.isDeepWorkEnabled) {
      locked = await kioskService.startLock();
    }

    emit(state.copyWith(
      status: FocusStatus.running,
      isLocked: locked,
      clearWarning: true,
    ));

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() async {
    _ticker?.cancel();
    if (state.isLocked) {
      await kioskService.stopLock();
    }
    emit(state.copyWith(
      status: FocusStatus.paused,
      isLocked: false,
    ));
  }

  void reset() async {
    _ticker?.cancel();
    if (state.isLocked) {
      await kioskService.stopLock();
    }
    emit(state.copyWith(
      status: FocusStatus.idle,
      remainingSeconds: state.totalSeconds,
      isLocked: false,
      clearWarning: true,
    ));
  }

  void handleAppLifecycleBackground() async {
    if (state.status == FocusStatus.running) {
      _ticker?.cancel();
      if (state.isLocked) {
        await kioskService.stopLock();
      }
      emit(state.copyWith(
        status: FocusStatus.paused,
        isLocked: false,
        warningMessage: '⚠️ Ilovadan chiqildi! Fokus to\'xtatildi.',
      ));
    }
  }

  void _tick() async {
    if (state.remainingSeconds > 1) {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    } else {
      _ticker?.cancel();
      if (state.isLocked) {
        await kioskService.stopLock();
      }
      final finishedMinutes = state.totalSeconds ~/ 60;
      if (state.activeTaskId != null) {
        plannerCubit.recordFocusMinutes(state.activeTaskId!, finishedMinutes);
      }
      emit(state.copyWith(
        status: FocusStatus.completed,
        remainingSeconds: 0,
        isLocked: false,
      ));
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    kioskService.stopLock();
    return super.close();
  }
}
