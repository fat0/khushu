import 'package:flutter/material.dart';
import '../../../core/models/prayer_times.dart';
import '../../../core/models/rakat_data.dart';
import '../../../core/theme/app_colors.dart';

class PrayerTimeRow extends StatelessWidget {
  final PrayerTimeEntry entry;
  final bool isHighlighted;
  final bool isExpanded;
  final RakatInfo? rakatInfo;
  final VoidCallback? onTap;

  const PrayerTimeRow({
    super.key,
    required this.entry,
    this.isHighlighted = false,
    this.isExpanded = false,
    this.rakatInfo,
    this.onTap,
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

    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: isHighlighted
              ? const Border(left: BorderSide(color: AppColors.sage, width: 3))
              : null,
        ),
        child: Column(
          children: [
            // Primary row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                          color: nameColor,
                        ),
                      ),
                      if (rakatInfo != null) ...[
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.expand_more,
                            size: 16,
                            color: nameColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    entry.time,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: timeColor,
                    ),
                  ),
                ],
              ),
            ),
            // Secondary Asr row (Hanafi) — inside the same widget
            if (entry.hasDualTime)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.secondaryName!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                    Text(
                      entry.secondaryTime!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            // Expandable rakat section
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpansion(isDark),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansion(bool isDark) {
    if (rakatInfo == null) return const SizedBox.shrink();

    final detailColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    if (rakatInfo!.isSunrise) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: Text(
          RakatInfo.sunriseNote,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: detailColor,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rakatInfo!.items.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            r.display,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: detailColor,
            ),
          ),
        )).toList(),
      ),
    );
  }
}
