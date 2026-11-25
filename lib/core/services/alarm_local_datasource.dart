import 'package:alarm/alarm.dart';

class AlarmLocalDataSource {
  static const int defaultAlarmId = 42;

  Future<void> init() async {
    await Alarm.init();
  }

  Future<void> setAlarm({
    required DateTime dateTime,
    required String title,
    required String body,
    String assetAudioPath = 'assets/alarm.wav',
  }) async {
    final settings = AlarmSettings(
      id: defaultAlarmId,
      dateTime: dateTime,
      assetAudioPath: assetAudioPath,
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 3),
      ),
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'To\'xtatish',
      ),
    );
    final scheduled = await Alarm.set(alarmSettings: settings);
    if (!scheduled) throw StateError('Unable to schedule alarm');
  }

  Future<void> stopAlarm() async {
    await Alarm.stop(defaultAlarmId);
  }

  Future<bool> hasAlarm() async {
    return await Alarm.hasAlarm();
  }
}
