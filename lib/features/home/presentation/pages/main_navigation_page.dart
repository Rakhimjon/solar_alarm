import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:solar_alarm/features/focus_timer/presentation/pages/focus_timer_view.dart';
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
    final pages = [
      const SolarClockView(),
      const FocusTimerView(),
      PlannerView(onSwitchTab: (index) => setState(() => _currentIndex = index)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.appColors.cardBorder.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              activeIcon: Icon(Icons.wb_sunny_rounded),
              label: 'Quyosh Soati',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_empty_rounded),
              activeIcon: Icon(Icons.hourglass_full_rounded),
              label: 'Qumsoat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rounded),
              activeIcon: Icon(Icons.fact_check_rounded),
              label: 'Rejalar',
            ),
          ],
        ),
      ),
    );
  }
}
