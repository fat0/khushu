import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;
import '../../../core/hijri/hijri_service.dart';
import '../../../core/models/user_settings.dart';
import '../../../core/theme/app_colors.dart';

/// Dome header sizing and text position documented in docs/dome-header-spec.md
/// Text at 58% from top, two-line date+time layout.
class DomeHeader extends StatefulWidget {
  final String locationName;
  final double? latitude;
  final double? longitude;
  final bool isOffline;
  final CalendarType calendarType;
  final String? hijriDate;

  const DomeHeader({
    super.key,
    required this.locationName,
    this.latitude,
    this.longitude,
    this.isOffline = false,
    this.calendarType = CalendarType.gregorian,
    this.hijriDate,
  });

  @override
  State<DomeHeader> createState() => _DomeHeaderState();
}

class _DomeHeaderState extends State<DomeHeader> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (widget.latitude != null && widget.longitude != null) {
      try {
        final tzName = tzmap.latLngToTimezoneString(
          widget.latitude!,
          widget.longitude!,
        );
        final location = tz.getLocation(tzName);
        setState(() => _now = tz.TZDateTime.now(location));
        return;
      } catch (_) {
        // Fall back to device time
      }
    }
    setState(() => _now = DateTime.now());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor = isDark ? AppColors.sage.withValues(alpha: 0.7) : AppColors.deepGreen.withValues(alpha: 0.7);
    final svgColor = isDark
        ? AppColors.sage.withValues(alpha: 0.32)
        : AppColors.deepGreen.withValues(alpha: 0.45);

    final screenWidth = MediaQuery.of(context).size.width;
    final svgDisplayWidth = screenWidth * 1.5;
    final svgDisplayHeight = svgDisplayWidth / 1.5;
    final containerHeight = svgDisplayHeight * 0.60;
    final textTop = containerHeight * 0.58;

    final timeStr = DateFormat('h:mm a').format(_now);
    final String dateDisplay;
    if (widget.calendarType == CalendarType.hijri) {
      if (widget.hijriDate != null) {
        dateDisplay = widget.hijriDate!;
      } else {
        final hijri = HijriService.fromGregorian(_now);
        dateDisplay = HijriService.formatHijriDate(hijri);
      }
    } else {
      dateDisplay = DateFormat('EEE, MMM d, y').format(_now);
    }

    return SizedBox(
      height: containerHeight,
      width: screenWidth,
      child: ClipRect(
        child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
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
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.locationName,
                      style: TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                    if (widget.isOffline) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.wifi_off,
                        size: 12,
                        color: secondaryColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'offline',
                        style: TextStyle(
                          fontSize: 11,
                          color: secondaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateDisplay,
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.sage : AppColors.deepGreen.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 13, color: isDark ? AppColors.sage.withValues(alpha: 0.6) : AppColors.deepGreen.withValues(alpha: 0.4)),
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
