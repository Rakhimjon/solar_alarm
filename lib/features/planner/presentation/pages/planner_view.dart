import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../focus_timer/presentation/cubit/focus_timer_cubit.dart';
import '../../domain/entities/plan_task.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';

class PlannerView extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const PlannerView({super.key, this.onSwitchTab});

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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        final cubit = context.read<PlannerCubit>();

        final filteredTasks = _selectedCategory == 'Barchasi'
            ? state.tasks
            : state.tasks.where((t) => (t.category ?? 'Shaxsiy') == _selectedCategory).toList();

        final totalTasks = state.tasks.length;
        final completedTasks = state.completedCount;
        final progressRatio = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks).clamp(0.0, 1.0);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kunlik Rejalar'),
            actions: [
              IconButton(
                icon: Icon(
                  context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: colors.primary,
                ),
                tooltip: context.isDark ? 'Yorug\' rejim' : 'Qorong\'u rejim',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Productivity Hero Card (Things 3 / TickTick style ring + stats)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: _buildHeroCard(context, totalTasks, completedTasks, progressRatio, state.totalMinutesFocused),
              ),

              // 2. Category Filter Bar (Horizontal scrolling chips)
              SizedBox(
                height: 44.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final title = cat['title'] as String;
                    final icon = cat['icon'] as IconData;
                    final isSelected = _selectedCategory == title;

                    return FilterChip(
                      selected: isSelected,
                      avatar: Icon(
                        icon,
                        size: 16.r,
                        color: isSelected ? Colors.white : colors.textMuted,
                      ),
                      label: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                      ),
                      backgroundColor: colors.card,
                      selectedColor: colors.primary,
                      showCheckmark: false,
                      side: BorderSide(
                        color: isSelected ? colors.primary : colors.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      onSelected: (_) => setState(() => _selectedCategory = title),
                    );
                  },
                ),
              ),

              SizedBox(height: 10.h),

              // 3. Task List
              Expanded(
                child: filteredTasks.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return _buildTaskCard(context, task, cubit);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () => _showAddTaskSheet(context, cubit),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Yangi Reja',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    int total,
    int completed,
    double progress,
    int totalFocusMinutes,
  ) {
    final colors = context.appColors;
    final percent = (progress * 100).toInt();

    String motivationalMessage;
    if (total == 0) {
      motivationalMessage = 'Bugungi kuningizni rejalashtiring!';
    } else if (completed == total) {
      motivationalMessage = 'Ajoyib natija! Barcha rejalar bajarildi!';
    } else if (progress >= 0.5) {
      motivationalMessage = 'Yarmidan ko\'pi bajarildi, davom eting!';
    } else {
      motivationalMessage = 'Qadam-baqadam maqsad sari!';
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completed == total && total > 0
                        ? (context.isDark ? Colors.greenAccent : Colors.green)
                        : colors.primary,
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),

          // Progress text & stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motivationalMessage,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _buildPillStat(
                      context,
                      Icons.check_circle_outline_rounded,
                      '$completed/$total bajarildi',
                      completed == total && total > 0
                          ? (context.isDark ? Colors.greenAccent : Colors.green.shade600)
                          : colors.textMuted,
                    ),
                    SizedBox(width: 8.w),
                    _buildPillStat(
                      context,
                      Icons.hourglass_bottom_rounded,
                      '$totalFocusMinutes daq fokus',
                      colors.primary,
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

  Widget _buildPillStat(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, PlanTask task, PlannerCubit cubit) {
    final colors = context.appColors;
    final category = task.category ?? 'Shaxsiy';

    // Choose category color and icon
    final catData = _categories.firstWhere(
      (c) => c['title'] == category,
      orElse: () => {'icon': Icons.task_alt_rounded},
    );

    final focusRatio = task.targetMinutes > 0
        ? (task.completedMinutes / task.targetMinutes).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: task.isCompleted
              ? (context.isDark ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.4))
              : colors.cardBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => cubit.toggleDone(task.id),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Round Checkbox
                  GestureDetector(
                    onTap: () => cubit.toggleDone(task.id),
                    child: Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted
                            ? (context.isDark ? Colors.greenAccent.shade700 : Colors.green.shade600)
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted
                              ? (context.isDark ? Colors.greenAccent.shade700 : Colors.green.shade600)
                              : colors.textMuted.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted
                          ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Title & Category tag
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? colors.textMuted : colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(catData['icon'] as IconData, size: 11.r, color: colors.textMuted),
                            SizedBox(width: 4.w),
                            Text(
                              category,
                              style: TextStyle(fontSize: 11.sp, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 1-Tap Focus Launcher Button (Qumsoat)
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary.withValues(alpha: 0.15),
                      foregroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: () {
                      context.read<FocusTimerCubit>().attachTask(task.id, task.title);
                      context.read<FocusTimerCubit>().setDurationMinutes(task.targetMinutes);
                      widget.onSwitchTab?.call(1);
                    },
                    icon: Icon(Icons.hourglass_top_rounded, size: 14.r),
                    label: Text(
                      'Fokus',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Delete option
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withValues(alpha: 0.8), size: 18.r),
                    onPressed: () => cubit.deleteTask(task.id),
                  ),
                ],
              ),

              // Focus Progress Sub-Bar (Todoist/TickTick style indicator)
              if (task.targetMinutes > 0) ...[
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: focusRatio,
                          minHeight: 4.h,
                          backgroundColor: colors.cardBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            focusRatio >= 1.0 ? Colors.green : colors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${task.completedMinutes}/${task.targetMinutes} daq',
                      style: TextStyle(fontSize: 10.sp, color: colors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 56.r, color: colors.textMuted.withValues(alpha: 0.4)),
          SizedBox(height: 12.h),
          Text(
            _selectedCategory == 'Barchasi'
                ? 'Hozircha rejalar yo\'q'
                : '$_selectedCategory bo\'yicha reja yo\'q',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          SizedBox(height: 6.h),
          Text(
            'Quyidagi tugma orqali yangi reja qo\'shing',
            style: TextStyle(fontSize: 12.sp, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, PlannerCubit cubit) {
    final titleController = TextEditingController();
    int targetMinutes = 25;
    String selectedCategory = _selectedCategory == 'Barchasi' ? 'Ish & O\'qish' : _selectedCategory;
    final colors = context.appColors;

    final presetMinutes = [15, 25, 45, 60];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sheetColors = context.appColors;

            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Header Handle
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: sheetColors.textMuted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yangi Reja Qo\'shish',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: sheetColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Title input field
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      style: TextStyle(color: sheetColors.textPrimary, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Reja nomi (masalan: Dasturlash, Kitob o\'qish)',
                        hintStyle: TextStyle(color: sheetColors.textMuted, fontSize: 13.sp),
                        filled: true,
                        fillColor: context.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: sheetColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: sheetColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(color: sheetColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Category Selector
                    Text(
                      'Kategoriya',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: sheetColors.textMuted),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: _categories.where((c) => c['title'] != 'Barchasi').map((cat) {
                        final title = cat['title'] as String;
                        final icon = cat['icon'] as IconData;
                        final isSel = selectedCategory == title;

                        return ChoiceChip(
                          selected: isSel,
                          avatar: Icon(icon, size: 14.r, color: isSel ? Colors.white : sheetColors.textMuted),
                          label: Text(
                            title,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : sheetColors.textPrimary,
                            ),
                          ),
                          selectedColor: sheetColors.primary,
                          backgroundColor: context.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                          showCheckmark: false,
                          side: BorderSide(color: isSel ? sheetColors.primary : sheetColors.cardBorder),
                          onSelected: (_) => setModalState(() => selectedCategory = title),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),

                    // Quick Focus Duration presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mo\'ljallangan fokus vaqti',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: sheetColors.textMuted),
                        ),
                        Text(
                          '$targetMinutes daqiqa',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: sheetColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Presets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: presetMinutes.map((mins) {
                        final isSel = targetMinutes == mins;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: isSel ? sheetColors.primary : Colors.transparent,
                                foregroundColor: isSel ? Colors.white : sheetColors.textPrimary,
                                side: BorderSide(color: isSel ? sheetColors.primary : sheetColors.cardBorder),
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                              onPressed: () => setModalState(() => targetMinutes = mins),
                              child: Text(
                                '$mins m',
                                style: TextStyle(fontSize: 12.sp, fontWeight: isSel ? FontWeight.bold : FontWeight.w500),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10.h),

                    // Slider for custom minute
                    Slider(
                      value: targetMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      activeColor: sheetColors.primary,
                      inactiveColor: sheetColors.cardBorder,
                      label: '$targetMinutes daq',
                      onChanged: (val) => setModalState(() => targetMinutes = val.toInt()),
                    ),
                    SizedBox(height: 16.h),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(48.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          cubit.createTask(
                            titleController.text.trim(),
                            targetMinutes,
                            category: selectedCategory,
                          );
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: Text(
                        'Rejani Saqlash',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
