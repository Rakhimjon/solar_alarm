import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/focus_timer_cubit.dart';
import '../cubit/focus_timer_state.dart';
import '../widgets/hourglass_widget.dart';

class FocusTimerView extends StatefulWidget {
  const FocusTimerView({super.key});

  @override
  State<FocusTimerView> createState() => _FocusTimerViewState();
}

class _FocusTimerViewState extends State<FocusTimerView>
    with WidgetsBindingObserver {
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
      listenWhen: (prev, curr) =>
          curr.warningMessage != null &&
          curr.warningMessage != prev.warningMessage,
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
          appBar: AppBar(
            title: const Text('Qumsoat Fokus'),
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
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
              child: Column(
                children: [
                  // Attached plan: plain text, tap ✕ to detach.
                  SizedBox(
                    height: 24.h,
                    child: state.activeTaskTitle == null
                        ? null
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  state.activeTaskTitle!,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.only(left: 6.w),
                                minimumSize: Size(28.r, 28.r),
                                onPressed: () => cubit.attachTask(null, null),
                                child: Icon(
                                  CupertinoIcons.xmark_circle_fill,
                                  size: 16.r,
                                  color: colors.cardBorder,
                                ),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(height: 8.h),
                  HourglassWidget(
                    progress: state.progress,
                    isRunning: isRunning,
                    size: 170.r,
                  ),
                  SizedBox(height: 20.h),

                  // Tap the time to set a custom duration (only when idle).
                  Semantics(
                    button: state.status == FocusStatus.idle,
                    label: 'Vaqtni o\'zgartirish',
                    child: GestureDetector(
                      onTap: state.status == FocusStatus.idle
                          ? () => _pickDuration(context, state.totalSeconds)
                          : null,
                      child: Text(
                        state.formattedTime,
                        style: TextStyle(
                          fontSize: 64.sp,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    state.status == FocusStatus.completed
                        ? 'Fokus vaqti tugadi 🎉'
                        : isRunning
                        ? (state.isLocked ? '🔒 Deep Work' : 'Fokusda bo\'ling')
                        : state.status == FocusStatus.idle
                        ? 'Vaqtni o\'zgartirish uchun bosing'
                        : 'Pauza',
                    style: TextStyle(
                      color: state.isLocked ? colors.primary : colors.textMuted,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Presets: plain text, selected one in primary color.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [15, 25, 45, 60].map((m) {
                      final selected = state.totalSeconds == m * 60;
                      return CupertinoButton(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        onPressed: isRunning
                            ? null
                            : () => cubit.setDurationMinutes(m),
                        child: Text(
                          '$m daq',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected ? colors.primary : colors.textMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12.h),

                  // Deep Work row.
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 6.h, 10.w, 6.h),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Qat\'iy rejim (Deep Work)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                'Boshqa ilovalarga o\'tishni to\'sish',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: state.isDeepWorkEnabled,
                          activeTrackColor: colors.primary,
                          onChanged: isRunning
                              ? null
                              : (v) => cubit.toggleDeepWork(v),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Controls.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.status != FocusStatus.idle) ...[
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(52.r, 52.r),
                          onPressed: cubit.reset,
                          child: Icon(
                            CupertinoIcons.arrow_counterclockwise,
                            size: 22.r,
                            color: colors.textMuted,
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      CustomButton(
                        title: isRunning ? 'Pauza' : 'Boshlash',
                        icon: Icon(
                          isRunning
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                        ),
                        borderRadius: 30.r,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40.w,
                          vertical: 15.h,
                        ),
                        backgroundColor: isRunning ? colors.card : null,
                        foregroundColor: isRunning ? colors.textPrimary : null,
                        onTap: isRunning ? cubit.pause : cubit.start,
                      ),
                      if (state.status != FocusStatus.idle)
                        SizedBox(width: 64.r),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDuration(BuildContext context, int currentSeconds) async {
    final colors = context.appColors;
    final cubit = context.read<FocusTimerCubit>();
    var picked = Duration(seconds: currentSeconds);

    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Bekor',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Tayyor',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: context.isDark
                        ? Brightness.dark
                        : Brightness.light,
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: picked,
                    onTimerDurationChanged: (d) => picked = d,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Minimum 1 minute; the timer works in whole minutes.
    if (confirmed == true && picked.inMinutes > 0) {
      cubit.setDurationMinutes(picked.inMinutes);
    }
  }
}
