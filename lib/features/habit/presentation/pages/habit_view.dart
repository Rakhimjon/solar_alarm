import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_alarm/core/router/path.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/core/theme/theme_cubit.dart';
import 'package:solar_alarm/core/widgets/custom_button.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_cubit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_state.dart';
import 'package:solar_alarm/features/habit/presentation/widgets/habit_grid.dart';

class HabitView extends StatelessWidget {
  const HabitView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        final cubit = context.read<HabitCubit>();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayHabits = state.habits
            .where((h) => h.isScheduledOn(today))
            .toList();
        final done = todayHabits.where((h) => h.isDoneOn(today)).length;

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
          body: state.status == HabitStatus.loading && state.habits.isEmpty
              ? const Center(child: CupertinoActivityIndicator())
              : state.habits.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 96.h),
                  children: [
                    if (todayHabits.isNotEmpty)
                      _TodaySummary(done: done, total: todayHabits.length),
                    for (final habit in state.habits) ...[
                      _HabitCard(
                        habit: habit,
                        today: today,
                        onToggle: () {
                          HapticFeedback.lightImpact();
                          cubit.toggleDate(habit.id, today);
                        },
                        onOpen: () =>
                            context.push(RoutePath.habitDetail, extra: habit),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ],
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: CustomButton(
            title: 'Yangi Odat',
            icon: const Icon(CupertinoIcons.add),
            borderRadius: 28.r,
            onTap: () => context.push(RoutePath.addHabit),
          ),
        );
      },
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final int done;
  final int total;

  const _TodaySummary({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bugun',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                done == total ? 'Hammasi bajarildi ✨' : '$done / $total',
                style: TextStyle(color: colors.textMuted, fontSize: 13.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 5.h,
              backgroundColor: colors.card,
              valueColor: AlwaysStoppedAnimation(colors.primary),
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
    final isDone = habit.isDoneOn(today);
    final isScheduled = habit.isScheduledOn(today);
    final streak = habit.currentStreak(today);

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(habit.emoji, style: TextStyle(fontSize: 20.sp)),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          streak > 0
                              ? '🔥 $streak kun · ${habit.scheduleText}'
                              : habit.scheduleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _CheckButton(
                    label: '${habit.name}: bajarildi deb belgilash',
                    isDone: isDone,
                    enabled: isScheduled,
                    color: habitColor,
                    onTap: onToggle,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ExcludeSemantics(child: HabitGrid(habit: habit)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  const _CheckButton({
    required this.label,
    required this.isDone,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      checked: isDone,
      enabled: enabled,
      label: label,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size(44.r, 44.r),
        onPressed: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: isDone
                ? color
                : color.withValues(alpha: enabled ? 0.15 : 0.06),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 22.r,
            color: isDone
                ? Colors.white
                : color.withValues(alpha: enabled ? 0.9 : 0.3),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌱', style: TextStyle(fontSize: 44.sp)),
            SizedBox(height: 12.h),
            Text(
              'Hozircha odatlar yo\'q',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Har kuni bajarilgan kun kvadratcha bo\'lib bo\'yaladi',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
