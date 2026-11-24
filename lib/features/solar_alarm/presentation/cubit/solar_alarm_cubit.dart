import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/solar_types.dart';
import '../../domain/repositories/solar_alarm_repository.dart';
import 'solar_alarm_state.dart';

class SolarAlarmCubit extends Cubit<SolarAlarmState> {
  final SolarAlarmRepository repository;

  SolarAlarmCubit({required this.repository}) : super(const SolarAlarmState()) {
    refreshTimes();
  }

  void refreshTimes() {
    _calculateNext(state.event, state.offsetMinutes);
  }

  void changeEvent(SolarEvent event) {
    _calculateNext(event, state.offsetMinutes);
  }

  void changeOffset(int offsetMinutes) {
    _calculateNext(state.event, offsetMinutes);
  }

  void _calculateNext(SolarEvent event, int offsetMinutes) {
    final nextTime = repository.calculateNextAlarmTime(
      lat: state.lat,
      lng: state.lng,
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
    final time = await repository.scheduleAlarm(
      lat: state.lat,
      lng: state.lng,
      event: state.event,
      offsetMinutes: state.offsetMinutes,
    );
    emit(state.copyWith(
      nextAlarm: time,
      status: SolarAlarmStatus.scheduled,
      message: 'Budilnik muvaffaqiyatli qo\'yildi',
    ));
  }

  Future<void> cancelAlarm() async {
    await repository.cancelAlarm();
    emit(state.copyWith(
      status: SolarAlarmStatus.cancelled,
      message: 'Budilnik o\'chirildi',
    ));
  }
}
