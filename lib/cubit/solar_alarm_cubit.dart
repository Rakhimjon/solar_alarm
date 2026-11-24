import 'package:flutter_bloc/flutter_bloc.dart';
import '../alarm_service.dart';
import '../solar_calculator.dart';

enum SolarAlarmStatus { initial, scheduled, cancelled }

class SolarAlarmState {
  final SolarEvent event;
  final int offsetMinutes;
  final DateTime? nextAlarm;
  final SolarAlarmStatus status;
  final String? message;

  const SolarAlarmState({
    this.event = SolarEvent.sunrise,
    this.offsetMinutes = -15,
    this.nextAlarm,
    this.status = SolarAlarmStatus.initial,
    this.message,
  });

  SolarAlarmState copyWith({
    SolarEvent? event,
    int? offsetMinutes,
    DateTime? nextAlarm,
    SolarAlarmStatus? status,
    String? message,
  }) {
    return SolarAlarmState(
      event: event ?? this.event,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      nextAlarm: nextAlarm ?? this.nextAlarm,
      status: status ?? this.status,
      message: message,
    );
  }
}

class SolarAlarmCubit extends Cubit<SolarAlarmState> {
  SolarAlarmCubit() : super(const SolarAlarmState()) {
    init();
  }

  void init() {
    _calculateNextTime(state.event, state.offsetMinutes);
  }

  void changeEvent(SolarEvent event) {
    _calculateNextTime(event, state.offsetMinutes);
  }

  void changeOffset(int offsetMinutes) {
    _calculateNextTime(state.event, offsetMinutes);
  }

  void _calculateNextTime(SolarEvent event, int offsetMinutes) {
    final nextTime = SolarCalculator.getNextAlarmTime(
      lat: SolarAlarmService.defaultLat,
      lng: SolarAlarmService.defaultLng,
      event: event,
      offsetMinutes: offsetMinutes,
    );
    emit(state.copyWith(
      event: event,
      offsetMinutes: offsetMinutes,
      nextAlarm: nextTime,
    ));
  }

  Future<void> scheduleAlarm() async {
    final time = await SolarAlarmService.scheduleNextSolarAlarm(
      event: state.event,
      offsetMinutes: state.offsetMinutes,
    );
    emit(state.copyWith(
      nextAlarm: time,
      status: SolarAlarmStatus.scheduled,
      message: 'Budilnik qo\'yildi',
    ));
  }

  Future<void> cancelAlarm() async {
    await SolarAlarmService.cancelAlarm();
    emit(state.copyWith(
      status: SolarAlarmStatus.cancelled,
      message: 'Budilnik o\'chirildi',
    ));
  }
}
