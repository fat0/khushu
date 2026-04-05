import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

/// Dome header sizing and text position documented in docs/dome-header-spec.md
/// Text at 53% from top, date line aligns with dome bottom edge.
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
    final textColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final svgColor = isDark
        ? AppColors.sage.withValues(alpha: 0.32)
        : AppColors.deepGreen.withValues(alpha: 0.45);

    final screenWidth = MediaQuery.of(context).size.width;
    // Scale SVG 1.5x wider than screen for proper dome size
    final svgDisplayWidth = screenWidth * 1.5;
    final svgDisplayHeight = svgDisplayWidth / 1.5;
    // Crop top 15% and bottom 25% — SVG has empty space above and below dome
    final containerHeight = svgDisplayHeight * 0.60;
    final textTop = containerHeight * 0.65;

    return SizedBox(
      height: containerHeight,
      width: screenWidth,
      child: ClipRect(
        child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Dome SVG — wider than screen, centered, top and bottom cropped
          Positioned(
            top: -svgDisplayHeight * 0.15,
            left: -(svgDisplayWidth - screenWidth) / 2,
            width: svgDisplayWidth,
            height: svgDisplayHeight,
            child: SvgPicture.asset(
              'assets/images/dome.svg',
              fit: BoxFit.fill,
              colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
            ),
          ),
          // Text overlay — positioned at 53% from top (inside dome belly)
          Positioned(
            top: textTop,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KHUSHU',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  locationName,
                  style: TextStyle(fontSize: 14, color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  date,
                  style: const TextStyle(fontSize: 13, color: AppColors.sage),
                  textAlign: TextAlign.center,
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
