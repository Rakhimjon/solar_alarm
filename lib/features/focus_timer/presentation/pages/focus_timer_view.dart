import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import '../cubit/focus_timer_cubit.dart';
import '../cubit/focus_timer_state.dart';
import '../widgets/hourglass_widget.dart';

class FocusTimerView extends StatelessWidget {
  const FocusTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusTimerCubit, FocusTimerState>(
      builder: (context, state) {
        final cubit = context.read<FocusTimerCubit>();
        final isRunning = state.status == FocusStatus.running;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Qumsoat Fokus'),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Active task indicator
                if (state.activeTaskTitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryAmber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_rounded, size: 16, color: AppTheme.primaryAmber),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Reja: ${state.activeTaskTitle}',
                            style: const TextStyle(
                              color: AppTheme.primaryAmber,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => cubit.attachTask(null, null),
                          child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    'Fokus rejasini tanlang yoki mustaqil boshlang',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                const Spacer(),

                // Hourglass Graphic
                HourglassWidget(
                  progress: state.progress,
                  isRunning: isRunning,
                  size: 210,
                ),
                const SizedBox(height: 24),

                // Digital Countdown
                Text(
                  state.formattedTime,
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: AppTheme.textLight,
                  ),
                ),
                Text(
                  state.status == FocusStatus.completed
                      ? '🎉 Fokus vaqti tugadi!'
                      : (isRunning ? 'Fokusda bo\'ling...' : 'Tayyormisiz?'),
                  style: TextStyle(
                    color: state.status == FocusStatus.completed
                        ? AppTheme.primaryAmber
                        : AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),

                // Duration presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [15, 25, 45, 60].map((minutes) {
                    final isSelected = state.totalSeconds == minutes * 60;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text('$minutes d'),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryAmber,
                        backgroundColor: AppTheme.cardColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : AppTheme.textLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) => cubit.setDurationMinutes(minutes),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Action Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.status != FocusStatus.idle)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.replay_rounded),
                        onPressed: () => cubit.reset(),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.cardColor,
                          foregroundColor: AppTheme.textMuted,
                          minimumSize: const Size(54, 54),
                        ),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (isRunning) {
                          cubit.pause();
                        } else {
                          cubit.start();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning ? AppTheme.cardColor : AppTheme.primaryAmber,
                        foregroundColor: isRunning ? AppTheme.textLight : Colors.black,
                        side: isRunning ? const BorderSide(color: AppTheme.cardBorder) : null,
                        minimumSize: const Size(160, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                          const SizedBox(width: 8),
                          Text(
                            isRunning ? 'Pauza' : 'Boshlash',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
