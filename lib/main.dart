import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'di.dart';
import 'features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
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
        BlocProvider<SolarClockCubit>(
          create: (_) => sl<SolarClockCubit>(),
        ),
        BlocProvider<PlannerCubit>(
          create: (_) => sl<PlannerCubit>(),
        ),
        BlocProvider<FocusTimerCubit>(
          create: (_) => sl<FocusTimerCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Quyosh & Qumsoat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MainNavigationPage(),
      ),
    );
  }
}
