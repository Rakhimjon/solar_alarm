import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/alarm_item.dart';
import '../cubit/alarm_cubit.dart';

class AddEditAlarmPage extends StatefulWidget {
  final AlarmItem? initialAlarm;

  const AddEditAlarmPage({super.key, this.initialAlarm});

  @override
  State<AddEditAlarmPage> createState() => _AddEditAlarmPageState();
}

class _AddEditAlarmPageState extends State<AddEditAlarmPage> {
  late int _modeIndex; // 0 = Aniq vaqt, 1 = Quyosh/Namoz vaqti
  late TimeOfDay _selectedTime;
  late String _selectedSolarEvent;
  late int _solarOffset;
  late TextEditingController _labelController;
  late AlarmSoundOption _selectedSound;
  late List<int> _repeatDays;
  late bool _vibrate;
  late bool _requireMath;

  bool get isEditing => widget.initialAlarm != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAlarm;
    if (a != null) {
      _modeIndex = a.hasSolarLink ? 1 : 0;
      _selectedTime = TimeOfDay(hour: a.hour, minute: a.minute);
      _selectedSolarEvent = a.linkedSolarType ?? 'fajr';
      _solarOffset = a.solarOffsetMinutes;
      _labelController = TextEditingController(text: a.label);
      _selectedSound = AlarmSoundOption.all.firstWhere(
        (s) => s.path == a.soundPath,
        orElse: () => AlarmSoundOption.all.first,
      );
      _repeatDays = List.from(a.repeatDays);
      _vibrate = a.vibrate;
      _requireMath = a.requireMathMission;
    } else {
      _modeIndex = 0;
      _selectedTime = TimeOfDay.now();
      _selectedSolarEvent = 'fajr';
      _solarOffset = -20;
      _labelController = TextEditingController(text: 'Ertalabki uyg\'onish');
      _selectedSound = AlarmSoundOption.all.first;
      _repeatDays = [];
      _vibrate = true;
      _requireMath = true;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save() {
    final cubit = context.read<AlarmCubit>();
    final label = _labelController.text.trim();

    cubit.saveAlarm(
      existingId: widget.initialAlarm?.id,
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      label: label.isEmpty ? 'Budilnik' : label,
      soundPath: _selectedSound.path,
      soundTitle: _selectedSound.title,
      repeatDays: _repeatDays,
      vibrate: _vibrate,
      requireMathMission: _requireMath,
      linkedSolarType: _modeIndex == 1 ? _selectedSolarEvent : null,
      solarOffsetMinutes: _modeIndex == 1 ? _solarOffset : 0,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: 24.r),
          tooltip: 'Chiqish',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Budilnikni Tahrirlash' : 'Yangi Budilnik',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: TextButton(
              onPressed: _save,
              child: Text(
                'Saqlash',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Mode Segmented Switch
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _segmentedTab(
                        label: '⏰ Aniq Vaqt',
                        isSelected: _modeIndex == 0,
                        onTap: () => setState(() => _modeIndex = 0),
                        colors: colors,
                      ),
                    ),
                    Expanded(
                      child: _segmentedTab(
                        label: '☀️ Quyosh / Namoz',
                        isSelected: _modeIndex == 1,
                        onTap: () => setState(() => _modeIndex = 1),
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // 2. Time or Solar Selection Card
              if (_modeIndex == 0) ...[
                _buildTimeCard(colors),
              ] else ...[
                _buildSolarCard(colors),
              ],

              SizedBox(height: 16.h),

              // 3. Settings Group Card
              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  children: [
                    // Label field
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: TextField(
                        controller: _labelController,
                        style: TextStyle(color: colors.textPrimary, fontSize: 14.sp),
                        decoration: InputDecoration(
                          labelText: 'Budilnik nomi',
                          labelStyle: TextStyle(color: colors.textMuted, fontSize: 13.sp),
                          prefixIcon: Icon(Icons.edit_note_rounded, color: colors.primary, size: 22.r),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),

                    Divider(height: 1, color: colors.cardBorder),

                    // Sound Selector
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.volume_up_rounded, color: colors.primary, size: 20.r),
                              SizedBox(width: 8.w),
                              Text(
                                'Ovoz (Baland signal)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: AlarmSoundOption.all.map((sound) {
                              final isSelected = _selectedSound.path == sound.path;
                              return ChoiceChip(
                                label: Text(sound.title, style: TextStyle(fontSize: 12.sp)),
                                selected: isSelected,
                                selectedColor: colors.primary,
                                backgroundColor: colors.background,
                                side: BorderSide(
                                  color: isSelected ? colors.primary : colors.cardBorder,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : colors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (_) => setState(() => _selectedSound = sound),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: colors.cardBorder),

                    // Repeat Days
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.repeat_rounded, color: colors.primary, size: 20.r),
                              SizedBox(width: 8.w),
                              Text(
                                'Takrorlanish kunlari',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _weekdayCircle('Du', 1, colors),
                              _weekdayCircle('Se', 2, colors),
                              _weekdayCircle('Chor', 3, colors),
                              _weekdayCircle('Pay', 4, colors),
                              _weekdayCircle('Jum', 5, colors),
                              _weekdayCircle('Shan', 6, colors),
                              _weekdayCircle('Yak', 7, colors),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: colors.cardBorder),

                    // Math Mission Switch
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.psychology_rounded, color: Colors.orangeAccent, size: 22.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aqliy missiya (Math Challenge)',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Signalni to\'xtatish uchun misol yechiladi',
                                  style: TextStyle(fontSize: 11.sp, color: colors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _requireMath,
                            activeTrackColor: Colors.orangeAccent.withValues(alpha: 0.5),
                            activeThumbColor: Colors.orangeAccent,
                            onChanged: (v) => setState(() => _requireMath = v),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: colors.cardBorder),

                    // Vibrate Switch
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.vibration_rounded, color: colors.primary, size: 22.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Tebranish (Vibratsiya)',
                              style: TextStyle(fontSize: 13.sp, color: colors.textPrimary),
                            ),
                          ),
                          Switch.adaptive(
                            value: _vibrate,
                            activeTrackColor: colors.primary.withValues(alpha: 0.5),
                            activeThumbColor: colors.primary,
                            onChanged: (v) => setState(() => _vibrate = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Save CTA Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(50.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                onPressed: _save,
                child: Text(
                  'Budilnikni Saqlash',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),

              // Delete button if editing
              if (isEditing) ...[
                SizedBox(height: 12.h),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    minimumSize: Size.fromHeight(48.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  icon: Icon(Icons.delete_outline_rounded, size: 20.r),
                  label: Text('Budilnikni O\'chirish', style: TextStyle(fontSize: 14.sp)),
                  onPressed: () {
                    context.read<AlarmCubit>().deleteAlarm(widget.initialAlarm!.id);
                    Navigator.pop(context);
                  },
                ),
              ],

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segmentedTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCard(AppColors colors) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (picked != null) {
          setState(() => _selectedTime = picked);
        }
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: colors.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Vaqtni o\'zgartirish uchun bosing',
              style: TextStyle(fontSize: 12.sp, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarCard(AppColors colors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qaysi vaqtga bog\'laysiz?',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _solarOption('fajr', 'Bomdod 🌅', colors),
              _solarOption('sunrise', 'Quyosh ☀️', colors),
              _solarOption('dhuhr', 'Peshin ☀️', colors),
              _solarOption('asr', 'Asr 🌤️', colors),
              _solarOption('maghrib', 'Shom 🌇', colors),
              _solarOption('isha', 'Xufton 🌙', colors),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Siljish (oldin / keyin):', style: TextStyle(fontSize: 12.sp, color: colors.textMuted)),
              Text(
                '${_solarOffset >= 0 ? "+$_solarOffset" : "$_solarOffset"} daqiqa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          Slider(
            value: _solarOffset.toDouble(),
            min: -60,
            max: 60,
            divisions: 24,
            activeColor: colors.primary,
            inactiveColor: colors.cardBorder,
            onChanged: (val) => setState(() => _solarOffset = val.toInt()),
          ),
          Center(
            child: Text(
              _solarOffset < 0
                  ? '${_solarNameUz(_selectedSolarEvent)}dan ${_solarOffset.abs()} daqiqa oldin chalinadi'
                  : (_solarOffset == 0
                      ? '${_solarNameUz(_selectedSolarEvent)} vaqtida chalinadi'
                      : '${_solarNameUz(_selectedSolarEvent)}dan $_solarOffset daqiqa keyin chalinadi'),
              style: TextStyle(fontSize: 12.sp, color: colors.primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _solarOption(String type, String title, AppColors colors) {
    final isSelected = _selectedSolarEvent == type;
    return ChoiceChip(
      label: Text(title, style: TextStyle(fontSize: 12.sp)),
      selected: isSelected,
      selectedColor: colors.primary,
      backgroundColor: colors.background,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedSolarEvent = type),
    );
  }

  Widget _weekdayCircle(String label, int day, AppColors colors) {
    final isSelected = _repeatDays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _repeatDays.remove(day);
          } else {
            _repeatDays.add(day);
          }
        });
      },
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.background,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? colors.primary : colors.cardBorder),
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

  String _solarNameUz(String type) {
    switch (type) {
      case 'fajr':
        return 'Bomdod';
      case 'sunrise':
        return 'Quyosh chiqishi';
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
