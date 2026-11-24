import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/alarm_item.dart';

abstract class AlarmLocalStorage {
  Future<List<AlarmItem>> getAlarms();
  Future<void> saveAlarm(AlarmItem alarm);
  Future<void> deleteAlarm(int id);
  Future<void> toggleAlarm(int id);
  Future<void> stopRinging(int id);
  Future<void> snoozeAlarm(int id, int minutes);
}

class AlarmLocalStorageImpl implements AlarmLocalStorage {
  static const String _storageKey = 'custom_user_alarms';
  final SharedPreferences prefs;

  AlarmLocalStorageImpl({required this.prefs});

  @override
  Future<List<AlarmItem>> getAlarms() async {
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => AlarmItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAlarm(AlarmItem alarm) async {
    final current = await getAlarms();
    final index = current.indexWhere((a) => a.id == alarm.id);
    if (index >= 0) {
      current[index] = alarm;
    } else {
      current.add(alarm);
    }

    await _persist(current);

    if (alarm.isEnabled) {
      await _scheduleNative(alarm);
    } else {
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

    final updated = current[index].copyWith(isEnabled: !current[index].isEnabled);
    current[index] = updated;

    await _persist(current);

    if (updated.isEnabled) {
      await _scheduleNative(updated);
    } else {
      await Alarm.stop(id);
    }
  }

  @override
  Future<void> stopRinging(int id) async {
    await Alarm.stop(id);
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

    await Alarm.set(alarmSettings: settings);
  }

  Future<void> _scheduleNative(AlarmItem alarm) async {
    final settings = AlarmSettings(
      id: alarm.id,
      dateTime: alarm.nextDateTime,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      volumeSettings: VolumeSettings.fade(
        volume: 1.0,
        fadeDuration: const Duration(seconds: 1),
      ),
      notificationSettings: NotificationSettings(
        title: alarm.label,
        body: 'Budilnik vaqti bo\'ldi: ${alarm.formattedTime}',
        stopButton: 'To\'xtatish',
      ),
    );

    await Alarm.set(alarmSettings: settings);
  }

  Future<void> _persist(List<AlarmItem> alarms) async {
    final raw = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
