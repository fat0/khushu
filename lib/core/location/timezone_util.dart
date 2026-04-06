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
}
