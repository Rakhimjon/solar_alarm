import '../../domain/entities/alarm_item.dart';

class AlarmState {
  final List<AlarmItem> alarms;
  final int? ringingAlarmId;
  final String? ringingAlarmLabel;
  final bool isLoading;
  final String? message;

  const AlarmState({
    this.alarms = const [],
    this.ringingAlarmId,
    this.ringingAlarmLabel,
    this.isLoading = false,
    this.message,
  });

  bool get isRinging => ringingAlarmId != null;

  AlarmState copyWith({
    List<AlarmItem>? alarms,
    int? ringingAlarmId,
    String? ringingAlarmLabel,
    bool? isLoading,
    String? message,
    bool clearRinging = false,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      ringingAlarmId: clearRinging ? null : (ringingAlarmId ?? this.ringingAlarmId),
      ringingAlarmLabel: clearRinging ? null : (ringingAlarmLabel ?? this.ringingAlarmLabel),
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}
