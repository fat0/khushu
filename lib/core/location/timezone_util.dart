import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;
import '../debug_log.dart';

class TimezoneUtil {
  // IANA timezone renames — lat_lng_to_timezone may return old names
  static const _tzAliases = {
    'Europe/Kiev': 'Europe/Kyiv',
    'Asia/Calcutta': 'Asia/Kolkata',
    'Asia/Rangoon': 'Asia/Yangon',
    'Asia/Saigon': 'Asia/Ho_Chi_Minh',
    'Pacific/Samoa': 'Pacific/Pago_Pago',
    'US/Eastern': 'America/New_York',
    'US/Central': 'America/Chicago',
    'US/Mountain': 'America/Denver',
    'US/Pacific': 'America/Los_Angeles',
  };

  static tz.Location _getLocation(String tzName) {
    // Try exact name first
    try {
      return tz.getLocation(tzName);
    } catch (_) {}

    // Try known aliases
    final alias = _tzAliases[tzName];
    if (alias != null) {
      try {
        return tz.getLocation(alias);
      } catch (_) {}
    }

    // Try replacing common prefixes (e.g., US/Eastern → America/New_York)
    // Log the failure for debugging
    DebugLog.info('[TZ] Unknown timezone: $tzName — trying UTC offset fallback');
    throw Exception('Unknown timezone: $tzName');
  }

  static DateTime nowAt(double latitude, double longitude) {
    try {
      final tzName = tzmap.latLngToTimezoneString(latitude, longitude);
      final location = _getLocation(tzName);
      final now = tz.TZDateTime.now(location);
      DebugLog.info('[TZ] nowAt($latitude, $longitude) → $tzName → ${now.hour}:${now.minute}');
      return now;
    } catch (e) {
      DebugLog.info('[TZ] nowAt FAILED for ($latitude, $longitude): $e — falling back to device time');
      return DateTime.now();
    }
  }

  /// Create a DateTime for a specific hour:minute in the location's timezone
  static DateTime timeAt(double latitude, double longitude, int hour, int minute) {
    try {
      final tzName = tzmap.latLngToTimezoneString(latitude, longitude);
      final location = _getLocation(tzName);
      final now = tz.TZDateTime.now(location);
      return tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    } catch (e) {
      DebugLog.info('[TZ] timeAt FAILED for ($latitude, $longitude): $e');
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
  }
}
