import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/alarm_permissions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../solar_clock/presentation/cubit/solar_clock_cubit.dart';
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
  bool _isSaving = false;

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

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final permissionsGranted = await AlarmPermissions.ensure();
      if (!mounted) return;
      if (!permissionsGranted) {
        _showError('Bildirishnoma va aniq uyg\'otgich ruxsatlarini bering');
        return;
      }

      final solarState = context.read<SolarClockCubit>().state;
      final label = _labelController.text.trim();
      await context.read<AlarmCubit>().saveAlarm(
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
        lat: solarState.lat,
        lng: solarState.lng,
        region: solarState.region,
      );

      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        _showError('Uyg\'otgichni saqlash imkoni bo\'lmadi');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    try {
      await context.read<AlarmCubit>().deleteAlarm(widget.initialAlarm!.id);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) _showError('Uyg\'otgichni o\'chirish imkoni bo\'lmadi');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Tahrirlash' : 'Yangi Uyg\'otgich'),
        actions: [
          CupertinoButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const CupertinoActivityIndicator()
                : Text(
                    'Saqlash',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _modeIndex,
              backgroundColor: colors.card,
              thumbColor: context.isDark ? colors.cardBorder : Colors.white,
              children: {
                0: _segment('⏰ Aniq Vaqt', colors),
                1: _segment('☀️ Quyosh / Namoz', colors),
              },
              onValueChanged: (v) {
                if (v != null) setState(() => _modeIndex = v);
              },
            ),
            SizedBox(height: 12.h),
            _modeIndex == 0 ? _buildTimePicker(colors) : _buildSolar(colors),
            SizedBox(height: 12.h),
            _group(colors, [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _labelController,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.sp),
                  decoration: InputDecoration(
                    hintText: 'Nomi',
                    hintStyle: TextStyle(color: colors.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    7,
                    (i) => _weekdayCircle(_dayLetters[i], i + 1, colors),
                  ),
                ),
              ),
            ]),
            SizedBox(height: 12.h),
            _group(colors, [
              _row(
                colors,
                title: 'Ovoz',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedSound.title,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16.r,
                      color: colors.textMuted,
                    ),
                  ],
                ),
                onTap: () => _pickSound(colors),
              ),
              _row(
                colors,
                title: 'Quyosh nurlari missiyasi',
                subtitle: 'O\'chirish uchun quyoshga 5 marta teging',
                trailing: CupertinoSwitch(
                  value: _requireMath,
                  activeTrackColor: colors.primary,
                  onChanged: (v) => setState(() => _requireMath = v),
                ),
              ),
              _row(
                colors,
                title: 'Tebranish',
                trailing: CupertinoSwitch(
                  value: _vibrate,
                  activeTrackColor: colors.primary,
                  onChanged: (v) => setState(() => _vibrate = v),
                ),
              ),
            ]),
            if (isEditing) ...[
              SizedBox(height: 24.h),
              CupertinoButton(
                onPressed: _delete,
                child: Text(
                  'Uyg\'otgichni o\'chirish',
                  style: TextStyle(color: Colors.redAccent, fontSize: 15.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _dayLetters = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

  Widget _segment(String label, AppColors colors) => Padding(
    padding: EdgeInsets.symmetric(vertical: 9.h),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
    ),
  );

  Widget _group(AppColors colors, List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              indent: 16.w,
              color: colors.cardBorder.withValues(alpha: 0.6),
            ),
          children[i],
        ],
      ],
    ),
  );

  Widget _row(
    AppColors colors, {
    required String title,
    String? subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 10.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Future<void> _pickSound(AppColors colors) async {
    final sound = await showCupertinoModalPopup<AlarmSoundOption>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Ovoz'),
        actions: AlarmSoundOption.all
            .map(
              (o) => CupertinoActionSheetAction(
                isDefaultAction: o.path == _selectedSound.path,
                onPressed: () => Navigator.pop(ctx, o),
                child: Text(o.title),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Bekor'),
        ),
      ),
    );
    if (sound != null) setState(() => _selectedSound = sound);
  }

  Widget _buildTimePicker(AppColors colors) {
    final now = DateTime.now();
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: context.isDark ? Brightness.dark : Brightness.light,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w300,
              color: colors.textPrimary,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          itemExtent: 44.h,
          initialDateTime: DateTime(
            now.year,
            now.month,
            now.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
          onDateTimeChanged: (d) =>
              setState(() => _selectedTime = TimeOfDay.fromDateTime(d)),
        ),
      ),
    );
  }

  Widget _buildSolar(AppColors colors) {
    final name = _solarNameUz(_selectedSolarEvent);
    final when = _solarOffset < 0
        ? '${name}dan ${_solarOffset.abs()} daqiqa oldin'
        : _solarOffset == 0
        ? '$name vaqtida'
        : '${name}dan $_solarOffset daqiqa keyin';

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: [
              _solarOption('fajr', 'Bomdod 🌅', colors),
              _solarOption('sunrise', 'Quyosh ☀️', colors),
              _solarOption('dhuhr', 'Peshin ☀️', colors),
              _solarOption('asr', 'Asr 🌤️', colors),
              _solarOption('maghrib', 'Shom 🌇', colors),
              _solarOption('isha', 'Xufton 🌙', colors),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            when,
            style: TextStyle(fontSize: 14.sp, color: colors.textPrimary),
          ),
          Slider(
            value: _solarOffset.toDouble(),
            min: -60,
            max: 60,
            divisions: 24,
            activeColor: colors.primary,
            inactiveColor: colors.cardBorder,
            label: '${_solarOffset >= 0 ? "+" : ""}$_solarOffset daq',
            onChanged: (val) => setState(() => _solarOffset = val.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _solarOption(String type, String title, AppColors colors) {
    final isSelected = _selectedSolarEvent == type;
    return CupertinoButton(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      minimumSize: Size(0, 36.h),
      borderRadius: BorderRadius.circular(18.r),
      color: isSelected ? colors.primary.withValues(alpha: 0.15) : null,
      onPressed: () => setState(() => _selectedSolarEvent = type),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? colors.primary : colors.textPrimary,
        ),
      ),
    );
  }

  Widget _weekdayCircle(String label, int day, AppColors colors) {
    final isSelected = _repeatDays.contains(day);
    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: () => setState(() {
          isSelected ? _repeatDays.remove(day) : _repeatDays.add(day);
        }),
        child: Container(
          width: 38.r,
          height: 38.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? colors.primary : Colors.transparent,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? colors.onPrimary : colors.textMuted,
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
