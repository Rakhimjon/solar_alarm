import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/core/services/kiosk_service.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'focus_timer_state.dart';

class FocusTimerCubit extends Cubit<FocusTimerState> {
  final PlannerCubit plannerCubit;
  final KioskService kioskService;
  Timer? _ticker;
  DateTime? _targetEndTime;

  FocusTimerCubit({required this.plannerCubit, required this.kioskService})
    : super(const FocusTimerState());

  Future<void> _setWakelock(bool enable) async {
    try {
      if (enable) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Safe fallback for tests / unsupported environments
    }
  }

  void toggleDeepWork(bool value) {
    emit(state.copyWith(isDeepWorkEnabled: value));
  }

  void clearWarning() {
    emit(state.copyWith(clearWarning: true));
  }

  void setDurationMinutes(int minutes) {
    if (state.status == FocusStatus.running) return;
    final sec = minutes * 60;
    _targetEndTime = null;
    emit(
      state.copyWith(
        status: FocusStatus.idle,
        totalSeconds: sec,
        remainingSeconds: sec,
        clearWarning: true,
      ),
    );
  }

  void attachTask(String? taskId, String? taskTitle) {
    emit(
      state.copyWith(
        activeTaskId: taskId,
        activeTaskTitle: taskTitle,
        clearActiveTask: taskId == null,
      ),
    );
  }

  void start() async {
    if (state.status == FocusStatus.running) return;

    bool locked = false;
    if (state.isDeepWorkEnabled) {
      locked = await kioskService.startLock();
    }

    if (isClosed) return;

    _targetEndTime = DateTime.now().add(
      Duration(seconds: state.remainingSeconds),
    );

    emit(
      state.copyWith(
        status: FocusStatus.running,
        isLocked: locked,
        clearWarning: true,
      ),
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    unawaited(_setWakelock(true));
  }

  void pause() async {
    _ticker?.cancel();
    _targetEndTime = null;
    if (state.isLocked) {
      await kioskService.stopLock();
    }
    if (isClosed) return;
    unawaited(_setWakelock(false));
    emit(state.copyWith(status: FocusStatus.paused, isLocked: false));
  }

  void reset() async {
    _ticker?.cancel();
    _targetEndTime = null;
    if (state.isLocked) {
      await kioskService.stopLock();
    }
    if (isClosed) return;
    unawaited(_setWakelock(false));
    emit(
      state.copyWith(
        status: FocusStatus.idle,
        remainingSeconds: state.totalSeconds,
        isLocked: false,
        clearWarning: true,
      ),
    );
  }

  void handleAppLifecycleBackground() {
    handleAppLifecycleState(AppLifecycleState.paused);
  }

  void handleAppLifecycleState(AppLifecycleState lifecycle) async {
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.hidden) {
      if (state.status == FocusStatus.running) {
        if (state.isDeepWorkEnabled) {
          _ticker?.cancel();
          _targetEndTime = null;
          if (state.isLocked) {
            await kioskService.stopLock();
          }
          if (isClosed) return;
          unawaited(_setWakelock(false));
          emit(
            state.copyWith(
              status: FocusStatus.paused,
              isLocked: false,
              warningMessage: '⚠️ Ilovadan chiqildi! Fokus to\'xtatildi.',
            ),
          );
        } else {
          // Normal mode: keep running across background; temporarily disable wakelock
          unawaited(_setWakelock(false));
        }
      }
    } else if (lifecycle == AppLifecycleState.resumed) {
      if (state.status == FocusStatus.running) {
        unawaited(_setWakelock(true));
        if (_targetEndTime != null) {
          final remaining = _targetEndTime!
              .difference(DateTime.now())
              .inSeconds;
          if (remaining <= 0) {
            _finishSession();
          } else {
            if (isClosed) return;
            emit(state.copyWith(remainingSeconds: remaining));
            _ticker?.cancel();
            _ticker = Timer.periodic(
              const Duration(seconds: 1),
              (_) => _tick(),
            );
          }
        }
      }
    }
  }

  void _finishSession() async {
    _ticker?.cancel();
    _targetEndTime = null;
    if (state.isLocked) {
      await kioskService.stopLock();
    }
    unawaited(_setWakelock(false));
    final finishedMinutes = state.totalSeconds ~/ 60;
    if (state.activeTaskId != null) {
      try {
        await plannerCubit.recordFocusMinutes(
          state.activeTaskId!,
          finishedMinutes,
        );
      } catch (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            warningMessage: 'Fokus tugadi, lekin reja saqlanmadi.',
          ),
        );
      }
    }
    if (isClosed) return;
    emit(
      state.copyWith(
        status: FocusStatus.completed,
        remainingSeconds: 0,
        isLocked: false,
      ),
    );
  }

  void _tick() {
    if (_targetEndTime == null) return;
    final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
    if (remaining > 0) {
      emit(state.copyWith(remainingSeconds: remaining));
    } else {
      _finishSession();
    }
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _targetEndTime = null;
    _setWakelock(false);
    kioskService.stopLock();
    return super.close();
  }
}
