import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_alarm/core/services/kiosk_service.dart';
import 'package:solar_alarm/features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
import 'package:solar_alarm/features/planner/domain/entities/plan_task.dart';
import 'package:solar_alarm/features/planner/domain/repositories/plan_repository.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:solar_alarm/features/planner/presentation/pages/planner_view.dart';

class MemoryPlanRepository implements PlanRepository {
  final List<PlanTask> tasks = [];

  @override
  Future<List<PlanTask>> getTasks() async => List.from(tasks);

  @override
  Future<void> saveTask(PlanTask task) async {
    tasks.insert(0, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    final index = tasks.indexWhere((task) => task.id == id);
    tasks[index] = tasks[index].copyWith(
      isCompleted: !tasks[index].isCompleted,
    );
  }

  @override
  Future<void> addFocusDuration(String id, int minutes) async {}
}

class FakeKioskService extends KioskService {
  @override
  Future<bool> startLock() async => true;

  @override
  Future<bool> stopLock() async => true;
}

void main() {
  late PlannerCubit plannerCubit;
  late FocusTimerCubit focusTimerCubit;

  setUp(() {
    plannerCubit = PlannerCubit(repository: MemoryPlanRepository());
    focusTimerCubit = FocusTimerCubit(
      plannerCubit: plannerCubit,
      kioskService: FakeKioskService(),
    );
  });

  tearDown(() {
    focusTimerCubit.close();
    plannerCubit.close();
  });

  Future<void> pumpPlanner(WidgetTester tester, {Function(int)? onSwitchTab}) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: plannerCubit),
            BlocProvider.value(value: focusTimerCubit),
          ],
          child: MaterialApp(home: PlannerView(onSwitchTab: onSwitchTab)),
        ),
      ),
    );
  }

  testWidgets('Timed plan opens Focus Timer attached to the task', (
    tester,
  ) async {
    int? selectedTab;
    await pumpPlanner(tester, onSwitchTab: (index) => selectedTab = index);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yangi Reja'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Kitob o\'qish');
    await tester.tap(find.text('Saqlash va Fokusga o\'tish'));
    await tester.pumpAndSettle();

    expect(selectedTab, 1);
    expect(focusTimerCubit.state.activeTaskTitle, 'Kitob o\'qish');
    expect(focusTimerCubit.state.totalSeconds, 25 * 60);
    expect(plannerCubit.state.tasks.single.useTimer, isTrue);
  });

  testWidgets('No-timer plan saves without leaving Planner', (tester) async {
    var navigated = false;
    await pumpPlanner(tester, onSwitchTab: (_) => navigated = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yangi Reja'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Oddiy reja');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rejani saqlash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rejani saqlash'));
    await tester.pumpAndSettle();

    expect(navigated, isFalse);
    expect(plannerCubit.state.tasks.single.title, 'Oddiy reja');
    expect(plannerCubit.state.tasks.single.useTimer, isFalse);
  });
}
