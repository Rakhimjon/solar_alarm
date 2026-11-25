import '../../domain/entities/alarm_item.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/alarm_local_storage.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalStorage localStorage;

  AlarmRepositoryImpl({required this.localStorage});

  @override
  Future<List<AlarmItem>> getAlarms() => localStorage.getAlarms();

  @override
  Future<void> saveAlarm(AlarmItem alarm) => localStorage.saveAlarm(alarm);

  @override
  Future<void> deleteAlarm(int id) => localStorage.deleteAlarm(id);

  @override
  Future<void> toggleAlarm(int id) => localStorage.toggleAlarm(id);

  @override
  Future<void> stopRinging(int id) => localStorage.stopRinging(id);

  @override
  Future<void> snoozeAlarm(int id, {int minutes = 5}) =>
      localStorage.snoozeAlarm(id, minutes);

  @override
  Future<void> rescheduleAlarms() => localStorage.rescheduleAlarms();
}
