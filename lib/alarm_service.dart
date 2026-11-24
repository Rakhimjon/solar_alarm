import 'package:alarm/alarm.dart';
import 'solar_calculator.dart';

class SolarAlarmService {
  static const double defaultLat = 41.311081; // Toshkent lat
  static const double defaultLng = 69.240562; // Toshkent lng
  static const int alarmId = 42;

  static Future<void> init() async {
    await Alarm.init();
    Alarm.ringing.listen((alarmSet) async {
      await scheduleNextSolarAlarm();
    });
  }

  static Future<DateTime> scheduleNextSolarAlarm({
    double lat = defaultLat,
    double lng = defaultLng,
    SolarEvent event = SolarEvent.sunrise,
    int offsetMinutes = -15,
  }) async {
    final nextTime = SolarCalculator.getNextAlarmTime(
      lat: lat,
      lng: lng,
      event: event,
      offsetMinutes: offsetMinutes,
    );

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: nextTime,
      assetAudioPath: 'assets/alarm.wav',
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: 'Quyosh Uyg\'otgichi',
        body:
            'Quyosh vaqti yetdi: ${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}',
        stopButton: 'To\'xtatish',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    return nextTime;
  }

  static Future<void> cancelAlarm() async {
    await Alarm.stop(alarmId);
  }

  static Future<bool> hasActiveAlarm() async {
    return await Alarm.hasAlarm();
  }
}

