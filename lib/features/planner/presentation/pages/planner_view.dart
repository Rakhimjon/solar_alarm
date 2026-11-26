import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_alarm/core/router/path.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/core/theme/theme_cubit.dart';
import 'package:solar_alarm/core/widgets/custom_button.dart';
import 'package:solar_alarm/features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
import 'package:solar_alarm/features/planner/domain/entities/plan_task.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_state.dart';

class PlannerView extends StatefulWidget {
  const PlannerView({super.key});

  @override
  State<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends State<PlannerView> {
  String _selectedCategory = 'Barchasi';

  static const List<Map<String, dynamic>> _categories = [
    {'title': 'Barchasi', 'icon': Icons.all_inclusive_rounded},
    {'title': 'Ish & O\'qish', 'icon': Icons.laptop_mac_rounded},
    {'title': 'Ibodat & Ilm', 'icon': Icons.mosque_rounded},
    {'title': 'Sport & Salomatlik', 'icon': Icons.fitness_center_rounded},
    {'title': 'Shaxsiy', 'icon': Icons.person_rounded},
  ];

  Future<void> _openAddTask() async {
    final categories = _categories
        .map((category) => category['title'] as String)
        .where((title) => title != 'Barchasi')
        .toList();
    final initialCategory = _selectedCategory == 'Barchasi'
        ? categories.first
        : _selectedCategory;

    final task = await context.push<PlanTask>(
      RoutePath.addPlan,
      extra: {'categories': categories, 'initialCategory': initialCategory},
    );

    if (!mounted || task == null) return;
    if (task.useTimer) {
      context.read<FocusTimerCubit>().attachTask(task.id, task.title);
      context.read<FocusTimerCubit>().setDurationMinutes(task.targetMinutes);
      context.go(RoutePath.focus);
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reja saqlandi')));
  }

  void _startFocus(PlanTask task) {
    context.read<FocusTimerCubit>().attachTask(task.id, task.title);
    context.read<FocusTimerCubit>().setDurationMinutes(task.targetMinutes);
    context.go(RoutePath.focus);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        final cubit = context.read<PlannerCubit>();
        final filteredTasks = _selectedCategory == 'Barchasi'
            ? state.tasks
            : state.tasks
                  .where(
                    (task) => (task.category ?? 'Shaxsiy') == _selectedCategory,
                  )
                  .toList();
        final totalTasks = state.tasks.length;
        final progress = totalTasks == 0
            ? 0.0
            : state.completedCount / totalTasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kunlik Rejalar'),
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
                  total: totalTasks,
                  completed: state.completedCount,
                  progress: progress,
                  focusMinutes: state.totalMinutesFocused,
                ),
              ),
              SizedBox(
                height: 44.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 4.w),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final title = category['title'] as String;
                    final selected = title == _selectedCategory;
                    return CupertinoButton(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      minimumSize: Size(0, 36.h),
                      borderRadius: BorderRadius.circular(18.r),
                      color: selected
                          ? colors.primary.withValues(alpha: 0.15)
                          : null,
                      onPressed: () =>
                          setState(() => _selectedCategory = title),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: selected ? colors.primary : colors.textMuted,
                          fontSize: 13.sp,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child:
                    state.status == PlannerStatus.loading && state.tasks.isEmpty
                    ? const Center(child: CupertinoActivityIndicator())
                    : filteredTasks.isEmpty
                    ? _EmptyState(category: _selectedCategory)
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 88.h),
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return _TaskCard(
                            task: task,
                            categories: _categories,
                            onToggle: () => cubit.toggleDone(task.id),
                            onDelete: () => cubit.deleteTask(task.id),
                            onFocus: () => _startFocus(task),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _AddPlanButton(onPressed: _openAddTask),
        );
      },
    );
  }
}

class _AddPlanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddPlanButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      title: 'Yangi Reja',
      icon: const Icon(CupertinoIcons.add),
      borderRadius: 28.r,
      onTap: onPressed,
    );
  }
}

class _HeroCard extends StatelessWidget {
  final int total;
  final int completed;
  final double progress;
  final int focusMinutes;

  const _HeroCard({
    required this.total,
    required this.completed,
    required this.progress,
    required this.focusMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final message = total == 0
        ? 'Bugungi kuningizni rejalashtiring!'
        : completed == total
        ? 'Ajoyib! Barcha rejalar bajarildi!'
        : progress >= 0.5
        ? 'Yarmidan ko\'pi bajarildi, davom eting!'
        : 'Qadam-baqadam maqsad sari!';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
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
                Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: [
                    _Stat(
                      icon: Icons.check_circle_outline_rounded,
                      text: '$completed/$total bajarildi',
                    ),
                    _Stat(
                      icon: Icons.hourglass_bottom_rounded,
                      text: '$focusMinutes daq fokus',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Stat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: colors.primary),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(color: colors.textMuted, fontSize: 11.sp),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final PlanTask task;
  final List<Map<String, dynamic>> categories;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onFocus;

  const _TaskCard({
    required this.task,
    required this.categories,
    required this.onToggle,
    required this.onDelete,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final category = task.category ?? 'Shaxsiy';
    final categoryData = categories.firstWhere(
      (item) => item['title'] == category,
      orElse: () => {'icon': Icons.task_alt_rounded},
    );
    final focusProgress = task.targetMinutes == 0
        ? 0.0
        : (task.completedMinutes / task.targetMinutes).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          children: [
            Row(
              children: [
                Semantics(
                  button: true,
                  checked: task.isCompleted,
                  label: '${task.title}: bajarilgan deb belgilash',
                  child: InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(24.r),
                    child: SizedBox(
                      width: 44.r,
                      height: 44.r,
                      child: Center(
                        child: Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted
                                ? Colors.green
                                : Colors.transparent,
                            border: Border.all(
                              color: task.isCompleted
                                  ? Colors.green
                                  : colors.textMuted,
                              width: 2,
                            ),
                          ),
                          child: task.isCompleted
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16.r,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: task.isCompleted
                          ? colors.textMuted
                          : colors.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Rejani o\'chirish',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Icon(
                    categoryData['icon'] as IconData,
                    size: 14.r,
                    color: colors.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      task.useTimer ? category : '$category • Timersiz',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  if (task.useTimer && !task.isCompleted)
                    CustomButton(
                      title: 'Fokus',
                      icon: Icon(Icons.hourglass_top_rounded, size: 16.r),
                      borderRadius: 20.r,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      textStyle: TextStyle(
                        color: colors.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: onFocus,
                    ),
                ],
              ),
            ),
            if (task.useTimer) ...[
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: focusProgress,
                        minHeight: 4.h,
                        backgroundColor: colors.cardBorder,
                        valueColor: AlwaysStoppedAnimation(
                          focusProgress >= 1 ? Colors.green : colors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${task.completedMinutes}/${task.targetMinutes} daq',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String category;

  const _EmptyState({required this.category});

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
              Icons.assignment_outlined,
              size: 56.r,
              color: colors.textMuted,
            ),
            SizedBox(height: 12.h),
            Text(
              category == 'Barchasi'
                  ? 'Hozircha rejalar yo\'q'
                  : '$category bo\'yicha reja yo\'q',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Yangi Reja tugmasi bilan timerli yoki timersiz reja qo\'shing',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }
}
