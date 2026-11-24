import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
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
                          'Baland ovozli yangi budilnik qo\'shing',
                          style: TextStyle(color: colors.textMuted, fontSize: 13.sp),
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            onPressed: () => _showAddAlarmSheet(context, cubit),
            icon: Icon(Icons.alarm_add_rounded, size: 20.r),
            label: Text('Yangi Budilnik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
          ),
        );
      },
    );
  }

  Widget _buildAlarmCard(BuildContext context, AlarmItem alarm, AlarmCubit cubit) {
    final colors = context.appColors;

    return Container(
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
                    SizedBox(width: 10.w),
                    Container(
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
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.volume_up_rounded, size: 14.r, color: colors.textMuted),
                    SizedBox(width: 4.w),
                    Text(
                      alarm.soundTitle,
                      style: TextStyle(fontSize: 12.sp, color: colors.textMuted),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.repeat_rounded, size: 14.r, color: colors.textMuted),
                    SizedBox(width: 4.w),
                    Text(
                      alarm.repeatDaysText,
                      style: TextStyle(fontSize: 12.sp, color: colors.textMuted),
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
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20.r),
            onPressed: () => cubit.deleteAlarm(alarm.id),
          ),
        ],
      ),
    );
  }

  void _showAddAlarmSheet(BuildContext context, AlarmCubit cubit) {
    TimeOfDay selectedTime = TimeOfDay.now();
    String label = 'Ertalabki uyg\'onish';
    AlarmSoundOption selectedSound = AlarmSoundOption.all.first;
    List<int> repeatDays = [];
    bool vibrate = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sheetColors = context.appColors;

            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Yangi Baland Budilnik',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: sheetColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Time Picker Button
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setModalState(() => selectedTime = picked);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: sheetColors.primary.withValues(alpha: context.isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: sheetColors.primary),
                        ),
                        child: Center(
                          child: Text(
                            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: sheetColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Label Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Budilnik nomi',
                        labelStyle: TextStyle(color: sheetColors.textMuted, fontSize: 13.sp),
                        hintText: 'masalan: Bomdodga uyg\'onish',
                        hintStyle: TextStyle(color: sheetColors.textMuted, fontSize: 13.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: sheetColors.cardBorder),
                        ),
                      ),
                      style: TextStyle(color: sheetColors.textPrimary),
                      onChanged: (val) => label = val,
                    ),
                    SizedBox(height: 14.h),

                    // Loud Sound Selector
                    Text(
                      '🔊 Ovoz (Baland signal):',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: sheetColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: AlarmSoundOption.all.map((sound) {
                        final isSelected = selectedSound.path == sound.path;
                        return ChoiceChip(
                          label: Text(sound.title, style: TextStyle(fontSize: 12.sp)),
                          selected: isSelected,
                          selectedColor: sheetColors.primary,
                          backgroundColor: sheetColors.card,
                          side: BorderSide(
                            color: isSelected ? sheetColors.primary : sheetColors.cardBorder,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : sheetColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => setModalState(() => selectedSound = sound),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 14.h),

                    // Repeat Days
                    Text(
                      '📅 Takrorlanish kunlari:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: sheetColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _weekdayChip('Du', 1, repeatDays, setModalState, sheetColors),
                        _weekdayChip('Se', 2, repeatDays, setModalState, sheetColors),
                        _weekdayChip('Chor', 3, repeatDays, setModalState, sheetColors),
                        _weekdayChip('Pay', 4, repeatDays, setModalState, sheetColors),
                        _weekdayChip('Jum', 5, repeatDays, setModalState, sheetColors),
                        _weekdayChip('Shan', 6, repeatDays, setModalState, sheetColors),
                        _weekdayChip('Yak', 7, repeatDays, setModalState, sheetColors),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Vibrate Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tebranish (Vibratsiya)',
                          style: TextStyle(fontSize: 13.sp, color: sheetColors.textPrimary),
                        ),
                        Switch.adaptive(
                          value: vibrate,
                          activeTrackColor: sheetColors.primary.withValues(alpha: 0.5),
                          activeThumbColor: sheetColors.primary,
                          onChanged: (v) => setModalState(() => vibrate = v),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sheetColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(48.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: () {
                        cubit.saveAlarm(
                          hour: selectedTime.hour,
                          minute: selectedTime.minute,
                          label: label.trim(),
                          soundPath: selectedSound.path,
                          soundTitle: selectedSound.title,
                          repeatDays: repeatDays,
                          vibrate: vibrate,
                        );
                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        'Saqlash va Yoqish',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _weekdayChip(
    String label,
    int day,
    List<int> repeatDays,
    StateSetter setModalState,
    AppColors colors,
  ) {
    final isSelected = repeatDays.contains(day);
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            repeatDays.remove(day);
          } else {
            repeatDays.add(day);
          }
        });
      },
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colors.primary : colors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _showRingingDialog(BuildContext context, AlarmState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Center(
            child: Text(
              '⏰ Budilnik Jiringlamoqda!',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.ringingAlarmLabel ?? 'Vaqt bo\'ldi!',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              const Icon(Icons.alarm_on_rounded, size: 64, color: Colors.amber),
            ],
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
                context.read<AlarmCubit>().dismissRinging();
                Navigator.pop(dialogContext);
              },
              child: const Text('To\'xtatish', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
