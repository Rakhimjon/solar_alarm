import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/core/theme/theme_cubit.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_cubit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_state.dart';

import 'add_habit_page.dart';
import 'habit_detail_page.dart';

class HabitView extends StatelessWidget {
  const HabitView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        final cubit = context.read<HabitCubit>();
        final today = DateTime.now();
        final todayHabits =
            state.habits.where((h) => h.isScheduledOn(today)).toList();
        final doneToday =
            todayHabits.where((h) => h.isDoneOn(today)).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Odatlar'),
            actions: [
              IconButton(
                icon: Icon(
                  context.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: colors.primary,
                ),
                tooltip: context.isDark ? 'Yorug\' rejim' : 'Qorong\'u rejim',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: _HeroCard(
                  done: doneToday,
                  total: todayHabits.length,
                ),
              ),
              Expanded(
                child: state.status == HabitStatus.loading &&
                        state.habits.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.habits.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 88.h),
                        itemCount: state.habits.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final habit = state.habits[index];
                          return _HabitCard(
                            habit: habit,
                            today: today,
                            onToggle: () => cubit.toggleToday(habit.id),
                            onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HabitDetailPage(habit: habit),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddHabitPage()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Yangi Odat'),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int done;
  final int total;

  const _HeroCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final progress = total == 0 ? 0.0 : done / total;
    final message = total == 0
        ? 'Bugun rejalashtirilgan odat yo\'q'
        : done == total
        ? 'Ajoyib! Bugungi barcha odatlar bajarildi!'
        : 'Bugungi odatlarga qadam-baqadam!';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64.r,
            height: 64.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6.r,
                  backgroundColor: colors.cardBorder,
                  valueColor: AlwaysStoppedAnimation(colors.primary),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '$done/$total bajarildi',
                  style: TextStyle(color: colors.textMuted, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime today;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  const _HabitCard({
    required this.habit,
    required this.today,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final habitColor = Color(habit.colorValue);
    final isDoneToday = habit.isDoneOn(today);
    final isScheduledToday = habit.isScheduledOn(today);
    final streak = habit.currentStreak(today);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDoneToday ? habitColor : colors.cardBorder,
          width: isDoneToday ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(habit.emoji, style: TextStyle(fontSize: 24.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          habit.scheduleText,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 11.sp,
                          ),
                        ),
                        if (streak > 0) ...[
                          SizedBox(width: 8.w),
                          Text(
                            '🔥 $streak',
                            style: TextStyle(
                              color: habitColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (isScheduledToday)
                Semantics(
                  button: true,
                  checked: isDoneToday,
                  label: '${habit.name}: bugun bajarildi deb belgilash',
                  child: InkWell(
                    onTap: onToggle,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 44.r,
                      height: 44.r,
                      child: Center(
                        child: Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDoneToday ? habitColor : Colors.transparent,
                            border: Border.all(
                              color: isDoneToday
                                  ? habitColor
                                  : colors.textMuted,
                              width: 2,
                            ),
                          ),
                          child: isDoneToday
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 44.r,
                  height: 44.r,
                  alignment: Alignment.center,
                  child: Text(
                    '—',
                    style: TextStyle(color: colors.textMuted, fontSize: 16.sp),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat_rounded,
              size: 56.r,
              color: colors.textMuted,
            ),
            SizedBox(height: 12.h),
            Text(
              'Hozircha odatlar yo\'q',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Yangi Odat tugmasi bilan birinchi odatingizni qo\'shing',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
