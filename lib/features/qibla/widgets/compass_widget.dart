import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khushu/core/theme/app_colors.dart';

class CompassWidget extends StatelessWidget {
  final double qiblaDirection;
  final double compassHeading;
  final bool isAligned;

  const CompassWidget({
    super.key,
    required this.qiblaDirection,
    required this.compassHeading,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    const alignedColor = AppColors.sage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating compass ring
              Transform.rotate(
                angle: -compassHeading * pi / 180,
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: _CompassRingPainter(
                          primaryColor: primaryColor,
                          secondaryColor: secondaryColor,
                        ),
                      ),
                      // Cardinal labels as Text widgets (rotating with the ring)
                      // N — top
                      Positioned(
                        top: 12,
                        child: Text(
                          'N',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // S — bottom
                      Positioned(
                        bottom: 12,
                        child: Text(
                          'S',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // W — left
                      Positioned(
                        left: 12,
                        child: Text(
                          'W',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // E — right
                      Positioned(
                        right: 12,
                        child: Text(
                          'E',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ka'bah indicator — rotates to point at qibla
              Transform.rotate(
                angle: (qiblaDirection - compassHeading) * pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAligned
                            ? alignedColor
                            : primaryColor.withOpacity(0.8),
                        boxShadow: isAligned
                            ? [
                                BoxShadow(
                                  color: alignedColor.withOpacity(0.5),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Center dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Bearing readout
        Text(
          '${qiblaDirection.toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            color: primaryColor,
          ),
        ),

        const SizedBox(height: 8),

        // Status text
        Text(
          isAligned ? 'Facing Qibla' : 'Qibla Direction',
          style: TextStyle(
            fontSize: 14,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _CompassRingPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer circle ring
    final ringPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Degree ticks every 10°
    for (int deg = 0; deg < 360; deg += 10) {
      final isMajor = deg % 90 == 0;
      final tickLength = isMajor ? 16.0 : 8.0;
      final tickOpacity = isMajor ? 0.5 : 0.2;

      final tickPaint = Paint()
        ..color = primaryColor.withOpacity(tickOpacity)
        ..strokeWidth = isMajor ? 2.0 : 1.0;

      final angleRad = deg * pi / 180;
      final outerX = center.dx + radius * sin(angleRad);
      final outerY = center.dy - radius * cos(angleRad);
      final innerX = center.dx + (radius - tickLength) * sin(angleRad);
      final innerY = center.dy - (radius - tickLength) * cos(angleRad);

      canvas.drawLine(
        Offset(outerX, outerY),
        Offset(innerX, innerY),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CompassRingPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
