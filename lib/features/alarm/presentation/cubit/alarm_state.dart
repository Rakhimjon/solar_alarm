import '../../domain/entities/alarm_item.dart';

class AlarmState {
  final List<AlarmItem> alarms;
  final int? ringingAlarmId;
  final String? ringingAlarmLabel;
  final bool ringingRequireMath;
  final int mathOperand1;
  final int mathOperand2;
  final bool isLoading;
  final String? message;

  const AlarmState({
    this.alarms = const [],
    this.ringingAlarmId,
    this.ringingAlarmLabel,
    this.ringingRequireMath = false,
    this.mathOperand1 = 17,
    this.mathOperand2 = 25,
    this.isLoading = false,
    this.message,
  });

  bool get isRinging => ringingAlarmId != null;
  int get mathAnswer => mathOperand1 + mathOperand2;

  AlarmState copyWith({
    List<AlarmItem>? alarms,
    int? ringingAlarmId,
    String? ringingAlarmLabel,
    bool? ringingRequireMath,
    int? mathOperand1,
    int? mathOperand2,
    bool? isLoading,
    String? message,
    bool clearRinging = false,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      ringingAlarmId: clearRinging ? null : (ringingAlarmId ?? this.ringingAlarmId),
      ringingAlarmLabel: clearRinging ? null : (ringingAlarmLabel ?? this.ringingAlarmLabel),
      ringingRequireMath: clearRinging ? false : (ringingRequireMath ?? this.ringingRequireMath),
      mathOperand1: clearRinging ? 17 : (mathOperand1 ?? this.mathOperand1),
      mathOperand2: clearRinging ? 25 : (mathOperand2 ?? this.mathOperand2),
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}
