import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

const _weekdayLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class HabitView extends StatefulWidget {
  const HabitView({super.key});

  @override
  State<HabitView> createState() => _HabitViewState();
}

class _HabitViewState extends State<HabitView> {
  late DateTime _selected = _dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        final cubit = context.read<HabitCubit>();
        final dayHabits = state.habits
            .where((h) => h.isScheduledOn(_selected))
            .toList();
        final done = dayHabits.where((h) => h.isDoneOn(_selected)).length;

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
              _WeekStrip(
                selected: _selected,
                habits: state.habits,
                onSelect: (day) => setState(() => _selected = day),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                child: Row(
                  children: [
                    Text(
                      _dayTitle(_selected),
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (dayHabits.isNotEmpty)
                      Text(
                        '$done/${dayHabits.length}',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child:
                    state.status == HabitStatus.loading && state.habits.isEmpty
                    ? const Center(child: CupertinoActivityIndicator())
                    : state.habits.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 96.h),
                        itemCount: state.habits.length,
                        separatorBuilder: (_, _) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final habit = state.habits[index];
                          return _HabitRow(
                            habit: habit,
                            day: _selected,
                            onToggle: () =>
                                cubit.toggleDate(habit.id, _selected),
                            onOpen: () => context.push(
                              RoutePath.habitDetail,
                              extra: habit,
                            ),
                          );
                        },
                      ),
              ),
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

  String _dayTitle(DateTime day) {
    final today = _dateOnly(DateTime.now());
    if (day == today) return 'Bugun';
    if (day == today.subtract(const Duration(days: 1))) return 'Kecha';
    const months = [
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avgust',
      'sentabr',
      'oktabr',
      'noyabr',
      'dekabr',
    ];
    return '${day.day}-${months[day.month - 1]}';
  }
}

/// Week calendar: swipe-free, chevrons move by week. Future days are locked.
class _WeekStrip extends StatefulWidget {
  final DateTime selected;
  final List<Habit> habits;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip({
    required this.selected,
    required this.habits,
    required this.onSelect,
  });

  @override
  State<_WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<_WeekStrip> {
  int _weekOffset = 0; // 0 = this week, -1 = previous week, ...

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final today = _dateOnly(DateTime.now());
    final monday = today
        .subtract(Duration(days: today.weekday - 1))
        .add(Duration(days: _weekOffset * 7));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          _chevron(CupertinoIcons.chevron_left, colors, () {
            setState(() => _weekOffset--);
          }),
          Expanded(
            child: Row(
              children: List.generate(7, (i) {
                final day = monday.add(Duration(days: i));
                return Expanded(child: _dayCell(day, today, colors));
              }),
            ),
          ),
          _chevron(
            CupertinoIcons.chevron_right,
            colors,
            _weekOffset < 0 ? () => setState(() => _weekOffset++) : null,
          ),
        ],
      ),
    );
  }

  Widget _chevron(IconData icon, AppColors colors, VoidCallback? onTap) {
    return CupertinoButton(
      padding: EdgeInsets.all(6.r),
      minimumSize: Size(32.r, 44.r),
      onPressed: onTap,
      child: Icon(
        icon,
        size: 18.r,
        color: onTap == null ? colors.cardBorder : colors.textMuted,
      ),
    );
  }

  Widget _dayCell(DateTime day, DateTime today, AppColors colors) {
    final isFuture = day.isAfter(today);
    final isSelected = day == widget.selected;
    final isToday = day == today;
    final scheduled = widget.habits.where((h) => h.isScheduledOn(day));
    final progress = scheduled.isEmpty || isFuture
        ? 0.0
        : scheduled.where((h) => h.isDoneOn(day)).length / scheduled.length;

    final numberColor = isSelected
        ? colors.onPrimary
        : isFuture
        ? colors.textMuted.withValues(alpha: 0.5)
        : isToday
        ? colors.primary
        : colors.textPrimary;

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      selected: isSelected,
      label: '${day.day}-kun',
      onTap: isFuture ? null : () => widget.onSelect(day),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isFuture ? null : () => widget.onSelect(day),
        child: Column(
          children: [
            Text(
              _weekdayLabels[day.weekday - 1],
              style: TextStyle(color: colors.textMuted, fontSize: 11.sp),
            ),
            SizedBox(height: 6.h),
            SizedBox(
              width: 38.r,
              height: 38.r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Thin ring = share of that day's habits done.
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2.5,
                    backgroundColor: isFuture
                        ? Colors.transparent
                        : colors.cardBorder,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                  ),
                  Container(
                    width: 30.r,
                    height: 30.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? colors.primary : Colors.transparent,
                    ),
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: numberColor,
                        fontSize: 13.sp,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final Habit habit;
  final DateTime day;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  const _HabitRow({
    required this.habit,
    required this.day,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final habitColor = Color(habit.colorValue);
    final isDone = habit.isDoneOn(day);
    final isScheduled = habit.isScheduledOn(day);
    final streak = habit.currentStreak();

    return Opacity(
      opacity: isScheduled ? 1 : 0.45,
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 6.w, 10.h),
            child: Row(
              children: [
                Text(habit.emoji, style: TextStyle(fontSize: 24.sp)),
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
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isScheduled)
                  Semantics(
                    container: true,
                    button: true,
                    checked: isDone,
                    label: '${habit.name}: bajarildi deb belgilash',
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(44.r, 44.r),
                      onPressed: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? habitColor : Colors.transparent,
                          border: Border.all(
                            color: isDone ? habitColor : colors.cardBorder,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? Icon(
                                Icons.check_rounded,
                                size: 18.r,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  )
                else
                  SizedBox(width: 44.r),
              ],
            ),
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
