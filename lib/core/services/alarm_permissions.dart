import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class AlarmPermissions {
  static Future<bool> ensure() async {
    final notifications = await Permission.notification.request();
    if (!notifications.isGranted) return false;

    if (Platform.isAndroid) {
      final exactAlarms = await Permission.scheduleExactAlarm.request();
      return exactAlarms.isGranted;
    }

    return true;
  }
}
