import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../focus_timer/presentation/cubit/focus_timer_cubit.dart';
import '../../domain/entities/plan_task.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';

class PlannerView extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const PlannerView({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        final cubit = context.read<PlannerCubit>();

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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Stats Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          context: context,
                          label: 'Rejalar',
                          value: '${state.tasks.length}',
                          icon: Icons.checklist_rounded,
                        ),
                        Container(width: 1, height: 36, color: colors.cardBorder),
                        _buildStat(
                          context: context,
                          label: 'Bajarildi',
                          value: '${state.completedCount}',
                          icon: Icons.check_circle_outline_rounded,
                          color: context.isDark ? Colors.greenAccent : Colors.green.shade600,
                        ),
                        Container(width: 1, height: 36, color: colors.cardBorder),
                        _buildStat(
                          context: context,
                          label: 'Fokus vaqti',
                          value: '${state.totalMinutesFocused} d',
                          icon: Icons.hourglass_bottom_rounded,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks List
                Expanded(
                  child: state.tasks.isEmpty
                      ? Center(
                          child: Text(
                            'Hozircha rejalar yo\'q.\nYangi reja qo\'shing!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: state.tasks.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final task = state.tasks[index];
                            return _buildTaskTile(context, task, cubit);
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showAddTaskSheet(context, cubit),
            icon: const Icon(Icons.add),
            label: const Text('Yangi Reja', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildStat({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    final colors = context.appColors;
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? colors.textMuted),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.textMuted),
        ),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, PlanTask task, PlannerCubit cubit) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? (context.isDark ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.green.withValues(alpha: 0.4))
              : colors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: context.isDark ? Colors.greenAccent.shade700 : Colors.green.shade600,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onChanged: (_) => cubit.toggleDone(task.id),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? colors.textMuted : colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fokus: ${task.completedMinutes}/${task.targetMinutes} daq',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Qumsoatga biriktirish',
            icon: Icon(Icons.hourglass_top_rounded, color: colors.primary, size: 20),
            onPressed: () {
              context.read<FocusTimerCubit>().attachTask(task.id, task.title);
              context.read<FocusTimerCubit>().setDurationMinutes(task.targetMinutes);
              onSwitchTab?.call(1);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () => cubit.deleteTask(task.id),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context, PlannerCubit cubit) {
    final titleController = TextEditingController();
    int targetMinutes = 25;
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sheetColors = context.appColors;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Yangi Reja Qo\'shish',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: sheetColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: TextStyle(color: sheetColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Reja nomi (masalan: Dasturlash, Kitob mutolaasi)',
                      hintStyle: TextStyle(color: sheetColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: context.isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: sheetColors.cardBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: sheetColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: sheetColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mo\'ljallangan fokus vaqti:', style: TextStyle(color: sheetColors.textMuted)),
                      Text('$targetMinutes daqiqa',
                          style: TextStyle(
                              color: sheetColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
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
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sheetColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        cubit.createTask(titleController.text.trim(), targetMinutes);
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
