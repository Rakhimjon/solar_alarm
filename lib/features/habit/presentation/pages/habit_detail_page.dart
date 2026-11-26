import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_cubit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_state.dart';

import 'add_habit_page.dart';

class HabitDetailPage extends StatelessWidget {
  final Habit habit;

  const HabitDetailPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final habitColor = Color(habit.colorValue);
    final today = _dateOnly(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: colors.primary),
            tooltip: 'Tahrirlash',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddHabitPage(initialHabit: habit),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent),
            tooltip: 'O\'chirish',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: BlocBuilder<HabitCubit, HabitState>(
        builder: (context, state) {
          final current =
              state.habits.where((h) => h.id == habit.id).firstOrNull ?? habit;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            current.emoji,
                            style: TextStyle(fontSize: 36.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        current.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        current.scheduleText,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colors.textMuted,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          _stat(
                            '${current.currentStreak()}',
                            'Joriy streak',
                            habitColor,
                            colors,
                          ),
                          _stat(
                            '${current.bestStreak()}',
                            'Eng yaxshi',
                            habitColor,
                            colors,
                          ),
                          _stat(
                            '${current.totalCompletions}',
                            'Jami',
                            habitColor,
                            colors,
                          ),
                          _stat(
                            _completionRateText(current, today),
                            '30 kun',
                            habitColor,
                            colors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'So\'nggi 12 hafta',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                _Heatmap(
                  habit: current,
                  habitColor: habitColor,
                  today: today,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(
    String value,
    String label,
    Color accent,
    AppColors colors,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  String _completionRateText(Habit h, DateTime today) {
    var scheduled = 0;
    var done = 0;
    for (var i = 0; i < 30; i++) {
      final d = today.subtract(Duration(days: i));
      if (h.isScheduledOn(d)) {
        scheduled++;
        if (h.isDoneOn(d)) done++;
      }
    }
    if (scheduled == 0) return '—';
    return '${(done / scheduled * 100).round()}%';
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Odatni o\'chirish'),
        content: const Text('Bu odat va uning butun tarixi o\'chiriladi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('O\'chirish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<HabitCubit>().deleteHabit(habit.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _Heatmap extends StatelessWidget {
  final Habit habit;
  final Color habitColor;
  final DateTime today;

  const _Heatmap({
    required this.habit,
    required this.habitColor,
    required this.today,
  });

  static const _weekdayLabels = ['Du', 'Se', 'Chor', 'Pay', 'Jum', 'Shan', 'Yak'];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final grid = _buildGrid(today);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: List.generate(7, (day) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              children: [
                SizedBox(
                  width: 34.w,
                  child: Text(
                    _weekdayLabels[day],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(12, (week) {
                      final date = grid[day][week];
                      return _cell(date, colors);
                    }),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _cell(DateTime date, AppColors colors) {
    final isFuture = date.isAfter(today);
    final isDone = habit.isDoneOn(date);
    final isScheduled = habit.isScheduledOn(date);
    final isToday = date == today;

    Color bg;
    if (isDone) {
      bg = habitColor;
    } else if (isScheduled && !isFuture) {
      bg = colors.cardBorder;
    } else {
      bg = Colors.transparent;
    }

    return Container(
      width: 16.r,
      height: 16.r,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.r),
        border: isToday
            ? Border.all(color: habitColor, width: 1.5)
            : null,
      ),
    );
  }

  List<List<DateTime>> _buildGrid(DateTime today) {
    final t = _dateOnly(today);
    final monday = t.subtract(Duration(days: t.weekday - 1));
    final startMonday = monday.subtract(const Duration(days: (12 - 1) * 7));
    return List.generate(7, (day) {
      return List.generate(12, (week) {
        return startMonday.add(Duration(days: week * 7 + day));
      });
    });
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
