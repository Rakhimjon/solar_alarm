import '../../domain/entities/solar_types.dart';
import '../../domain/repositories/solar_alarm_repository.dart';
import '../datasources/alarm_local_datasource.dart';
import '../datasources/solar_calculator_datasource.dart';

class SolarAlarmRepositoryImpl implements SolarAlarmRepository {
  final SolarCalculatorDataSource calculatorDataSource;
  final AlarmLocalDataSource alarmDataSource;

  SolarAlarmRepositoryImpl({
    required this.calculatorDataSource,
    required this.alarmDataSource,
  });

  @override
  DateTime calculateSolarTime({
    required DateTime date,
    required double lat,
    required double lng,
    required SolarEvent event,
    int offsetMinutes = 0,
  }) {
    return calculatorDataSource.getSolarTime(
      date: date,
      lat: lat,
      lng: lng,
      event: event,
      offsetMinutes: offsetMinutes,
    );
  }

  @override
  DateTime calculateNextAlarmTime({
    required double lat,
    required double lng,
    required SolarEvent event,
    int offsetMinutes = 0,
  }) {
    return calculatorDataSource.getNextAlarmTime(
      lat: lat,
      lng: lng,
      event: event,
      offsetMinutes: offsetMinutes,
    );
  }

  @override
  Future<DateTime> scheduleAlarm({
    required double lat,
    required double lng,
    required SolarEvent event,
    required int offsetMinutes,
  }) async {
    final nextTime = calculateNextAlarmTime(
      lat: lat,
      lng: lng,
      event: event,
      offsetMinutes: offsetMinutes,
    );

    final eventLabel =
        event == SolarEvent.sunrise ? 'Quyosh chiqishi' : 'Quyosh botishi';
    final timeStr =
        '${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}';

    await alarmDataSource.setAlarm(
      dateTime: nextTime,
      title: 'Quyosh Uyg\'otgichi ($eventLabel)',
      body: 'Belgilangan vaqt yetdi: $timeStr',
    );

    return nextTime;
  }

  @override
  Future<void> cancelAlarm() async {
    await alarmDataSource.stopAlarm();
  }
}
