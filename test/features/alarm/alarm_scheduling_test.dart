import 'package:flutter_test/flutter_test.dart';
import 'package:solar_alarm/features/alarm/data/datasources/alarm_local_storage.dart';
import 'package:solar_alarm/features/alarm/domain/entities/alarm_item.dart';
import 'package:solar_alarm/features/solar_clock/domain/entities/solar_time_item.dart';

void main() {
  final now = DateTime(2026, 11, 25, 10);

  test('Fixed repeating alarm selects the next requested weekday', () {
    final alarm = AlarmItem(id: 1, hour: 6, minute: 30, repeatDays: const [1]);

    expect(alarm.nextOccurrenceAfter(now), DateTime(2026, 11, 30, 6, 30));
  });

  test('Solar alarm applies event offset and requested weekday', () async {
    final alarm = AlarmItem(
      id: 2,
      hour: 0,
      minute: 0,
      linkedSolarType: 'fajr',
      solarOffsetMinutes: -20,
      repeatDays: const [4],
    );

    final result = await resolveAlarmDateTime(
      alarm: alarm,
      now: now,
      loadCycle: (date) async => DaySolarCycle(
        date: date,
        items: [
          SolarTimeItem(
            type: SolarEventType.fajr,
            title: 'Bomdod',
            time: DateTime(date.year, date.month, date.day, 5, 30),
            icon: '🌅',
          ),
        ],
      ),
    );

    expect(result, DateTime(2026, 11, 26, 5, 10));
  });

  test('Solar alarm moves to tomorrow when today\'s event passed', () async {
    final alarm = AlarmItem(
      id: 3,
      hour: 0,
      minute: 0,
      linkedSolarType: 'fajr',
      solarOffsetMinutes: -20,
    );

    final result = await resolveAlarmDateTime(
      alarm: alarm,
      now: DateTime(2026, 11, 25, 6),
      loadCycle: (date) async => DaySolarCycle(
        date: date,
        items: [
          SolarTimeItem(
            type: SolarEventType.fajr,
            title: 'Bomdod',
            time: DateTime(date.year, date.month, date.day, 5, 30),
            icon: '🌅',
          ),
        ],
      ),
    );

    expect(result, DateTime(2026, 11, 26, 5, 10));
  });
}
