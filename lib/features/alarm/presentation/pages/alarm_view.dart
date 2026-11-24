import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/alarm_item.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';
import 'add_edit_alarm_page.dart';

class AlarmView extends StatelessWidget {
  final Function(int)? onSwitchTab;

  const AlarmView({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<AlarmCubit, AlarmState>(
      listenWhen: (prev, curr) =>
          (curr.message != null && curr.message != prev.message) ||
          (curr.isRinging && !prev.isRinging),
      listener: (context, state) {
        if (state.isRinging) {
          _showRingingDialog(context, state);
        } else if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: colors.card,
              content: Text(
                state.message!,
                style: TextStyle(color: colors.primary, fontSize: 13.sp),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AlarmCubit>();

        return Scaffold(
          appBar: AppBar(
            title: Text('Budilnik', style: TextStyle(fontSize: 18.sp)),
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
              IconButton(
                icon: Icon(Icons.add_rounded, size: 24.r, color: colors.primary),
                tooltip: 'Yangi budilnik',
                onPressed: () => _openAddEdit(context),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: state.alarms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_alarms_rounded, size: 54.r, color: colors.textMuted),
                        SizedBox(height: 12.h),
                        Text(
                          'Hozircha budilniklar o\'rnatilmagan',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Quyosh/Namoz vaqtiga bog\'langan yoki baland ovozli yangi budilnik qo\'shing',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textMuted, fontSize: 13.sp),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: () => _openAddEdit(context),
                          icon: Icon(Icons.add_alarm_rounded, size: 20.r),
                          label: Text('Budilnik Qo\'shish', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: state.alarms.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final alarm = state.alarms[index];
                      return _buildAlarmCard(context, alarm, cubit);
                    },
                  ),
          ),
          floatingActionButton: state.alarms.isEmpty
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  onPressed: () => _openAddEdit(context),
                  icon: Icon(Icons.alarm_add_rounded, size: 20.r),
                  label: Text('Yangi Budilnik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
        );
      },
    );
  }

  void _openAddEdit(BuildContext context, [AlarmItem? alarm]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditAlarmPage(initialAlarm: alarm),
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, AlarmItem alarm, AlarmCubit cubit) {
    final colors = context.appColors;

    return InkWell(
      onTap: () => _openAddEdit(context, alarm),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: alarm.isEnabled ? colors.primary.withValues(alpha: 0.4) : colors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        alarm.formattedTime,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: alarm.isEnabled ? colors.textPrimary : colors.textMuted,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: context.isDark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            alarm.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children: [
                      if (alarm.hasSolarLink)
                        _miniBadge(
                          '📍 ${_solarNameUz(alarm.linkedSolarType)} (${alarm.solarOffsetMinutes >= 0 ? "+" : ""}${alarm.solarOffsetMinutes} daq)',
                          colors.primary,
                          colors,
                        ),
                      if (alarm.requireMathMission)
                        _miniBadge('🧠 Aqliy missiya', Colors.orangeAccent, colors),
                      _miniBadge(alarm.soundTitle, colors.textMuted, colors),
                      _miniBadge(alarm.repeatDaysText, colors.textMuted, colors),
                    ],
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: alarm.isEnabled,
              activeTrackColor: colors.primary.withValues(alpha: 0.5),
              activeThumbColor: colors.primary,
              onChanged: (_) => cubit.toggleAlarm(alarm.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBadge(String text, Color textColor, AppColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colors.cardBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10.sp, color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  String _solarNameUz(String? type) {
    switch (type) {
      case 'fajr':
        return 'Bomdod';
      case 'sunrise':
        return 'Quyosh';
      case 'dhuhr':
        return 'Peshin';
      case 'asr':
        return 'Asr';
      case 'maghrib':
        return 'Shom';
      case 'isha':
        return 'Xufton';
      default:
        return 'Quyosh';
    }
  }

  void _showRingingDialog(BuildContext context, AlarmState state) {
    final mathController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm_on_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 8.w),
                    Text(
                      'Budilnik Jiringlamoqda!',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.ringingAlarmLabel ?? 'Vaqt bo\'ldi!',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 14.h),

                    // If Math Mission is required
                    if (state.ringingRequireMath) ...[
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🧠 Uyqudan uyg\'onish missiyasi:',
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${state.mathOperand1} + ${state.mathOperand2} = ?',
                              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                            ),
                            SizedBox(height: 10.h),
                            TextField(
                              controller: mathController,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: 'Javobni yozing',
                                errorText: errorMessage,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // Wake-up to Deep Work CTA Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: TextButton.icon(
                        icon: const Icon(Icons.hourglass_top_rounded, color: Colors.white),
                        label: Text(
                          '🚀 25 d Fokusni boshlash',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp),
                        ),
                        onPressed: () {
                          context.read<AlarmCubit>().dismissRinging();
                          Navigator.pop(dialogContext);
                          onSwitchTab?.call(1); // Jump straight to Qumsoat focus!
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<AlarmCubit>().snoozeRinging(minutes: 5);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('5 daqiqa kuting (Snooze)'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    if (state.ringingRequireMath) {
                      final input = int.tryParse(mathController.text.trim());
                      final solved = context.read<AlarmCubit>().verifyMathAndDismiss(input ?? -1);
                      if (solved) {
                        Navigator.pop(dialogContext);
                      } else {
                        setDialogState(() {
                          errorMessage = 'Noto\'g\'ri! Yana hisoblang';
                        });
                      }
                    } else {
                      context.read<AlarmCubit>().dismissRinging();
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('To\'xtatish', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
