import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:solar_alarm/features/alarm/presentation/pages/alarm_view.dart';
import 'package:solar_alarm/features/focus_timer/presentation/pages/focus_timer_view.dart';
import 'package:solar_alarm/features/habit/presentation/pages/habit_view.dart';
import 'package:solar_alarm/features/planner/presentation/pages/planner_view.dart';
import 'package:solar_alarm/features/solar_clock/presentation/pages/solar_clock_view.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final pages = [
      const SolarClockView(),
      const FocusTimerView(),
      PlannerView(onSwitchTab: (index) => setState(() => _currentIndex = index)),
      AlarmView(onSwitchTab: (index) => setState(() => _currentIndex = index)),
      const HabitView(),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: CupertinoTabBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: colors.background.withValues(alpha: context.isDark ? 0.78 : 0.88),
            activeColor: colors.primary,
            inactiveColor: colors.textMuted,
            border: Border(
              top: BorderSide(
                color: colors.cardBorder.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.sun_max),
                activeIcon: Icon(CupertinoIcons.sun_max_fill),
                label: 'Quyosh',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.hourglass),
                activeIcon: Icon(CupertinoIcons.hourglass_bottomhalf_fill),
                label: 'Qumsoat',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_list),
                activeIcon: Icon(CupertinoIcons.square_list_fill),
                label: 'Rejalar',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.alarm),
                activeIcon: Icon(CupertinoIcons.alarm_fill),
                label: 'Uyg\'otgich',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.repeat),
                activeIcon: Icon(CupertinoIcons.repeat),
                label: 'Odatlar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
