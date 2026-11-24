import 'dart:io';
import 'package:flutter/services.dart';

class KioskService {
  static const MethodChannel _channel = MethodChannel('com.example.solar_alarm/kiosk');

  Future<bool> startLock() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('startLockTask');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopLock() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('stopLockTask');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLocked() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isLockTaskMode');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
