import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../cubit/focus_timer_cubit.dart';
import '../cubit/focus_timer_state.dart';
import '../widgets/hourglass_widget.dart';

class FocusTimerView extends StatefulWidget {
  const FocusTimerView({super.key});

  @override
  State<FocusTimerView> createState() => _FocusTimerViewState();
}

class _FocusTimerViewState extends State<FocusTimerView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      context.read<FocusTimerCubit>().handleAppLifecycleBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<FocusTimerCubit, FocusTimerState>(
      listenWhen: (prev, curr) => curr.warningMessage != null && curr.warningMessage != prev.warningMessage,
      listener: (context, state) {
        if (state.warningMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade900,
              content: Text(
                state.warningMessage!,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.amber,
                onPressed: () => context.read<FocusTimerCubit>().clearWarning(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<FocusTimerCubit>();
        final isRunning = state.status == FocusStatus.running;

        return Scaffold(
          appBar: AppBar(
            title: Text('Qumsoat Fokus', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton(
                icon: Icon(
                  context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: colors.primary,
                  size: 22.r,
                ),
                tooltip: context.isDark ? 'Yorug\' rejim' : 'Qorong\'u rejim',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Active task indicator
                  if (state.activeTaskTitle != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: context.isDark ? 0.12 : 0.08),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_rounded, size: 16.r, color: colors.primary),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              'Reja: ${state.activeTaskTitle}',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => cubit.attachTask(null, null),
                            child: Icon(Icons.close, size: 16.r, color: colors.textMuted),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Fokus rejasini tanlang yoki mustaqil boshlang',
                      style: TextStyle(color: colors.textMuted, fontSize: 13.sp),
                    ),

                  SizedBox(height: 16.h),

                  // Hourglass Graphic
                  HourglassWidget(
                    progress: state.progress,
                    isRunning: isRunning,
                    size: 190.r,
                  ),
                  SizedBox(height: 16.h),

                  // Digital Countdown
                  Text(
                    state.formattedTime,
                    style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    state.status == FocusStatus.completed
                        ? '🎉 Fokus vaqti tugadi!'
                        : (isRunning
                            ? (state.isLocked ? '🔒 Deep Work: Ilovalar to\'silgan' : 'Fokusda bo\'ling...')
                            : 'Tayyormisiz?'),
                    style: TextStyle(
                      color: state.status == FocusStatus.completed || state.isLocked
                          ? colors.primary
                          : colors.textMuted,
                      fontSize: 14.sp,
                      fontWeight: state.isLocked ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Deep Work Mode Switch Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: state.isLocked ? colors.primary : colors.cardBorder,
                        width: state.isLocked ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.isLocked ? Icons.lock_rounded : Icons.lock_outline_rounded,
                          size: 22.r,
                          color: state.isLocked ? colors.primary : colors.textMuted,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qat\'iy rejim (Deep Work)',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                state.isLocked
                                    ? 'Ilova qulflangan (Pauza bosilguncha)'
                                    : 'Boshqa ilovalarga o\'tishni to\'sish',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: state.isLocked ? colors.primary : colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: state.isDeepWorkEnabled,
                          activeTrackColor: colors.primary.withValues(alpha: 0.5),
                          activeThumbColor: colors.primary,
                          onChanged: isRunning ? null : (v) => cubit.toggleDeepWork(v),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Duration presets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [15, 25, 45, 60].map((minutes) {
                      final isSelected = state.totalSeconds == minutes * 60;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: ChoiceChip(
                          label: Text('$minutes d', style: TextStyle(fontSize: 12.sp)),
                          selected: isSelected,
                          selectedColor: colors.primary,
                          backgroundColor: colors.card,
                          side: BorderSide(
                            color: isSelected ? colors.primary : colors.cardBorder,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : colors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12.sp,
                          ),
                          onSelected: isRunning ? null : (_) => cubit.setDurationMinutes(minutes),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 18.h),

                  // Action Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.status != FocusStatus.idle)
                        IconButton.filledTonal(
                          icon: Icon(Icons.replay_rounded, size: 24.r),
                          onPressed: () => cubit.reset(),
                          style: IconButton.styleFrom(
                            backgroundColor: colors.card,
                            foregroundColor: colors.textMuted,
                            side: BorderSide(color: colors.cardBorder),
                            minimumSize: Size(52.r, 52.r),
                          ),
                        ),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        onPressed: () {
                          if (isRunning) {
                            cubit.pause();
                          } else {
                            cubit.start();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRunning ? colors.card : colors.primary,
                          foregroundColor: isRunning ? colors.textPrimary : Colors.white,
                          side: isRunning ? BorderSide(color: colors.cardBorder) : null,
                          minimumSize: Size(160.w, 54.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 22.r),
                            SizedBox(width: 8.w),
                            Text(
                              isRunning ? 'Pauza' : 'Boshlash',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
