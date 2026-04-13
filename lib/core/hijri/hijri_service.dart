import 'package:hijri/hijri_calendar.dart';

class HijriDate {
  final int day;
  final String monthName;
  final int year;

  const HijriDate({
    required this.day,
    required this.monthName,
    required this.year,
  });
}

class HijriService {
  static const _monthNames = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Shaban',
    'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah',
  ];

  /// Convert Gregorian DateTime to HijriDate using the hijri package.
  static HijriDate fromGregorian(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthIndex = hijri.hMonth - 1;
    final monthName = (monthIndex >= 0 && monthIndex < _monthNames.length)
        ? _monthNames[monthIndex]
        : 'Unknown';
    return HijriDate(
      day: hijri.hDay,
      monthName: monthName,
      year: hijri.hYear,
    );
  }

  /// Parse Hijri date from AlAdhan API response.
  /// Response format: { "day": "15", "month": { "number": 10, "en": "Shawwāl" }, "year": "1448" }
  static HijriDate? fromApiResponse(Map<String, dynamic> json) {
    try {
      final dayStr = json['day'] as String?;
      final monthMap = json['month'] as Map<String, dynamic>?;
      final yearStr = json['year'] as String?;

      if (dayStr == null || monthMap == null || yearStr == null) return null;

      final day = int.parse(dayStr);
      final monthNumber = monthMap['number'] as int;
      final year = int.parse(yearStr);

      final monthIndex = monthNumber - 1;
      final monthName = (monthIndex >= 0 && monthIndex < _monthNames.length)
          ? _monthNames[monthIndex]
          : 'Unknown';

      return HijriDate(day: day, monthName: monthName, year: year);
    } catch (_) {
      return null;
    }
  }

  /// Format a HijriDate as "15 Shawwal 1448".
  static String formatHijriDate(HijriDate date) {
    return '${date.day} ${date.monthName} ${date.year}';
  }
}
