import '../entities/solar_time_item.dart';

abstract class SolarClockRepository {
  DaySolarCycle getDayCycle({
    required DateTime date,
    required double lat,
    required double lng,
  });

  Future<DateTime> scheduleAlarm({
    required SolarEventType eventType,
    required DateTime eventTime,
    required int offsetMinutes,
  });

  Future<void> cancelAlarm();
}
