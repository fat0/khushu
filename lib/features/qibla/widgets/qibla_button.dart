import 'package:flutter/material.dart';
import 'package:khushu/core/theme/app_colors.dart';

class QiblaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const QiblaButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark
        ? AppColors.sage.withValues(alpha: 0.25)
        : AppColors.deepGreen.withValues(alpha: 0.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surfaceColor,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(
              child: CustomPaint(
                size: const Size(28, 28),
                painter: _KaabahPainter(color: iconColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Qibla',
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.sage : AppColors.deepGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _KaabahPainter extends CustomPainter {
  final Color color;

  _KaabahPainter({required this.color});

  // ViewBox is 160x160, scaled down to 28x28
  static const double _vbSize = 160.0;

  Offset _scale(double x, double y, Size size) {
    return Offset(x / _vbSize * size.width, y / _vbSize * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * size.width / 28.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Circle border
    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * size.width / 28.0;
    canvas.drawCircle(
      _scale(80, 80, size),
      74 / _vbSize * size.width,
      circlePaint,
    );

    // Front face fill
    final frontPath = Path()
      ..moveTo(_scale(48, 70, size).dx, _scale(48, 70, size).dy)
      ..lineTo(_scale(48, 120, size).dx, _scale(48, 120, size).dy)
      ..lineTo(_scale(96, 120, size).dx, _scale(96, 120, size).dy)
      ..lineTo(_scale(96, 70, size).dx, _scale(96, 70, size).dy)
      ..close();
    canvas.drawPath(frontPath, fillPaint);

    // Top face fill
    final topPath = Path()
      ..moveTo(_scale(48, 70, size).dx, _scale(48, 70, size).dy)
      ..lineTo(_scale(72, 50, size).dx, _scale(72, 50, size).dy)
      ..lineTo(_scale(120, 50, size).dx, _scale(120, 50, size).dy)
      ..lineTo(_scale(96, 70, size).dx, _scale(96, 70, size).dy)
      ..close();
    final topFillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topFillPaint);

    // Right face fill
    final rightPath = Path()
      ..moveTo(_scale(96, 70, size).dx, _scale(96, 70, size).dy)
      ..lineTo(_scale(120, 50, size).dx, _scale(120, 50, size).dy)
      ..lineTo(_scale(120, 100, size).dx, _scale(120, 100, size).dy)
      ..lineTo(_scale(96, 120, size).dx, _scale(96, 120, size).dy)
      ..close();
    final rightFillPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightPath, rightFillPaint);

    // Draw front face outline
    canvas.drawPath(frontPath, paint);
    // Draw top face outline
    canvas.drawPath(topPath, paint);
    // Draw right face outline
    canvas.drawPath(rightPath, paint);

    // Hizam (band) — front
    canvas.drawLine(
      _scale(48, 88, size),
      _scale(96, 88, size),
      paint,
    );
    // Hizam — right face
    canvas.drawLine(
      _scale(96, 88, size),
      _scale(120, 68, size),
      paint,
    );

    // Door (filled rect on front face)
    final doorLeft = _scale(65, 100, size);
    final doorRect = Rect.fromLTWH(
      doorLeft.dx,
      doorLeft.dy,
      14 / _vbSize * size.width,
      20 / _vbSize * size.height,
    );
    final doorFill = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawRect(doorRect, doorFill);
    canvas.drawRect(doorRect, paint);
  }

  @override
  bool shouldRepaint(_KaabahPainter oldDelegate) =>
      oldDelegate.color != color;
}
