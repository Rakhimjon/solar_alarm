import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/path.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/alarm_item.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';

class AlarmView extends StatelessWidget {
  const AlarmView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<AlarmCubit, AlarmState>(
      listenWhen: (prev, curr) =>
          (curr.message != null && curr.message != prev.message) ||
          (curr.isRinging && !prev.isRinging),
      listener: (context, state) {
        if (state.isRinging) {
          context.push(RoutePath.ringing);
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
            title: const Text('Uyg\'otgich'),
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
          body: state.alarms.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⏰', style: TextStyle(fontSize: 44.sp)),
                        SizedBox(height: 12.h),
                        Text(
                          'Uyg\'otgich yo\'q',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Aniq vaqt yoki quyosh/namoz vaqtiga bog\'lang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        CustomButton(
                          title: 'Uyg\'otgich Qo\'shish',
                          icon: const Icon(Icons.add_rounded),
                          borderRadius: 28.r,
                          onTap: () => _openAddEdit(context),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 96.h),
                  itemCount: state.alarms.length,
                  separatorBuilder: (_, _) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) =>
                      _buildAlarmCard(context, state.alarms[index], cubit),
                ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: state.alarms.isEmpty
              ? null
              : CustomButton(
                  title: 'Yangi Uyg\'otgich',
                  icon: const Icon(Icons.alarm_add_rounded),
                  borderRadius: 28.r,
                  onTap: () => _openAddEdit(context),
                ),
        );
      },
    );
  }

  void _openAddEdit(BuildContext context, [AlarmItem? alarm]) {
    context.push(RoutePath.addEditAlarm, extra: alarm);
  }

  Widget _buildAlarmCard(
    BuildContext context,
    AlarmItem alarm,
    AlarmCubit cubit,
  ) {
    final colors = context.appColors;
    final on = alarm.isEnabled;
    final details = [
      if (alarm.hasSolarLink)
        '${_solarNameUz(alarm.linkedSolarType)} '
            '${alarm.solarOffsetMinutes >= 0 ? "+" : ""}${alarm.solarOffsetMinutes} daq',
      alarm.repeatDaysText,
      if (alarm.requireMathMission) '☀️',
    ].join(' · ');

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => _openAddEdit(context, alarm),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 10.w, 12.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.formattedTime,
                      style: TextStyle(
                        fontSize: 34.sp,
                        fontWeight: FontWeight.w300,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: on ? colors.textPrimary : colors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      alarm.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: on ? colors.textPrimary : colors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: on,
                activeTrackColor: colors.primary,
                onChanged: (_) => cubit.toggleAlarm(alarm.id),
              ),
            ],
          ),
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
