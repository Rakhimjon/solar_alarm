import 'package:flutter_test/flutter_test.dart';
import 'package:solar_alarm/features/solar_clock/presentation/cubit/solar_clock_state.dart';

void main() {
  test('SolarClockState clears active alarm time', () {
    final scheduled = DateTime(2026, 11, 25, 6);
    final state = SolarClockState(activeAlarmTime: scheduled);

    final cleared = state.copyWith(clearActiveAlarmTime: true);

    expect(cleared.activeAlarmTime, isNull);
  });
}
