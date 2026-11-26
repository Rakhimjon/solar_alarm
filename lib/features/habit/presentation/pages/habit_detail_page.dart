import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_alarm/core/router/path.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_cubit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_state.dart';

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
            onPressed: () => context.push(
              RoutePath.addHabit,
              extra:
                  context
                      .read<HabitCubit>()
                      .state
                      .habits
                      .where((h) => h.id == habit.id)
                      .firstOrNull ??
                  habit,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
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
                  'Kalendar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: 10.h),
                _MonthCalendar(
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

  Widget _stat(String value, String label, Color accent, AppColors colors) {
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
            child: const Text(
              'O\'chirish',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<HabitCubit>().deleteHabit(habit.id);
      if (context.mounted) context.pop();
    }
  }
}

/// Month grid. Tap a past/today scheduled day (since creation) to toggle it.
class _MonthCalendar extends StatefulWidget {
  final Habit habit;
  final Color habitColor;
  final DateTime today;

  const _MonthCalendar({
    required this.habit,
    required this.habitColor,
    required this.today,
  });

  @override
  State<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<_MonthCalendar> {
  static const _weekdayLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
  static const _months = [
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentabr',
    'Oktabr',
    'Noyabr',
    'Dekabr',
  ];

  late DateTime _month = DateTime(widget.today.year, widget.today.month);

  bool get _isCurrentMonth =>
      _month.year == widget.today.year && _month.month == widget.today.month;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = _month.weekday - 1; // empty cells before day 1
    final rows = ((leading + daysInMonth) / 7).ceil();

    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 12.h),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(8.r),
                onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 18.r,
                  color: colors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  '${_months[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.all(8.r),
                onPressed: _isCurrentMonth
                    ? null
                    : () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      ),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 18.r,
                  color: _isCurrentMonth ? colors.cardBorder : colors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: _weekdayLabels
                .map(
                  (label) => Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 6.h),
          for (var r = 0; r < rows; r++)
            Row(
              children: List.generate(7, (c) {
                final dayNumber = r * 7 + c - leading + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox());
                }
                return Expanded(
                  child: _dayCell(
                    DateTime(_month.year, _month.month, dayNumber),
                    colors,
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime date, AppColors colors) {
    final habit = widget.habit;
    final isFuture = date.isAfter(widget.today);
    final isBeforeStart = date.isBefore(_dateOnly(habit.createdAt));
    final isScheduled = habit.isScheduledOn(date);
    final isDone = habit.isDoneOn(date);
    final isToday = date == widget.today;
    final canToggle = isScheduled && !isFuture && !isBeforeStart;

    final textColor = isDone
        ? Colors.white
        : !isScheduled || isFuture || isBeforeStart
        ? colors.textMuted.withValues(alpha: 0.45)
        : colors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canToggle
          ? () => context.read<HabitCubit>().toggleDate(habit.id, date)
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Center(
          child: Container(
            width: 36.r,
            height: 36.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? widget.habitColor : Colors.transparent,
              border: isToday && !isDone
                  ? Border.all(color: widget.habitColor, width: 1.5)
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontSize: 13.sp,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
