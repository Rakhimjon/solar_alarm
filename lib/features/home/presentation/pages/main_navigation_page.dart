import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

import 'package:go_router/go_router.dart';

class MainNavigationPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: navigationShell,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: CupertinoTabBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            backgroundColor: colors.background.withValues(
              alpha: context.isDark ? 0.78 : 0.88,
            ),
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
