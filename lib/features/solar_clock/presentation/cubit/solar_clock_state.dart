import '../../domain/entities/solar_time_item.dart';

enum SolarClockStatus { initial, loading, loaded, error }

class SolarClockState {
  final SolarClockStatus status;
  final DaySolarCycle? cycle;
  final SolarEventType selectedEvent;
  final int offsetMinutes;
  final DateTime? activeAlarmTime;
  final String? message;
  final double lat;
  final double lng;

  const SolarClockState({
    this.status = SolarClockStatus.initial,
    this.cycle,
    this.selectedEvent = SolarEventType.fajr,
    this.offsetMinutes = -15,
    this.activeAlarmTime,
    this.message,
    this.lat = 41.311081,
    this.lng = 69.240562,
  });

  SolarClockState copyWith({
    SolarClockStatus? status,
    DaySolarCycle? cycle,
    SolarEventType? selectedEvent,
    int? offsetMinutes,
    DateTime? activeAlarmTime,
    String? message,
    double? lat,
    double? lng,
  }) {
    return SolarClockState(
      status: status ?? this.status,
      cycle: cycle ?? this.cycle,
      selectedEvent: selectedEvent ?? this.selectedEvent,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      activeAlarmTime: activeAlarmTime ?? this.activeAlarmTime,
      message: message,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
