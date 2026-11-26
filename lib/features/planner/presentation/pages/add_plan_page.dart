import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/core/widgets/custom_button.dart';
import 'package:solar_alarm/features/planner/presentation/cubit/planner_cubit.dart';

class AddPlanPage extends StatefulWidget {
  final List<String> categories;
  final String initialCategory;

  const AddPlanPage({
    super.key,
    required this.categories,
    required this.initialCategory,
  });

  @override
  State<AddPlanPage> createState() => _AddPlanPageState();
}

class _AddPlanPageState extends State<AddPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _presetMinutes = const [15, 25, 45, 60];

  late String _selectedCategory;
  int _targetMinutes = 25;
  bool _useTimer = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : widget.categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final task = await context.read<PlannerCubit>().createTask(
        _titleController.text,
        _targetMinutes,
        category: _selectedCategory,
        useTimer: _useTimer,
      );
      if (mounted && task != null) context.pop(task);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rejani saqlash imkoni bo\'lmadi')),
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
      appBar: AppBar(title: const Text('Yangi reja')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  maxLength: 100,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  style: TextStyle(color: colors.textPrimary, fontSize: 16.sp),
                  decoration: InputDecoration(
                    labelText: 'Reja nomi',
                    hintText: 'Masalan: 30 daqiqa kitob o\'qish',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Reja nomini kiriting'
                      : null,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Kategoriya',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.categories.map((category) {
                    final selected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: colors.primary,
                      backgroundColor: colors.card,
                      labelStyle: TextStyle(
                        color: selected ? colors.onPrimary : colors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      title: const Text('Fokus timeri'),
                      subtitle: Text(
                        _useTimer
                            ? 'Saqlagach timer shu rejaga ulanadi'
                            : 'Timersiz reja, belgilab bajariladi',
                      ),
                      value: _useTimer,
                      activeThumbColor: colors.primary,
                      activeTrackColor: colors.primary.withValues(alpha: 0.4),
                      onChanged: (value) => setState(() => _useTimer = value),
                    ),
                  ),
                ),
                if (_useTimer) ...[
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Fokus davomiyligi',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$_targetMinutes daqiqa',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _presetMinutes.map((minutes) {
                      final selected = minutes == _targetMinutes;
                      return ChoiceChip(
                        label: Text('$minutes daq'),
                        selected: selected,
                        selectedColor: colors.primary,
                        backgroundColor: colors.card,
                        labelStyle: TextStyle(
                          color: selected
                              ? colors.onPrimary
                              : colors.textPrimary,
                        ),
                        onSelected: (_) {
                          setState(() => _targetMinutes = minutes);
                        },
                      );
                    }).toList(),
                  ),
                  Slider(
                    value: _targetMinutes.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    activeColor: colors.primary,
                    inactiveColor: colors.cardBorder,
                    label: '$_targetMinutes daqiqa',
                    onChanged: (value) {
                      setState(() => _targetMinutes = value.toInt());
                    },
                  ),
                ],
                SizedBox(height: 24.h),
                CustomButton(
                  title: _useTimer
                      ? 'Saqlash va Fokusga o\'tish'
                      : 'Rejani saqlash',
                  icon: Icon(
                    _useTimer
                        ? Icons.hourglass_top_rounded
                        : Icons.playlist_add_check_rounded,
                  ),
                  isFullWidth: true,
                  isLoading: _isSaving,
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  onTap: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
