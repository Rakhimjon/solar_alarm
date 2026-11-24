import '../entities/solar_types.dart';

abstract class SolarAlarmRepository {
  DateTime calculateSolarTime({
    required DateTime date,
    required double lat,
    required double lng,
    required SolarEvent event,
    int offsetMinutes = 0,
  });

  DateTime calculateNextAlarmTime({
    required double lat,
    required double lng,
    required SolarEvent event,
    int offsetMinutes = 0,
  });

  Future<DateTime> scheduleAlarm({
    required double lat,
    required double lng,
    required SolarEvent event,
    required int offsetMinutes,
  });

  Future<void> cancelAlarm();
}
