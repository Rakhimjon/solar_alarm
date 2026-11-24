import 'package:flutter_test/flutter_test.dart';
import 'package:solar_alarm/core/services/kiosk_service.dart';
import 'package:solar_alarm/features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
import 'package:solar_alarm/features/focus_timer/presentation/cubit/focus_timer_state.dart';
import 'package:solar_alarm/features/planner/domain/entities/plan_task.dart';
import 'package:solar_alarm/features/planner/domain/repositories/plan_repository.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';

class FakePlanRepository implements PlanRepository {
  final List<PlanTask> _tasks = [];
  @override
  Future<List<PlanTask>> getTasks() async => _tasks;
  @override
  Future<void> saveTask(PlanTask task) async {}
  @override
  Future<void> deleteTask(String id) async {}
  @override
  Future<void> toggleTaskCompletion(String id) async {}
  @override
  Future<void> addFocusDuration(String id, int minutes) async {}
}

class FakeKioskService extends KioskService {
  bool locked = false;

  @override
  Future<bool> startLock() async {
    locked = true;
    return true;
  }

  @override
  Future<bool> stopLock() async {
    locked = false;
    return true;
  }

  @override
  Future<bool> isLocked() async => locked;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeKioskService fakeKiosk;
  late PlannerCubit plannerCubit;
  late FocusTimerCubit timerCubit;

  setUp(() {
    fakeKiosk = FakeKioskService();
    plannerCubit = PlannerCubit(repository: FakePlanRepository());
    timerCubit = FocusTimerCubit(
      plannerCubit: plannerCubit,
      kioskService: fakeKiosk,
    );
  });

  tearDown(() {
    timerCubit.close();
    plannerCubit.close();
  });

  test('Starts with Deep Work enabled and locks on start', () async {
    expect(timerCubit.state.isDeepWorkEnabled, isTrue);
    expect(timerCubit.state.isLocked, isFalse);

    timerCubit.start();
    await pumpEventQueue();

    expect(timerCubit.state.status, FocusStatus.running);
    expect(timerCubit.state.isLocked, isTrue);
    expect(fakeKiosk.locked, isTrue);

    timerCubit.pause();
    await pumpEventQueue();

    expect(timerCubit.state.status, FocusStatus.paused);
    expect(timerCubit.state.isLocked, isFalse);
    expect(fakeKiosk.locked, isFalse);
  });

  test('Unlocks when app goes to background', () async {
    timerCubit.start();
    await pumpEventQueue();
    expect(timerCubit.state.isLocked, isTrue);

    timerCubit.handleAppLifecycleBackground();
    await pumpEventQueue();

    expect(timerCubit.state.status, FocusStatus.paused);
    expect(timerCubit.state.isLocked, isFalse);
    expect(fakeKiosk.locked, isFalse);
    expect(timerCubit.state.warningMessage, isNotNull);
  });
}
