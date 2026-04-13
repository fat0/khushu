import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:khushu/core/theme/app_colors.dart';

/// Fallback widget for devices without a magnetometer.
/// Displays a static rotated arrow with the calculated bearing angle and
/// an info box explaining that no compass sensor was detected.
class StaticBearing extends StatelessWidget {
  const StaticBearing({
    super.key,
    required this.bearing,
    required this.compassDirection,
  });

  final double bearing;
  final String compassDirection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Static arrow rotated to bearing
            Transform.rotate(
              angle: bearing * math.pi / 180,
              child: Icon(
                Icons.navigation,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            // Bearing text
            Text(
              '${bearing.toStringAsFixed(1)}° $compassDirection',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle
            Text(
              'Qibla direction from your location',
              style: TextStyle(
                fontSize: 14,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            // Info box
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSecondary.withValues(alpha: 0.2)
                    : AppColors.lightSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: secondaryColor.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: secondaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No compass sensor detected.\nShowing calculated bearing only.',
                      style: TextStyle(
                        fontSize: 13,
                        color: secondaryColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
