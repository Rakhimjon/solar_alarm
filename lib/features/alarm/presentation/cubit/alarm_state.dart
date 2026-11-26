import '../../domain/entities/alarm_item.dart';

class AlarmState {
  final List<AlarmItem> alarms;
  final int? ringingAlarmId;
  final String? ringingAlarmLabel;
  final bool ringingRequireMath;
  final int remainingSunTaps;
  final String morningAffirmation;
  final bool isLoading;
  final String? message;

  const AlarmState({
    this.alarms = const [],
    this.ringingAlarmId,
    this.ringingAlarmLabel,
    this.ringingRequireMath = false,
    this.remainingSunTaps = 5,
    this.morningAffirmation =
        'Xayrli tong! Bugun yangi imkoniyatlar va baraka kuni.',
    this.isLoading = false,
    this.message,
  });

  bool get isRinging => ringingAlarmId != null;

  AlarmState copyWith({
    List<AlarmItem>? alarms,
    int? ringingAlarmId,
    String? ringingAlarmLabel,
    bool? ringingRequireMath,
    int? remainingSunTaps,
    String? morningAffirmation,
    bool? isLoading,
    String? message,
    bool clearRinging = false,
  }) {
    return AlarmState(
      alarms: alarms ?? this.alarms,
      ringingAlarmId: clearRinging
          ? null
          : (ringingAlarmId ?? this.ringingAlarmId),
      ringingAlarmLabel: clearRinging
          ? null
          : (ringingAlarmLabel ?? this.ringingAlarmLabel),
      ringingRequireMath: clearRinging
          ? false
          : (ringingRequireMath ?? this.ringingRequireMath),
      remainingSunTaps: clearRinging
          ? 5
          : (remainingSunTaps ?? this.remainingSunTaps),
      morningAffirmation: clearRinging
          ? 'Xayrli tong! Bugun yangi imkoniyatlar va baraka kuni.'
          : (morningAffirmation ?? this.morningAffirmation),
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}
