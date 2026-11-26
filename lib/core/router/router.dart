import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_alarm/core/router/path.dart';
import 'package:solar_alarm/features/alarm/domain/entities/alarm_item.dart';
import 'package:solar_alarm/features/alarm/presentation/pages/add_edit_alarm_page.dart';
import 'package:solar_alarm/features/alarm/presentation/pages/alarm_view.dart';
import 'package:solar_alarm/features/alarm/presentation/pages/ringing_page.dart';
import 'package:solar_alarm/features/focus_timer/presentation/pages/focus_timer_view.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/presentation/pages/add_habit_page.dart';
import 'package:solar_alarm/features/habit/presentation/pages/habit_detail_page.dart';
import 'package:solar_alarm/features/habit/presentation/pages/habit_view.dart';
import 'package:solar_alarm/features/home/presentation/pages/main_navigation_page.dart';
import 'package:solar_alarm/features/planner/presentation/pages/add_plan_page.dart';
import 'package:solar_alarm/features/planner/presentation/pages/planner_view.dart';
import 'package:solar_alarm/features/solar_clock/presentation/pages/solar_clock_view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: RoutePath.solar,
  routes: [
    /// Main tabs (each branch keeps its own state, like the old IndexedStack)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainNavigationPage(navigationShell: navigationShell),
      branches: [
        _tab(RoutePath.solar, const SolarClockView()),
        _tab(RoutePath.focus, const FocusTimerView()),
        _tab(RoutePath.planner, const PlannerView()),
        _tab(RoutePath.alarm, const AlarmView()),
        _tab(RoutePath.habit, const HabitView()),
      ],
    ),

    /// Planner
    GoRoute(
      path: RoutePath.addPlan,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return AddPlanPage(
          categories: extra['categories'] as List<String>,
          initialCategory: extra['initialCategory'] as String,
        );
      },
    ),

    /// Alarm
    GoRoute(
      path: RoutePath.addEditAlarm,
      builder: (context, state) =>
          AddEditAlarmPage(initialAlarm: state.extra as AlarmItem?),
    ),
    GoRoute(
      path: RoutePath.ringing,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        transitionDuration: const Duration(milliseconds: 400),
        child: const RingingPage(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),

    /// Habit
    GoRoute(
      path: RoutePath.addHabit,
      builder: (context, state) =>
          AddHabitPage(initialHabit: state.extra as Habit?),
    ),
    GoRoute(
      path: RoutePath.habitDetail,
      builder: (context, state) => HabitDetailPage(habit: state.extra as Habit),
    ),
  ],
);

StatefulShellBranch _tab(String path, Widget page) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => page)],
);
