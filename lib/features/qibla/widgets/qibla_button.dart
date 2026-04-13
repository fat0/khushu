import 'package:flutter/material.dart';
import 'package:khushu/core/theme/app_colors.dart';

class QiblaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const QiblaButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark
        ? AppColors.sage.withValues(alpha: 0.25)
        : AppColors.deepGreen.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: surfaceColor,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: CustomPaint(
            size: const Size(24, 27),
            painter: _KaabahPainter(isDark: isDark),
          ),
        ),
      ),
    );
  }
}

class _KaabahPainter extends CustomPainter {
  final bool isDark;

  _KaabahPainter({required this.isDark});

  // ViewBox: 130 x 148
  static const double _vbW = 130.0;
  static const double _vbH = 148.0;

  Offset _s(double x, double y, Size size) {
    return Offset(x / _vbW * size.width, y / _vbH * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Arrow
    final arrowColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;
    final arrow = Path()
      ..moveTo(_s(65, 2, size).dx, _s(65, 2, size).dy)
      ..lineTo(_s(48, 42, size).dx, _s(48, 42, size).dy)
      ..lineTo(_s(65, 30, size).dx, _s(65, 30, size).dy)
      ..lineTo(_s(82, 42, size).dx, _s(82, 42, size).dy)
      ..close();
    canvas.drawPath(arrow, arrowPaint);

    // Top face
    final topColor = isDark ? const Color(0xFF6B8C66) : const Color(0xFF7DA078);
    final top = Path()
      ..moveTo(_s(65, 48, size).dx, _s(65, 48, size).dy)
      ..lineTo(_s(20, 71, size).dx, _s(20, 71, size).dy)
      ..lineTo(_s(65, 94, size).dx, _s(65, 94, size).dy)
      ..lineTo(_s(110, 71, size).dx, _s(110, 71, size).dy)
      ..close();
    canvas.drawPath(top, Paint()..color = topColor);

    // Left face
    final leftColor = isDark ? AppColors.deepGreen : AppColors.deepGreen;
    final left = Path()
      ..moveTo(_s(20, 71, size).dx, _s(20, 71, size).dy)
      ..lineTo(_s(20, 121, size).dx, _s(20, 121, size).dy)
      ..lineTo(_s(65, 144, size).dx, _s(65, 144, size).dy)
      ..lineTo(_s(65, 94, size).dx, _s(65, 94, size).dy)
      ..close();
    canvas.drawPath(left, Paint()..color = leftColor);

    // Right face
    final rightColor = isDark ? const Color(0xFF2A4228) : const Color(0xFF2E4A2C);
    final right = Path()
      ..moveTo(_s(65, 94, size).dx, _s(65, 94, size).dy)
      ..lineTo(_s(65, 144, size).dx, _s(65, 144, size).dy)
      ..lineTo(_s(110, 121, size).dx, _s(110, 121, size).dy)
      ..lineTo(_s(110, 71, size).dx, _s(110, 71, size).dy)
      ..close();
    canvas.drawPath(right, Paint()..color = rightColor);

    // Hizam band — left face
    final hizamColor = isDark
        ? AppColors.sand.withValues(alpha: 0.8)
        : AppColors.sand;
    final hizamLeft = Path()
      ..moveTo(_s(20, 88, size).dx, _s(20, 88, size).dy)
      ..lineTo(_s(65, 111, size).dx, _s(65, 111, size).dy)
      ..lineTo(_s(65, 102, size).dx, _s(65, 102, size).dy)
      ..lineTo(_s(20, 79, size).dx, _s(20, 79, size).dy)
      ..close();
    canvas.drawPath(hizamLeft, Paint()..color = hizamColor);

    // Hizam band — right face
    final hizamRightColor = isDark
        ? const Color(0xFFC4B998).withValues(alpha: 0.8)
        : const Color(0xFFC4B998);
    final hizamRight = Path()
      ..moveTo(_s(65, 111, size).dx, _s(65, 111, size).dy)
      ..lineTo(_s(110, 88, size).dx, _s(110, 88, size).dy)
      ..lineTo(_s(110, 79, size).dx, _s(110, 79, size).dy)
      ..lineTo(_s(65, 102, size).dx, _s(65, 102, size).dy)
      ..close();
    canvas.drawPath(hizamRight, Paint()..color = hizamRightColor);
  }

  @override
  bool shouldRepaint(_KaabahPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
