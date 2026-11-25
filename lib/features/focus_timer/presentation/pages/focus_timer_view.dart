import 'package:flutter/cupertino.dart';
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
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.resumed) {
      context.read<FocusTimerCubit>().handleAppLifecycleState(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<FocusTimerCubit, FocusTimerState>(
      listenWhen: (prev, curr) => curr.warningMessage != null && curr.warningMessage != prev.warningMessage,
      listener: (context, state) {
        if (state.warningMessage != null) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Fokus ogohlantirish'),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(state.warningMessage!),
              ),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.read<FocusTimerCubit>().clearWarning();
                  },
                  child: const Text('Tushunarli'),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<FocusTimerCubit>();
        final isRunning = state.status == FocusStatus.running;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: CupertinoNavigationBar(
            middle: Text(
              'Qumsoat Fokus',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: colors.background.withValues(alpha: context.isDark ? 0.78 : 0.88),
            border: Border(
              bottom: BorderSide(
                color: colors.cardBorder.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size(36.r, 36.r),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              child: Icon(
                context.isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                color: colors.primary,
                size: 22.r,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Active task indicator (iOS Pill Tag)
                  if (state.activeTaskTitle != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: context.isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.bookmark_fill, size: 15.r, color: colors.primary),
                          SizedBox(width: 6.w),
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
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => cubit.attachTask(null, null),
                            child: Icon(
                              CupertinoIcons.clear_circled_solid,
                              size: 16.r,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      'Fokus rejasini tanlang yoki mustaqil boshlang',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 13.sp,
                        letterSpacing: -0.2,
                      ),
                    ),

                  SizedBox(height: 16.h),

                  // Hourglass Graphic
                  HourglassWidget(
                    progress: state.progress,
                    isRunning: isRunning,
                    size: 190.r,
                  ),
                  SizedBox(height: 16.h),

                  // Digital Countdown with iOS tabular figures
                  Text(
                    state.formattedTime,
                    style: TextStyle(
                      fontSize: 52.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
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
                      fontWeight: state.isLocked ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Duration Presets using CupertinoSlidingSegmentedControl
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: state.totalSeconds ~/ 60,
                      backgroundColor: context.isDark
                          ? const Color(0xFF1E2837)
                          : const Color(0xFFE2E8F0),
                      thumbColor: context.isDark ? colors.card : Colors.white,
                      children: {
                        15: Padding(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          child: Text(
                            '15 daq',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: state.totalSeconds == 15 * 60 ? FontWeight.w600 : FontWeight.w500,
                              color: state.totalSeconds == 15 * 60 ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ),
                        25: Padding(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          child: Text(
                            '25 daq',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: state.totalSeconds == 25 * 60 ? FontWeight.w600 : FontWeight.w500,
                              color: state.totalSeconds == 25 * 60 ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ),
                        45: Padding(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          child: Text(
                            '45 daq',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: state.totalSeconds == 45 * 60 ? FontWeight.w600 : FontWeight.w500,
                              color: state.totalSeconds == 45 * 60 ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ),
                        60: Padding(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          child: Text(
                            '60 daq',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: state.totalSeconds == 60 * 60 ? FontWeight.w600 : FontWeight.w500,
                              color: state.totalSeconds == 60 * 60 ? colors.primary : colors.textPrimary,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (val) {
                        if (isRunning || val == null) return;
                        cubit.setDurationMinutes(val);
                      },
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Deep Work Mode Switch Card (iOS Grouped Cell Style)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: state.isLocked
                            ? colors.primary.withValues(alpha: 0.6)
                            : colors.cardBorder.withValues(alpha: 0.8),
                        width: state.isLocked ? 1.5 : 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: (state.isLocked ? colors.primary : colors.textMuted)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            state.isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.lock,
                            size: 20.r,
                            color: state.isLocked ? colors.primary : colors.textMuted,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qat\'iy rejim (Deep Work)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                state.isLocked
                                    ? 'Ilova qulflangan (Pauza bosilguncha)'
                                    : 'Boshqa ilovalarga o\'tishni to\'sish',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: state.isLocked ? colors.primary : colors.textMuted,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: state.isDeepWorkEnabled,
                          activeTrackColor: colors.primary,
                          onChanged: isRunning ? null : (v) => cubit.toggleDeepWork(v),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Action Controls (iOS Cupertino Buttons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.status != FocusStatus.idle)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(52.r, 52.r),
                          borderRadius: BorderRadius.circular(26.r),
                          color: colors.card,
                          onPressed: () => cubit.reset(),
                          child: Container(
                            width: 52.r,
                            height: 52.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.cardBorder.withValues(alpha: 0.8),
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              CupertinoIcons.arrow_counterclockwise,
                              size: 22.r,
                              color: colors.textMuted,
                            ),
                          ),
                        ),
                      if (state.status != FocusStatus.idle) SizedBox(width: 16.w),
                      CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                        borderRadius: BorderRadius.circular(30.r),
                        color: isRunning ? colors.card : colors.primary,
                        onPressed: () {
                          if (isRunning) {
                            cubit.pause();
                          } else {
                            cubit.start();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                              size: 20.r,
                              color: isRunning ? colors.textPrimary : Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              isRunning ? 'Pauza' : 'Boshlash',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isRunning ? colors.textPrimary : Colors.white,
                                letterSpacing: -0.3,
                              ),
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
