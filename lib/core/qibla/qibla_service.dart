import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblaService {
  /// Check if the device has a magnetometer (Android only; iOS always true).
  static Future<bool> hasMagnetometer() async {
    final support = await FlutterQiblah.androidDeviceSensorSupport();
    return support ?? true; // iOS returns null — always has magnetometer
  }

  /// Stream of Qibla direction data from flutter_qiblah.
  static Stream<QiblahDirection> get qiblahStream =>
      FlutterQiblah.qiblahStream;

  /// Stream of compass events for accuracy/calibration detection.
  static Stream<CompassEvent?> get compassEvents =>
      FlutterCompass.events ?? const Stream.empty();

  /// Calculate static Qibla bearing using adhan package.
  /// Returns bearing in degrees (0-360) from the given coordinates.
  static double getStaticBearing(double latitude, double longitude) {
    final coordinates = Coordinates(latitude, longitude);
    return Qibla(coordinates).direction;
  }

  /// Convert a bearing in degrees to a compass direction string.
  static String bearingToCompassDirection(double bearing) {
    // Normalize to 0-360
    bearing = bearing % 360;
    if (bearing < 0) bearing += 360;

    if (bearing >= 337.5 || bearing < 22.5) return 'N';
    if (bearing < 67.5) return 'NE';
    if (bearing < 112.5) return 'E';
    if (bearing < 157.5) return 'SE';
    if (bearing < 202.5) return 'S';
    if (bearing < 247.5) return 'SW';
    if (bearing < 292.5) return 'W';
    return 'NW';
  }

  /// Dispose the flutter_qiblah stream.
  static void dispose() {
    FlutterQiblah().dispose();
  }
}
