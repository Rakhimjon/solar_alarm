import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/core/theme/theme_cubit.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/domain/repositories/habit_repository.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_cubit.dart';
import 'package:solar_alarm/features/habit/presentation/pages/habit_view.dart';

class MemoryHabitRepository implements HabitRepository {
  final List<Habit> habits;
  final List<DateTime> toggled = [];

  MemoryHabitRepository(this.habits);

  @override
  Future<List<Habit>> getHabits() async => List.from(habits);

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> deleteHabit(String id) async {}

  @override
  Future<void> toggleCompletion(String id, DateTime date) async {
    toggled.add(date);
  }
}

void main() {
  testWidgets('Check button toggles today', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repo = MemoryHabitRepository([
      Habit(
        id: '1',
        name: 'Kitob',
        createdAt: today.subtract(const Duration(days: 30)),
      ),
    ]);
    final cubit = HabitCubit(repository: repo);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cubit),
            BlocProvider(create: (_) => ThemeCubit(prefs: prefs)),
          ],
          child: MaterialApp(theme: AppTheme.light, home: const HabitView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final toggle = find.bySemanticsLabel('Kitob: bajarildi deb belgilash');
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(repo.toggled.last, today);

    // Second tap un-marks the same day (no week strip any more).
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(repo.toggled, [today, today]);
    semantics.dispose();
  });
}
