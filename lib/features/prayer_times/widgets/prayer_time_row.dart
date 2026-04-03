import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrayerTimeRow extends StatelessWidget {
  final String name;
  final String time;
  final bool isHighlighted;

  const PrayerTimeRow({
    super.key,
    required this.name,
    required this.time,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color background;
    Color nameColor;
    Color timeColor;

    if (isHighlighted) {
      background = isDark ? AppColors.highlightDark : AppColors.highlightLight;
      nameColor = isDark ? AppColors.cream : AppColors.deepGreen;
      timeColor = isDark ? AppColors.sage : AppColors.deepGreen;
    } else {
      background = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      nameColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
      timeColor = isDark ? AppColors.sage : AppColors.deepGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? const Border(left: BorderSide(color: AppColors.sage, width: 3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              color: nameColor,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }
}
