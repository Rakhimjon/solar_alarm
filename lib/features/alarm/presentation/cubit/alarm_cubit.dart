import 'dart:async';
import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/alarm_item.dart';
import '../../domain/repositories/alarm_repository.dart';
import 'alarm_state.dart';

class AlarmCubit extends Cubit<AlarmState> {
  final AlarmRepository repository;
  StreamSubscription? _ringSubscription;

  AlarmCubit({required this.repository}) : super(const AlarmState()) {
    loadAlarms();
    _initRingListener();
  }

  void _initRingListener() {
    _ringSubscription = Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isNotEmpty) {
        final ringingAlarm = alarmSet.alarms.first;
        final match = state.alarms.where((a) => a.id == ringingAlarm.id).firstOrNull;

        final rand = Random();
        final op1 = 15 + rand.nextInt(35);
        final op2 = 12 + rand.nextInt(40);

        emit(state.copyWith(
          ringingAlarmId: ringingAlarm.id,
          ringingAlarmLabel: match?.label ?? ringingAlarm.notificationSettings.title,
          ringingRequireMath: match?.requireMathMission ?? false,
          mathOperand1: op1,
          mathOperand2: op2,
        ));
      } else if (state.isRinging) {
        emit(state.copyWith(clearRinging: true));
      }
    });
  }

  Future<void> loadAlarms() async {
    emit(state.copyWith(isLoading: true));
    final alarms = await repository.getAlarms();
    alarms.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    emit(state.copyWith(alarms: alarms, isLoading: false));
  }

  Future<void> saveAlarm({
    required int hour,
    required int minute,
    required String label,
    required String soundPath,
    required String soundTitle,
    required List<int> repeatDays,
    required bool vibrate,
    bool requireMathMission = false,
    String? linkedSolarType,
    int solarOffsetMinutes = 0,
    int? existingId,
  }) async {
    final id = existingId ?? DateTime.now().millisecondsSinceEpoch % 100000;
    final alarm = AlarmItem(
      id: id,
      hour: hour,
      minute: minute,
      label: label.isEmpty ? 'Budilnik' : label,
      soundPath: soundPath,
      soundTitle: soundTitle,
      repeatDays: repeatDays,
      vibrate: vibrate,
      requireMathMission: requireMathMission,
      linkedSolarType: linkedSolarType,
      solarOffsetMinutes: solarOffsetMinutes,
      isEnabled: true,
    );

    await repository.saveAlarm(alarm);
    await loadAlarms();
    emit(state.copyWith(message: 'Budilnik saqlandi'));
  }

  Future<void> toggleAlarm(int id) async {
    await repository.toggleAlarm(id);
    await loadAlarms();
  }

  Future<void> deleteAlarm(int id) async {
    await repository.deleteAlarm(id);
    await loadAlarms();
    emit(state.copyWith(message: 'Budilnik o\'chirildi'));
  }

  bool verifyMathAndDismiss(int userAnswer) {
    if (userAnswer == state.mathAnswer) {
      dismissRinging();
      return true;
    }
    return false;
  }

  Future<void> dismissRinging() async {
    final id = state.ringingAlarmId;
    if (id != null) {
      await repository.stopRinging(id);
    }
    emit(state.copyWith(clearRinging: true));
  }

  Future<void> snoozeRinging({int minutes = 5}) async {
    final id = state.ringingAlarmId;
    if (id != null) {
      await repository.snoozeAlarm(id, minutes: minutes);
    }
    emit(state.copyWith(
      clearRinging: true,
      message: 'Budilnik $minutes daqiqaga kechiktirildi',
    ));
  }

  @override
  Future<void> close() {
    _ringSubscription?.cancel();
    return super.close();
  }
}
