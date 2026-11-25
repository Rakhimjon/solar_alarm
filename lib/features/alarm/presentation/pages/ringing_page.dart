import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';

class RingingPage extends StatefulWidget {
  final Function(int)? onSwitchTab;

  const RingingPage({super.key, this.onSwitchTab});

  @override
  State<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends State<RingingPage> with SingleTickerProviderStateMixin {
  late Timer _clockTimer;
  late DateTime _now;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlarmCubit, AlarmState>(
      listenWhen: (prev, curr) => prev.isRinging && !curr.isRinging,
      listener: (context, _) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      },
      child: BlocBuilder<AlarmCubit, AlarmState>(
        builder: (context, state) {
          final remaining = state.remainingSunTaps;
          final hasMission = state.ringingRequireMath && remaining > 0;

          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Column(
                  children: [
                    // ── Clock + Label ──────────────────────────────
                    Expanded(
                      flex: 3,
                      child: _ClockSection(now: _now, label: state.ringingAlarmLabel),
                    ),

                    // ── Affirmation + Mission ──────────────────────
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AffirmationCard(text: state.morningAffirmation),
                            SizedBox(height: 24.h),
                            if (hasMission)
                              _SunMission(
                                remaining: remaining,
                                pulseAnimation: _pulseAnimation,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context.read<AlarmCubit>().tapSunRay();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── Bottom Actions ─────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 28.h),
                      child: _BottomActions(
                        hasMission: hasMission,
                        onFocus: () {
                          context.read<AlarmCubit>().dismissRinging();
                          widget.onSwitchTab?.call(1);
                        },
                        onSnooze: () => context.read<AlarmCubit>().snoozeRinging(minutes: 5),
                        onDismiss: () => context.read<AlarmCubit>().dismissRinging(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ClockSection extends StatelessWidget {
  final DateTime now;
  final String? label;

  const _ClockSection({required this.now, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          DateFormat('HH:mm').format(now),
          style: TextStyle(
            fontSize: 76.sp,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: -2,
          ),
        ),
        Text(
          DateFormat('EEEE, d MMMM').format(now),
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.white38,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.alarm_fill, color: Colors.amber, size: 15.r),
              SizedBox(width: 6.w),
              Text(
                label ?? "Uyg'otgich",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AffirmationCard extends StatelessWidget {
  final String text;

  const _AffirmationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Text(
        '✨ $text',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          fontStyle: FontStyle.italic,
          color: Colors.white60,
          height: 1.5,
        ),
      ),
    );
  }
}

class _SunMission extends StatelessWidget {
  final int remaining;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const _SunMission({
    required this.remaining,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '☀️ Quyosh Nurlari Missiyasi',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Uyg'onish uchun quyoshga $remaining marta teging",
          style: TextStyle(fontSize: 12.sp, color: Colors.white38),
        ),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: onTap,
          child: ScaleTransition(
            scale: pulseAnimation,
            child: Container(
              width: 108.r,
              height: 108.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.55),
                    blurRadius: 32,
                    spreadRadius: 6,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 42.r),
                  Text(
                    '$remaining',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        // Progress dots — amber = already tapped
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final tapped = i >= remaining;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: tapped ? 12.r : 8.r,
              height: tapped ? 12.r : 8.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tapped ? Colors.amber : Colors.white20,
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool hasMission;
  final VoidCallback onFocus;
  final VoidCallback onSnooze;
  final VoidCallback onDismiss;

  const _BottomActions({
    required this.hasMission,
    required this.onFocus,
    required this.onSnooze,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!hasMission) ...[
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: Colors.amber.shade700,
              borderRadius: BorderRadius.circular(14.r),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              onPressed: onFocus,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.hourglass, color: Colors.white, size: 18.r),
                  SizedBox(width: 8.w),
                  Text(
                    '🚀 25 daq Fokus bilan boshlash',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
        Row(
          children: [
            Expanded(
              child: CupertinoButton(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(14.r),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                onPressed: onSnooze,
                child: Text(
                  '💤 5 daq kuting',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (!hasMission) ...[
              SizedBox(width: 10.w),
              Expanded(
                child: CupertinoButton(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14.r),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  onPressed: onDismiss,
                  child: Text(
                    "To'xtatish",
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
