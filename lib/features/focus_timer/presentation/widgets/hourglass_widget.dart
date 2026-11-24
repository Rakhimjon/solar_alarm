import 'package:flutter/material.dart';

class HourglassWidget extends StatelessWidget {
  final double progress; // 0.0 (full top) to 1.0 (full bottom)
  final bool isRunning;
  final double size;

  const HourglassWidget({
    super.key,
    required this.progress,
    required this.isRunning,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HourglassPainter(
          progress: progress,
          isRunning: isRunning,
        ),
      ),
    );
  }
}

class _HourglassPainter extends CustomPainter {
  final double progress;
  final bool isRunning;

  _HourglassPainter({
    required this.progress,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Glass stroke paint
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // Stand top & bottom lines
    canvas.drawLine(
      Offset(w * 0.18, h * 0.08),
      Offset(w * 0.82, h * 0.08),
      glassPaint,
    );
    canvas.drawLine(
      Offset(w * 0.18, h * 0.92),
      Offset(w * 0.82, h * 0.92),
      glassPaint,
    );

    // Hourglass outer curves
    final path = Path();
    path.moveTo(w * 0.22, h * 0.10);
    // Upper bulb to waist
    path.cubicTo(w * 0.24, cy * 0.7, cx - 12, cy - 8, cx - 8, cy);
    // Waist to lower bulb
    path.cubicTo(cx - 12, cy + 8, w * 0.24, h - cy * 0.7, w * 0.22, h * 0.90);
    path.lineTo(w * 0.78, h * 0.90);
    // Lower bulb right side to waist
    path.cubicTo(w * 0.76, h - cy * 0.7, cx + 12, cy + 8, cx + 8, cy);
    // Waist to upper bulb right side
    path.cubicTo(cx + 12, cy - 8, w * 0.76, cy * 0.7, w * 0.78, h * 0.10);
    path.close();

    canvas.drawPath(path, glassPaint);

    // Sand colors (Amber glow)
    final sandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.amber.shade300,
          Colors.amber.shade700,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    // Clip to hourglass inside
    canvas.save();
    canvas.clipPath(path);

    // Top bulb sand level (empties from 1.0 to 0.0)
    final topRemaining = (1.0 - progress);
    if (topRemaining > 0.01) {
      final topSandHeight = (cy - h * 0.12) * topRemaining;
      final topRect = Rect.fromLTRB(
        w * 0.15,
        cy - topSandHeight,
        w * 0.85,
        cy,
      );
      canvas.drawRect(topRect, sandPaint);
    }

    // Falling stream if running
    if (isRunning && progress > 0.0 && progress < 0.99) {
      final streamPaint = Paint()
        ..color = Colors.amber.shade400
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, cy), Offset(cx, h * 0.88), streamPaint);
    }

    // Bottom bulb sand level (fills up from 0.0 to 1.0)
    if (progress > 0.01) {
      final bottomSandHeight = (h * 0.88 - cy) * progress;
      final bottomRect = Rect.fromLTRB(
        w * 0.15,
        h * 0.90 - bottomSandHeight,
        w * 0.85,
        h * 0.90,
      );
      canvas.drawRect(bottomRect, sandPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HourglassPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRunning != isRunning;
  }
}
