import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/features/focus_timer/presentation/cubit/focus_timer_cubit.dart';
import '../../domain/entities/plan_task.dart';
import '../cubit/planner_cubit.dart';
import '../cubit/planner_state.dart';

class PlannerView extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const PlannerView({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerCubit, PlannerState>(
      builder: (context, state) {
        final cubit = context.read<PlannerCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kunlik Rejalar'),
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
                          label: 'Rejalar',
                          value: '${state.tasks.length}',
                          icon: Icons.checklist_rounded,
                        ),
                        Container(width: 1, height: 36, color: AppTheme.cardBorder),
                        _buildStat(
                          label: 'Bajarildi',
                          value: '${state.completedCount}',
                          icon: Icons.check_circle_outline_rounded,
                          color: Colors.greenAccent,
                        ),
                        Container(width: 1, height: 36, color: AppTheme.cardBorder),
                        _buildStat(
                          label: 'Fokus vaqti',
                          value: '${state.totalMinutesFocused} d',
                          icon: Icons.hourglass_bottom_rounded,
                          color: AppTheme.primaryAmber,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tasks List
                Expanded(
                  child: state.tasks.isEmpty
                      ? const Center(
                          child: Text(
                            'Hozircha rejalar yo\'q.\nYangi reja qo\'shing!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted),
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
            backgroundColor: AppTheme.primaryAmber,
            foregroundColor: Colors.black,
            onPressed: () => _showAddTaskSheet(context, cubit),
            icon: const Icon(Icons.add),
            label: const Text('Yangi Reja', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? AppTheme.textMuted),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.textLight,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildTaskTile(BuildContext context, PlanTask task, PlannerCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? Colors.greenAccent.withValues(alpha: 0.3)
              : AppTheme.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: Colors.greenAccent.shade700,
            checkColor: Colors.black,
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
                    color: task.isCompleted ? AppTheme.textMuted : AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fokus: ${task.completedMinutes}/${task.targetMinutes} daq',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Qumsoatga biriktirish',
            icon: const Icon(Icons.hourglass_top_rounded, color: AppTheme.primaryAmber, size: 20),
            onPressed: () {
              context.read<FocusTimerCubit>().attachTask(task.id, task.title);
              context.read<FocusTimerCubit>().setDurationMinutes(task.targetMinutes);
              onSwitchTab?.call(1); // switch to Qumsoat tab
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  const Text(
                    'Yangi Reja Qo\'shish',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: AppTheme.textLight),
                    decoration: InputDecoration(
                      hintText: 'Reja nomi (masalan: Dasturlash, Kitob mutolaasi)',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: Colors.black26,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mo\'ljallangan fokus vaqti:', style: TextStyle(color: AppTheme.textMuted)),
                      Text('$targetMinutes daqiqa',
                          style: const TextStyle(
                              color: AppTheme.primaryAmber, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: targetMinutes.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    activeColor: AppTheme.primaryAmber,
                    inactiveColor: AppTheme.cardBorder,
                    label: '$targetMinutes daq',
                    onChanged: (val) => setModalState(() => targetMinutes = val.toInt()),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAmber,
                      foregroundColor: Colors.black,
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
