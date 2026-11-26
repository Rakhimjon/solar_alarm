import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'di.dart';
import 'features/alarm/presentation/cubit/alarm_cubit.dart';
import 'features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
import 'features/habit/presentation/cubit/habit_cubit.dart';
import 'features/home/presentation/pages/main_navigation_page.dart';
import 'features/planner/presentation/cubit/planner_cubit.dart';
import 'features/solar_clock/presentation/cubit/solar_clock_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDi();
  runApp(const SolarFocusApp());
}

class SolarFocusApp extends StatelessWidget {
  const SolarFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
        BlocProvider<SolarClockCubit>(
          create: (_) => sl<SolarClockCubit>(),
        ),
        BlocProvider<PlannerCubit>(
          create: (_) => sl<PlannerCubit>(),
        ),
        BlocProvider<HabitCubit>(
          create: (_) => sl<HabitCubit>(),
        ),
        BlocProvider<FocusTimerCubit>(
          create: (_) => sl<FocusTimerCubit>(),
        ),
        BlocProvider<AlarmCubit>(
          create: (_) => sl<AlarmCubit>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: 'Quyosh & Qumsoat',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                home: const MainNavigationPage(),
              );
            },
          );
        },
      ),
    );
  }
}
