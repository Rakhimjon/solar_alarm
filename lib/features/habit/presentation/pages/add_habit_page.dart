import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';
import 'package:solar_alarm/features/habit/presentation/cubit/habit_cubit.dart';

const List<String> kHabitEmojis = [
  '💧', '📖', '🏃', '🧘', '💪', '🦷', '🌅', '🕌',
  '✍️', '🥗', '😴', '🚶', '🎯', '🧠', '🙏', '☀️',
];

const List<int> kHabitColorValues = [
  0xFFF59E0B, // amber
  0xFFEF4444, // red
  0xFF3B82F6, // blue
  0xFF22C55E, // green
  0xFFA855F7, // purple
  0xFFEC4899, // pink
  0xFF14B8A6, // teal
  0xFFF97316, // orange
];

class AddHabitPage extends StatefulWidget {
  final Habit? initialHabit;

  const AddHabitPage({super.key, this.initialHabit});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late String _emoji;
  late int _colorValue;
  late bool _everyDay;
  late List<int> _weekdays;
  bool _isSaving = false;

  bool get isEditing => widget.initialHabit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.initialHabit;
    _emoji = h?.emoji ?? kHabitEmojis.first;
    _colorValue = h?.colorValue ?? kHabitColorValues.first;
    _everyDay = h?.isEveryDay ?? true;
    _weekdays = h != null ? List.from(h.weekdays) : [];
    _nameController.text = h?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final cubit = context.read<HabitCubit>();
      if (isEditing) {
        await cubit.updateHabit(
          widget.initialHabit!.copyWith(
            name: _nameController.text.trim(),
            emoji: _emoji,
            colorValue: _colorValue,
            weekdays: _everyDay ? const [] : List.from(_weekdays),
          ),
        );
      } else {
        await cubit.createHabit(
          name: _nameController.text,
          emoji: _emoji,
          colorValue: _colorValue,
          weekdays: _everyDay ? const [] : List.from(_weekdays),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Odatni saqlash imkoni bo\'lmadi')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Odatni tahrirlash' : 'Yangi odat')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: !isEditing,
                  maxLength: 60,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  style: TextStyle(color: colors.textPrimary, fontSize: 16.sp),
                  decoration: InputDecoration(
                    labelText: 'Odat nomi',
                    hintText: 'Masalan: 2 stakan suv ichish',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Odat nomini kiriting'
                      : null,
                ),
                SizedBox(height: 16.h),
                _sectionTitle('Belgi (emoji)', colors),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: kHabitEmojis.map((emoji) {
                    final selected = emoji == _emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _emoji = emoji),
                      child: Container(
                        width: 46.r,
                        height: 46.r,
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary.withValues(alpha: 0.2)
                              : colors.card,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? colors.primary : colors.cardBorder,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
                _sectionTitle('Rang', colors),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: kHabitColorValues.map((value) {
                    final selected = value == _colorValue;
                    return GestureDetector(
                      onTap: () => setState(() => _colorValue = value),
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: Color(value),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? colors.textPrimary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
                _sectionTitle('Jadval', colors),
                SizedBox(height: 8.h),
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
                        child: _scheduleTab(
                          label: 'Har kuni',
                          selected: _everyDay,
                          onTap: () => setState(() => _everyDay = true),
                          colors: colors,
                        ),
                      ),
                      Expanded(
                        child: _scheduleTab(
                          label: 'Tanlangan kunlar',
                          selected: !_everyDay,
                          onTap: () => setState(() => _everyDay = false),
                          colors: colors,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_everyDay) ...[
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
                SizedBox(height: 24.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: Size.fromHeight(52.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : Text(
                          isEditing ? 'Saqlash' : 'Odatni qo\'shish',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, AppColors colors) {
    return Text(
      title,
      style: TextStyle(
        color: colors.textMuted,
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _scheduleTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 44.h),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: selected ? colors.onPrimary : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _weekdayCircle(String label, int day, AppColors colors) {
    final selected = _weekdays.contains(day);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _weekdays.remove(day);
          } else {
            _weekdays.add(day);
          }
        });
      },
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.card,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.primary : colors.cardBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? colors.onPrimary : colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
