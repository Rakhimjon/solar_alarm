import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_alarm/core/theme/app_theme.dart';
import 'package:solar_alarm/features/habit/domain/entities/habit.dart';

/// GitHub-style contribution grid (HabitKit pattern): columns = weeks,
/// rows = Monday..Sunday, the last column is the current week.
/// With [weeks] null the grid fits as many weeks as the width allows.
class HabitGrid extends StatelessWidget {
  final Habit habit;
  final int? weeks;
  final double? cellSize;

  const HabitGrid({super.key, required this.habit, this.weeks, this.cellSize});

  @override
  Widget build(BuildContext context) {
    final cell = cellSize ?? 11.r;
    final gap = cell * 0.27;

    return LayoutBuilder(
      builder: (context, constraints) {
        final count =
            weeks ??
            ((constraints.maxWidth + gap) / (cell + gap)).floor().clamp(1, 53);
        return CustomPaint(
          size: Size(count * (cell + gap) - gap, 7 * (cell + gap) - gap),
          painter: _GridPainter(
            habit: habit,
            weeks: count,
            cell: cell,
            gap: gap,
            color: Color(habit.colorValue),
            empty: context.appColors.cardBorder,
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final Habit habit;
  final int weeks;
  final double cell;
  final double gap;
  final Color color;
  final Color empty;

  _GridPainter({
    required this.habit,
    required this.weeks,
    required this.cell,
    required this.gap,
    required this.color,
    required this.empty,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final created = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );
    final firstMonday = today
        .subtract(Duration(days: today.weekday - 1))
        .subtract(Duration(days: (weeks - 1) * 7));
    final radius = Radius.circular(cell * 0.28);
    final paint = Paint();

    for (var w = 0; w < weeks; w++) {
      for (var d = 0; d < 7; d++) {
        final day = DateTime(
          firstMonday.year,
          firstMonday.month,
          firstMonday.day + w * 7 + d,
        );
        if (day.isAfter(today)) continue;

        if (habit.isDoneOn(day)) {
          paint.color = color;
        } else if (habit.isScheduledOn(day) && !day.isBefore(created)) {
          paint.color = color.withValues(alpha: 0.16);
        } else {
          paint.color = empty.withValues(alpha: 0.35);
        }

        final rect = Rect.fromLTWH(
          w * (cell + gap),
          d * (cell + gap),
          cell,
          cell,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
        if (day == today && !habit.isDoneOn(day)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.deflate(0.75), radius),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = color,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.habit != habit ||
      old.weeks != weeks ||
      old.color != color ||
      old.empty != empty ||
      old.cell != cell;
}
