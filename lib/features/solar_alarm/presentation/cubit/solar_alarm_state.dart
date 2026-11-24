import '../../domain/entities/solar_types.dart';

enum SolarAlarmStatus { initial, scheduled, cancelled }

class SolarAlarmState {
  final SolarEvent event;
  final int offsetMinutes;
  final double lat;
  final double lng;
  final DateTime? nextAlarm;
  final SolarAlarmStatus status;
  final String? message;

  const SolarAlarmState({
    this.event = SolarEvent.sunrise,
    this.offsetMinutes = -15,
    this.lat = 41.311081, // Default Toshkent lat
    this.lng = 69.240562, // Default Toshkent lng
    this.nextAlarm,
    this.status = SolarAlarmStatus.initial,
    this.message,
  });

  SolarAlarmState copyWith({
    SolarEvent? event,
    int? offsetMinutes,
    double? lat,
    double? lng,
    DateTime? nextAlarm,
    SolarAlarmStatus? status,
    String? message,
  }) {
    return SolarAlarmState(
      event: event ?? this.event,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      nextAlarm: nextAlarm ?? this.nextAlarm,
      status: status ?? this.status,
      message: message,
    );
  }
}
