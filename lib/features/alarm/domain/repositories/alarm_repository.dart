import '../entities/alarm_item.dart';

abstract class AlarmRepository {
  Future<List<AlarmItem>> getAlarms();
  Future<void> saveAlarm(AlarmItem alarm);
  Future<void> deleteAlarm(int id);
  Future<void> toggleAlarm(int id);
  Future<void> stopRinging(int id);
  Future<void> snoozeAlarm(int id, {int minutes = 5});
}
