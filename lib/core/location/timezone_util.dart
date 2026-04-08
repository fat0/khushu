import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;

class TimezoneUtil {
  static DateTime nowAt(double latitude, double longitude) {
    try {
      final tzName = tzmap.latLngToTimezoneString(latitude, longitude);
      final location = tz.getLocation(tzName);
      return tz.TZDateTime.now(location);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Create a DateTime for a specific hour:minute in the location's timezone
  static DateTime timeAt(double latitude, double longitude, int hour, int minute) {
    try {
      final tzName = tzmap.latLngToTimezoneString(latitude, longitude);
      final location = tz.getLocation(tzName);
      final now = tz.TZDateTime.now(location);
      return tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    } catch (_) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
  }
}
