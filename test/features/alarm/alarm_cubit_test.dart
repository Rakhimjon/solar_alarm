import 'package:flutter_test/flutter_test.dart';
import 'package:solar_alarm/features/alarm/domain/entities/alarm_item.dart';
import 'package:solar_alarm/features/alarm/domain/repositories/alarm_repository.dart';
import 'package:solar_alarm/features/alarm/presentation/cubit/alarm_cubit.dart';

class FakeAlarmRepository implements AlarmRepository {
  final List<AlarmItem> _alarms = [];
  bool wasStopped = false;
  bool wasSnoozed = false;

  @override
  Future<List<AlarmItem>> getAlarms() async => List.from(_alarms);

  @override
  Future<void> saveAlarm(AlarmItem alarm) async {
    final idx = _alarms.indexWhere((a) => a.id == alarm.id);
    if (idx >= 0) {
      _alarms[idx] = alarm;
    } else {
      _alarms.add(alarm);
    }
  }

  @override
  Future<void> deleteAlarm(int id) async {
    _alarms.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> toggleAlarm(int id) async {
    final idx = _alarms.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _alarms[idx] = _alarms[idx].copyWith(isEnabled: !_alarms[idx].isEnabled);
    }
  }

  @override
  Future<void> stopRinging(int id) async {
    wasStopped = true;
  }

  @override
  Future<void> snoozeAlarm(int id, {int minutes = 5}) async {
    wasSnoozed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAlarmRepository fakeRepo;
  late AlarmCubit cubit;

  setUp(() {
    fakeRepo = FakeAlarmRepository();
    cubit = AlarmCubit(repository: fakeRepo);
  });

  tearDown(() {
    cubit.close();
  });

  test('AlarmCubit loads, saves, toggles, and deletes alarm', () async {
    expect(cubit.state.alarms, isEmpty);

    // Save alarm with math mission and solar link
    await cubit.saveAlarm(
      hour: 6,
      minute: 30,
      label: 'Bomdod',
      soundPath: 'assets/loud_beep.wav',
      soundTitle: 'Baland Signal',
      repeatDays: [1, 2, 3, 4, 5],
      vibrate: true,
      requireMathMission: true,
      linkedSolarType: 'fajr',
      solarOffsetMinutes: -20,
      existingId: 101,
    );

    expect(cubit.state.alarms.length, 1);
    expect(cubit.state.alarms.first.label, 'Bomdod');
    expect(cubit.state.alarms.first.requireMathMission, isTrue);
    expect(cubit.state.alarms.first.hasSolarLink, isTrue);
    expect(cubit.state.alarms.first.isEnabled, isTrue);

    // Verify math mission verification
    final correctAnswer = cubit.state.mathAnswer;
    expect(cubit.verifyMathAndDismiss(correctAnswer + 5), isFalse);
    expect(cubit.verifyMathAndDismiss(correctAnswer), isTrue);

    // Verify solar ray taps
    expect(cubit.state.remainingSunTaps, 5);
    cubit.tapSunRay();
    expect(cubit.state.remainingSunTaps, 4);

    // Toggle alarm
    await cubit.toggleAlarm(101);
    expect(cubit.state.alarms.first.isEnabled, isFalse);

    // Delete alarm
    await cubit.deleteAlarm(101);
    expect(cubit.state.alarms, isEmpty);
  });
}
