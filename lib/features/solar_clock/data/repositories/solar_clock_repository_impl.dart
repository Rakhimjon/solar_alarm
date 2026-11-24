import 'package:solar_alarm/core/services/alarm_local_datasource.dart';
import '../datasources/astronomical_calculator.dart';
import '../../domain/entities/solar_time_item.dart';
import '../../domain/repositories/solar_clock_repository.dart';

class SolarClockRepositoryImpl implements SolarClockRepository {
  final AstronomicalCalculator calculator;
  final AlarmLocalDataSource alarmDataSource;

  SolarClockRepositoryImpl({
    required this.calculator,
    required this.alarmDataSource,
  });

  @override
  DaySolarCycle getDayCycle({
    required DateTime date,
    required double lat,
    required double lng,
  }) {
    return calculator.calculateCycle(date: date, lat: lat, lng: lng);
  }

  @override
  Future<DateTime> scheduleAlarm({
    required SolarEventType eventType,
    required DateTime eventTime,
    required int offsetMinutes,
  }) async {
    final alarmTime = eventTime.add(Duration(minutes: offsetMinutes));
    final effectiveTime = alarmTime.isAfter(DateTime.now())
        ? alarmTime
        : alarmTime.add(const Duration(days: 1));

    await alarmDataSource.setAlarm(
      dateTime: effectiveTime,
      title: '${eventType.titleUz} vaqti eslatmasi',
      body:
          '${eventType.titleUz} vaqti: ${effectiveTime.hour.toString().padLeft(2, '0')}:${effectiveTime.minute.toString().padLeft(2, '0')}',
    );

    return effectiveTime;
  }

  @override
  Future<void> cancelAlarm() async {
    await alarmDataSource.stopAlarm();
  }
}
