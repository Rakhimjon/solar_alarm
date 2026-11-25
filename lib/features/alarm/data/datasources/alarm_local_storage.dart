import 'dart:convert';

import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_alarm/features/solar_clock/domain/entities/solar_time_item.dart';
import 'package:solar_alarm/features/solar_clock/domain/repositories/solar_clock_repository.dart';

import '../../domain/entities/alarm_item.dart';

typedef SolarCycleLoader = Future<DaySolarCycle> Function(DateTime date);

Future<DateTime> resolveAlarmDateTime({
  required AlarmItem alarm,
  SolarCycleLoader? loadCycle,
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  if (!alarm.hasSolarLink) {
    return alarm.nextOccurrenceAfter(currentTime);
  }

  if (loadCycle == null) {
    throw ArgumentError('A solar cycle loader is required for linked alarms');
  }

  final eventType = SolarEventType.values
      .where((event) => event.name == alarm.linkedSolarType)
      .firstOrNull;
  if (eventType == null) {
    throw ArgumentError('Unknown solar event: ${alarm.linkedSolarType}');
  }

  for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
    final date = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day + dayOffset,
    );
    if (alarm.repeatDays.isNotEmpty &&
        !alarm.repeatDays.contains(date.weekday)) {
      continue;
    }

    final cycle = await loadCycle(date);
    final event = cycle.items
        .where((item) => item.type == eventType)
        .firstOrNull;
    if (event == null) continue;

    final candidate = event.time.add(
      Duration(minutes: alarm.solarOffsetMinutes),
    );
    if (candidate.isAfter(currentTime)) return candidate;
  }

  throw StateError('Unable to resolve the next solar alarm');
}

abstract class AlarmLocalStorage {
  Future<List<AlarmItem>> getAlarms();
  Future<void> saveAlarm(AlarmItem alarm);
  Future<void> deleteAlarm(int id);
  Future<void> toggleAlarm(int id);
  Future<void> stopRinging(int id);
  Future<void> snoozeAlarm(int id, int minutes);
  Future<void> rescheduleAlarms();
}

class AlarmLocalStorageImpl implements AlarmLocalStorage {
  static const String _storageKey = 'custom_user_alarms';
  final SharedPreferences prefs;
  final SolarClockRepository solarClockRepository;

  AlarmLocalStorageImpl({
    required this.prefs,
    required this.solarClockRepository,
  });

  @override
  Future<List<AlarmItem>> getAlarms() async {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AlarmItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAlarm(AlarmItem alarm) async {
    final current = await getAlarms();
    var index = current.indexWhere((a) => a.id == alarm.id);
    if (index >= 0) {
      current[index] = alarm;
    } else {
      current.add(alarm);
      index = current.length - 1;
    }

    if (alarm.isEnabled) {
      await _scheduleAtIndex(current, index);
    } else {
      await _persist(current);
      await Alarm.stop(alarm.id);
    }
  }

  @override
  Future<void> deleteAlarm(int id) async {
    final current = await getAlarms();
    current.removeWhere((a) => a.id == id);
    await _persist(current);
    await Alarm.stop(id);
  }

  @override
  Future<void> toggleAlarm(int id) async {
    final current = await getAlarms();
    final index = current.indexWhere((a) => a.id == id);
    if (index < 0) return;

    final updated = current[index].copyWith(
      isEnabled: !current[index].isEnabled,
    );
    current[index] = updated;

    if (updated.isEnabled) {
      await _scheduleAtIndex(current, index);
    } else {
      await _persist(current);
      await Alarm.stop(id);
    }
  }

  @override
  Future<void> stopRinging(int id) async {
    await Alarm.stop(id);
    final current = await getAlarms();
    final index = current.indexWhere((alarm) => alarm.id == id);
    if (index < 0) return;

    if (current[index].repeatDays.isEmpty) {
      current[index] = current[index].copyWith(isEnabled: false);
      await _persist(current);
      return;
    }

    await _scheduleAtIndex(current, index);
  }

  @override
  Future<void> snoozeAlarm(int id, int minutes) async {
    await Alarm.stop(id);
    final snoozeTime = DateTime.now().add(Duration(minutes: minutes));

    final current = await getAlarms();
    final match = current.where((a) => a.id == id).firstOrNull;

    final settings = AlarmSettings(
      id: id,
      dateTime: snoozeTime,
      assetAudioPath: match?.soundPath ?? 'assets/loud_beep.wav',
      loopAudio: true,
      vibrate: match?.vibrate ?? true,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 1),
      ),
      notificationSettings: NotificationSettings(
        title: '${match?.label ?? "Budilnik"} (Qayta qo\'ng\'iroq)',
        body: '$minutes daqiqa kechiktirildi',
        stopButton: 'To\'xtatish',
      ),
    );

    final scheduled = await Alarm.set(alarmSettings: settings);
    if (!scheduled) throw StateError('Unable to schedule snooze');
  }

  @override
  Future<void> rescheduleAlarms() async {
    final current = await getAlarms();
    final now = DateTime.now();

    for (var index = 0; index < current.length; index++) {
      final alarm = current[index];
      if (!alarm.isEnabled) continue;

      final nativeAlarm = await Alarm.getAlarm(alarm.id);
      if (nativeAlarm != null && nativeAlarm.dateTime.isAfter(now)) continue;

      await _scheduleAtIndex(current, index);
    }
  }

  Future<void> _scheduleAtIndex(List<AlarmItem> alarms, int index) async {
    final alarm = alarms[index];
    final dateTime = await resolveAlarmDateTime(
      alarm: alarm,
      loadCycle: (date) => solarClockRepository.getDayCycle(
        date: date,
        lat: alarm.lat,
        lng: alarm.lng,
        region: alarm.region,
      ),
    );

    if (alarm.hasSolarLink) {
      alarms[index] = alarm.copyWith(
        hour: dateTime.hour,
        minute: dateTime.minute,
      );
    }
    await _persist(alarms);
    await _setNative(alarms[index], dateTime);
  }

  Future<void> _setNative(AlarmItem alarm, DateTime dateTime) async {
    final settings = AlarmSettings(
      id: alarm.id,
      dateTime: dateTime,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 1),
      ),
      notificationSettings: NotificationSettings(
        title: alarm.label,
        body:
            'Budilnik vaqti bo\'ldi: ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        stopButton: 'To\'xtatish',
      ),
    );

    final scheduled = await Alarm.set(alarmSettings: settings);
    if (!scheduled) throw StateError('Unable to schedule alarm');
  }

  Future<void> _persist(List<AlarmItem> alarms) async {
    final raw = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
