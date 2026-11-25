import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/alarm_item.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';
import 'add_edit_alarm_page.dart';
import 'ringing_page.dart';

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
          Navigator.of(context, rootNavigator: true).push(
            PageRouteBuilder(
              opaque: true,
              pageBuilder: (_, _, _) => RingingPage(onSwitchTab: onSwitchTab),
              transitionsBuilder: (_, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
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
            title: Text('Uyg\'otgich', style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton(
                icon: Icon(
                  context.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: colors.primary,
                  size: 22.r,
                ),
                tooltip: context.isDark ? 'Yorug\' rejim' : 'Qorong\'u rejim',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_rounded,
                  size: 24.r,
                  color: colors.primary,
                ),
                tooltip: 'Yangi uyg\'otgich',
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
                        Icon(
                          Icons.access_alarms_rounded,
                          size: 54.r,
                          color: colors.textMuted,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Hozircha uyg\'otgichlar o\'rnatilmagan',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Quyosh/Namoz vaqtiga bog\'langan yoki yangi uyg\'otgich qo\'shing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          onPressed: () => _openAddEdit(context),
                          icon: Icon(Icons.add_alarm_rounded, size: 20.r),
                          label: Text(
                            'Uyg\'otgich Qo\'shish',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                  foregroundColor: colors.onPrimary,
                  onPressed: () => _openAddEdit(context),
                  icon: Icon(Icons.alarm_add_rounded, size: 20.r),
                  label: Text(
                    'Yangi Uyg\'otgich',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _openAddEdit(BuildContext context, [AlarmItem? alarm]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditAlarmPage(initialAlarm: alarm)),
    );
  }

  Widget _buildAlarmCard(
    BuildContext context,
    AlarmItem alarm,
    AlarmCubit cubit,
  ) {
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
            color: alarm.isEnabled
                ? colors.primary.withValues(alpha: 0.4)
                : colors.cardBorder,
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
                          color: alarm.isEnabled
                              ? colors.textPrimary
                              : colors.textMuted,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(
                              alpha: context.isDark ? 0.15 : 0.08,
                            ),
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
                          '📍 ${_solarNameUz(alarm.linkedSolarType)} '
                          '(${alarm.solarOffsetMinutes >= 0 ? "+" : ""}${alarm.solarOffsetMinutes} daq)',
                          colors.primary,
                          colors,
                        ),
                      if (alarm.requireMathMission)
                        _miniBadge('☀️ Quyosh nurlari', Colors.amber, colors),
                      _miniBadge(alarm.soundTitle, colors.textMuted, colors),
                      _miniBadge(
                        alarm.repeatDaysText,
                        colors.textMuted,
                        colors,
                      ),
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
        style: TextStyle(
          fontSize: 10.sp,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
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
}
