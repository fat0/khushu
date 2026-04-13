import 'package:flutter/material.dart';
import 'package:khushu/core/theme/app_colors.dart';

class CalibrationOverlay extends StatelessWidget {
  const CalibrationOverlay({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgOpacity = isDark ? 0.85 : 0.70;

    return Container(
      color: Colors.black.withValues(alpha: bgOpacity),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(160, 90),
                painter: _Figure8Painter(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Calibrate Compass',
                style: TextStyle(
                  color: AppColors.sage,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Move your phone in a figure-8 pattern\nto improve compass accuracy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.sage.withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sage.withValues(alpha: 0.7),
                  side: BorderSide(
                    color: AppColors.sage.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                child: const Text('Dismiss', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Figure8Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Map from 240x130 viewBox to actual size
    final sx = size.width / 240;
    final sy = size.height / 130;

    Offset s(double x, double y) => Offset(x * sx, y * sy);

    final paint = Paint()
      ..color = AppColors.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * sx
      ..strokeCap = StrokeCap.round;

    // Left loop
    final leftLoop = Path()
      ..moveTo(s(120, 65).dx, s(120, 65).dy)
      ..cubicTo(
        s(105, 40).dx, s(105, 40).dy,
        s(70, 20).dx, s(70, 20).dy,
        s(50, 35).dx, s(50, 35).dy,
      )
      ..cubicTo(
        s(25, 55).dx, s(25, 55).dy,
        s(25, 80).dx, s(25, 80).dy,
        s(50, 95).dx, s(50, 95).dy,
      )
      ..cubicTo(
        s(70, 108).dx, s(70, 108).dy,
        s(105, 90).dx, s(105, 90).dy,
        s(120, 65).dx, s(120, 65).dy,
      );
    canvas.drawPath(leftLoop, paint);

    // Right loop
    final rightLoop = Path()
      ..moveTo(s(120, 65).dx, s(120, 65).dy)
      ..cubicTo(
        s(135, 40).dx, s(135, 40).dy,
        s(170, 20).dx, s(170, 20).dy,
        s(190, 35).dx, s(190, 35).dy,
      )
      ..cubicTo(
        s(215, 55).dx, s(215, 55).dy,
        s(215, 80).dx, s(215, 80).dy,
        s(190, 95).dx, s(190, 95).dy,
      )
      ..cubicTo(
        s(170, 108).dx, s(170, 108).dy,
        s(135, 90).dx, s(135, 90).dy,
        s(120, 65).dx, s(120, 65).dy,
      );
    canvas.drawPath(rightLoop, paint);

    // Arrow on left loop (counterclockwise)
    final arrowPaint = Paint()
      ..color = AppColors.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * sx
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leftArrow = Path()
      ..moveTo(s(78, 26).dx, s(78, 26).dy)
      ..lineTo(s(68, 30).dx, s(68, 30).dy)
      ..lineTo(s(74, 38).dx, s(74, 38).dy);
    canvas.drawPath(leftArrow, arrowPaint);

    // Arrow on right loop (clockwise)
    final rightArrow = Path()
      ..moveTo(s(162, 26).dx, s(162, 26).dy)
      ..lineTo(s(172, 30).dx, s(172, 30).dy)
      ..lineTo(s(166, 38).dx, s(166, 38).dy);
    canvas.drawPath(rightArrow, arrowPaint);

    // Phone icon at right
    final phoneBg = Paint()
      ..color = const Color(0xFF1E1E1C)
      ..style = PaintingStyle.fill;
    final phoneStroke = Paint()
      ..color = AppColors.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * sx;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: s(192, 30), width: 18 * sx, height: 28 * sy),
      Radius.circular(3 * sx),
    );
    canvas.drawRRect(phoneRect, phoneBg);
    canvas.drawRRect(phoneRect, phoneStroke);

    // Phone screen
    final screenPaint = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: s(192, 28), width: 12 * sx, height: 18 * sy),
      Radius.circular(1 * sx),
    );
    canvas.drawRRect(screenRect, screenPaint);

    // Phone home bar
    final barPaint = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.4)
      ..strokeWidth = 1.5 * sx
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(s(189, 40), s(195, 40), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
