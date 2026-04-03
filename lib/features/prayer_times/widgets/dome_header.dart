import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DomeHeader extends StatelessWidget {
  final String locationName;
  final String date;

  const DomeHeader({
    super.key,
    required this.locationName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strokeColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final strokeOpacity = isDark ? 0.32 : 0.45;
    final textColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return SizedBox(
      height: 135,
      child: CustomPaint(
        size: const Size(double.infinity, 135),
        painter: _DomePainter(
          strokeColor: strokeColor,
          opacity: strokeOpacity,
          isDark: isDark,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KHUSHU',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  locationName,
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: AppColors.sage),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DomePainter extends CustomPainter {
  final Color strokeColor;
  final double opacity;
  final bool isDark;

  _DomePainter({
    required this.strokeColor,
    required this.opacity,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final cx = size.width / 2;
    final bottom = size.height;

    // Left minaret — two parallel lines + pointed top, open bottom
    canvas.drawLine(Offset(cx - 115, bottom), Offset(cx - 115, 50), paint);
    canvas.drawLine(Offset(cx - 105, bottom), Offset(cx - 105, 50), paint);
    final leftTop = Path()
      ..moveTo(cx - 115, 50)
      ..quadraticBezierTo(cx - 115, 38, cx - 110, 28)
      ..quadraticBezierTo(cx - 105, 38, cx - 105, 50);
    canvas.drawPath(leftTop, paint);

    // Right minaret
    canvas.drawLine(Offset(cx + 105, bottom), Offset(cx + 105, 50), paint);
    canvas.drawLine(Offset(cx + 115, bottom), Offset(cx + 115, 50), paint);
    final rightTop = Path()
      ..moveTo(cx + 105, 50)
      ..quadraticBezierTo(cx + 105, 38, cx + 110, 28)
      ..quadraticBezierTo(cx + 115, 38, cx + 115, 50);
    canvas.drawPath(rightTop, paint);

    // Dome arc — open bottom
    final dome = Path()
      ..moveTo(cx - 105, bottom)
      ..arcToPoint(
        Offset(cx + 105, bottom),
        radius: const Radius.elliptical(120, 95),
        clockwise: false,
      );
    canvas.drawPath(dome, paint);

    // Crescent moon — tilted, open side facing right
    canvas.save();
    canvas.translate(cx, 14);
    canvas.rotate(-0.52); // ~-30 degrees
    canvas.scale(-1, 1); // flip horizontal so open side faces right

    final moonPaint = Paint()
      ..color = strokeColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(Offset.zero, 6, moonPaint);

    final moonCutout = Paint()
      ..color = isDark ? AppColors.darkBackground : AppColors.lightBackground
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(2.8, -1.5), 5, moonCutout);

    canvas.restore();

    // Finial stem
    canvas.drawLine(Offset(cx, 24), Offset(cx, 34), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
