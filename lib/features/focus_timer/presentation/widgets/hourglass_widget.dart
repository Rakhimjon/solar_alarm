import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HourglassWidget extends StatefulWidget {
  final double progress; // 0.0 (full top) to 1.0 (full bottom)
  final bool isRunning;
  final double size;
  final Color? glassColor;

  const HourglassWidget({
    super.key,
    required this.progress,
    required this.isRunning,
    this.size = 200,
    this.glassColor,
  });

  @override
  State<HourglassWidget> createState() => _HourglassWidgetState();
}

class _HourglassWidgetState extends State<HourglassWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    if (widget.isRunning && widget.progress < 0.999) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HourglassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRun = widget.isRunning && widget.progress < 0.999;
    if (shouldRun && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!shouldRun && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlassColor = widget.glassColor ?? context.appColors.glassStroke;
    final isDark = context.isDark;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return CustomPaint(
            painter: _HourglassPainter(
              progress: widget.progress,
              isRunning: widget.isRunning,
              glassColor: effectiveGlassColor,
              animValue: _animController.value,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _HourglassPainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  final Color glassColor;
  final double animValue;
  final bool isDark;

  _HourglassPainter({
    required this.progress,
    required this.isRunning,
    required this.glassColor,
    required this.animValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // 1. Top and Bottom Caps (Wooden/Brass Stands)
    _drawCaps(canvas, w, h);

    // 2. Hourglass Glass Outer Path
    final glassPath = _createGlassPath(w, h, cx, cy);

    // 3. Draw sand inside glass (clipped)
    canvas.save();
    canvas.clipPath(glassPath);

    // Subtle background tint inside chamber
    final innerBgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.02)
          : Colors.black.withValues(alpha: 0.02);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), innerBgPaint);

    // Calculate bottom mound peak for stream collision
    final bottomMoundPeakY = _calculateBottomPeakY(h, cy, progress);

    // Draw Top Sand (Funneling down)
    _drawTopSand(canvas, w, h, cx, cy, progress);

    // Draw Bottom Sand (Conical mound)
    _drawBottomSand(canvas, w, h, cx, cy, progress, bottomMoundPeakY);

    // Draw Falling Sand Stream & Particle Physics
    if (isRunning && progress > 0.0 && progress < 0.995) {
      _drawFallingStream(canvas, cx, cy, bottomMoundPeakY);
    }

    canvas.restore();

    // 4. Glass Outline Stroke
    final glassOutlinePaint = Paint()
      ..color = glassColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(glassPath, glassOutlinePaint);

    // 5. Glass 3D Specular Reflection Highlights
    _drawGlassReflections(canvas, w, h, cx, cy);
  }

  Path _createGlassPath(double w, double h, double cx, double cy) {
    final path = Path();
    path.moveTo(w * 0.22, h * 0.10);

    // Upper bulb to waist
    path.cubicTo(w * 0.23, cy * 0.65, cx - 11, cy - 8, cx - 7, cy);
    // Waist to lower bulb
    path.cubicTo(cx - 11, cy + 8, w * 0.23, h - (cy * 0.65), w * 0.22, h * 0.90);
    path.lineTo(w * 0.78, h * 0.90);
    // Lower bulb right side to waist
    path.cubicTo(w * 0.77, h - (cy * 0.65), cx + 11, cy + 8, cx + 7, cy);
    // Waist to upper bulb right side
    path.cubicTo(cx + 11, cy - 8, w * 0.77, cy * 0.65, w * 0.78, h * 0.10);
    path.close();

    return path;
  }

  void _drawCaps(Canvas canvas, double w, double h) {
    final capColor = isDark ? const Color(0xFF263244) : const Color(0xFFCBD5E1);
    final capHighlight = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final capPaint = Paint()
      ..color = capColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = capHighlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Top Stand Plate
    final topRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.15, h * 0.065, w * 0.85, h * 0.10),
      const Radius.circular(5),
    );
    canvas.drawRRect(topRRect, capPaint);
    canvas.drawRRect(topRRect, highlightPaint);

    // Bottom Stand Plate
    final bottomRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.15, h * 0.90, w * 0.85, h * 0.935),
      const Radius.circular(5),
    );
    canvas.drawRRect(bottomRRect, capPaint);
    canvas.drawRRect(bottomRRect, highlightPaint);
  }

  void _drawTopSand(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double cy,
    double p,
  ) {
    final remaining = (1.0 - p).clamp(0.0, 1.0);
    if (remaining <= 0.005) return;

    // Top sand level drops down towards cy as remaining decreases
    final sandTopY = cy - (cy - h * 0.12) * remaining;

    // Vortex funnel depression depth when running
    final funnelDepth = isRunning && remaining > 0.05
        ? (14.0 * remaining).clamp(3.0, 12.0)
        : 4.0 * remaining;

    final sandGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.amber.shade200,
        Colors.amber.shade400,
        Colors.amber.shade600,
      ],
    ).createShader(Rect.fromLTRB(w * 0.15, sandTopY, w * 0.85, cy));

    final sandPaint = Paint()
      ..shader = sandGradient
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.10, cy);
    path.lineTo(w * 0.10, sandTopY);
    // Funnel meniscus curve dipping toward center
    path.quadraticBezierTo(cx, sandTopY + funnelDepth, w * 0.90, sandTopY);
    path.lineTo(w * 0.90, cy);
    path.close();

    canvas.drawPath(path, sandPaint);

    // Subtle dark gradient line inside funnel to show depth
    final rimPaint = Paint()
      ..color = Colors.amber.shade800.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rimPath = Path();
    rimPath.moveTo(w * 0.15, sandTopY);
    rimPath.quadraticBezierTo(cx, sandTopY + funnelDepth, w * 0.85, sandTopY);
    canvas.drawPath(rimPath, rimPaint);
  }

  double _calculateBottomPeakY(double h, double cy, double p) {
    final bottomProg = p.clamp(0.0, 1.0);
    if (bottomProg <= 0.002) return h * 0.895;

    final baseY = h * 0.895 - (h * 0.895 - (cy + 14)) * bottomProg;
    // Dune peak forms higher in the center
    final moundRise = (isRunning ? 16.0 : 8.0) * (1.0 - bottomProg * 0.4);
    return (baseY - moundRise).clamp(cy + 12, h * 0.895);
  }

  void _drawBottomSand(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double cy,
    double p,
    double peakY,
  ) {
    final bottomProg = p.clamp(0.0, 1.0);
    if (bottomProg <= 0.002) return;

    final baseY = h * 0.895 - (h * 0.895 - (cy + 14)) * bottomProg;

    final sandGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.amber.shade300,
        Colors.amber.shade500,
        Colors.amber.shade700,
      ],
    ).createShader(Rect.fromLTRB(w * 0.15, peakY, w * 0.85, h * 0.90));

    final sandPaint = Paint()
      ..shader = sandGradient
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.10, h * 0.92);
    path.lineTo(w * 0.10, baseY);

    // Left slope up to dune peak
    path.cubicTo(
      cx - 18,
      baseY - 2,
      cx - 8,
      peakY,
      cx,
      peakY,
    );
    // Right slope down from dune peak
    path.cubicTo(
      cx + 8,
      peakY,
      cx + 18,
      baseY - 2,
      w * 0.90,
      baseY,
    );

    path.lineTo(w * 0.90, h * 0.92);
    path.close();

    canvas.drawPath(path, sandPaint);

    // Subtle highlight on the mound peak ridge
    final ridgePaint = Paint()
      ..color = Colors.amber.shade200.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final ridgePath = Path();
    ridgePath.moveTo(cx - 12, peakY + 3);
    ridgePath.quadraticBezierTo(cx, peakY, cx + 12, peakY + 3);
    canvas.drawPath(ridgePath, ridgePaint);
  }

  void _drawFallingStream(
    Canvas canvas,
    double cx,
    double cy,
    double bottomPeakY,
  ) {
    final streamLength = (bottomPeakY - cy).clamp(0.0, 200.0);
    if (streamLength < 2) return;

    // 1. Core continuous flowing stream line
    final streamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.amber.shade200,
          Colors.amber.shade400,
          Colors.amber.shade600,
        ],
      ).createShader(Rect.fromLTWH(cx - 3, cy, 6, streamLength))
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx, cy), Offset(cx, bottomPeakY), streamPaint);

    // 2. Animated grains accelerating under gravity along the stream
    final grainPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 16; i++) {
      // Deterministic staggered seed
      final seed = (i * 0.0625);
      final t = (animValue + seed) % 1.0;

      // Accelerated curve under gravity
      final curveT = math.pow(t, 1.4).toDouble();
      final py = cy + streamLength * curveT;

      // Organic micro horizontal jitter
      final px = cx + math.sin(i * 4.3 + animValue * 22) * 1.3;

      // Radius & color variety
      final isAccent = (i % 3 == 0);
      grainPaint.color = isAccent ? Colors.amber.shade100 : Colors.amber.shade400;
      final radius = isAccent ? 1.5 : 1.1;

      canvas.drawCircle(Offset(px, py), radius, grainPaint);
    }

    // 3. Landing splash & bouncing grains at impact peak
    final splashPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final splashT = (animValue * 1.8 + i * 0.125) % 1.0;
      final dir = (i.isEven ? 1.0 : -1.0);
      final angle = (0.25 + (i % 4) * 0.22);
      final dist = splashT * 12.0;

      final sx = cx + dir * math.cos(angle) * dist;
      // Arc trajectory: rise then fall onto sand
      final sy = bottomPeakY - math.sin(angle) * dist * 0.6 + (splashT * splashT * 4.5);
      final alpha = ((1.0 - splashT) * 0.85).clamp(0.0, 1.0);

      splashPaint.color = Colors.amber.shade200.withValues(alpha: alpha);
      canvas.drawCircle(Offset(sx, sy), 1.2, splashPaint);
    }
  }

  void _drawGlassReflections(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double cy,
  ) {
    final reflectPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.22 : 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Specular curved streak on upper-left bulb
    final upperPath = Path();
    upperPath.moveTo(w * 0.26, h * 0.14);
    upperPath.cubicTo(w * 0.26, cy * 0.60, cx - 14, cy - 14, cx - 12, cy - 10);
    canvas.drawPath(upperPath, reflectPaint);

    // Specular curved streak on lower-left bulb
    final lowerPath = Path();
    lowerPath.moveTo(cx - 12, cy + 10);
    lowerPath.cubicTo(cx - 14, cy + 14, w * 0.26, h - (cy * 0.60), w * 0.26, h * 0.86);
    canvas.drawPath(lowerPath, reflectPaint);
  }

  @override
  bool shouldRepaint(covariant _HourglassPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.glassColor != glassColor ||
        oldDelegate.animValue != animValue ||
        oldDelegate.isDark != isDark;
  }
}
