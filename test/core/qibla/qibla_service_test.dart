import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/qibla/qibla_service.dart';

void main() {
  group('QiblaService', () {
    group('getStaticBearing', () {
      test('returns bearing for Sterling VA (NE direction)', () {
        // Sterling, VA: 39.0066° N, 77.4291° W
        final bearing = QiblaService.getStaticBearing(39.0066, -77.4291);
        // Qibla from Virginia is roughly NE (~58°)
        expect(bearing, greaterThan(50));
        expect(bearing, lessThan(70));
      });

      test('returns bearing for Makkah (0° — already there)', () {
        // Exact Ka'bah coordinates as used by adhan internally
        final bearing = QiblaService.getStaticBearing(21.4225241, 39.8261818);
        // When at the Ka'bah, bearing is essentially 0 or 360
        expect(bearing, anyOf(closeTo(0, 5), closeTo(360, 5)));
      });

      test('returns bearing for Tokyo (WNW direction)', () {
        // Tokyo: 35.6762° N, 139.6503° E
        final bearing = QiblaService.getStaticBearing(35.6762, 139.6503);
        // Qibla from Tokyo is roughly WNW (~293°)
        expect(bearing, greaterThan(280));
        expect(bearing, lessThan(300));
      });
    });

    group('bearingToCompassDirection', () {
      test('returns N for 0°', () {
        expect(QiblaService.bearingToCompassDirection(0), 'N');
      });

      test('returns NE for 45°', () {
        expect(QiblaService.bearingToCompassDirection(45), 'NE');
      });

      test('returns E for 90°', () {
        expect(QiblaService.bearingToCompassDirection(90), 'E');
      });

      test('returns SE for 135°', () {
        expect(QiblaService.bearingToCompassDirection(135), 'SE');
      });

      test('returns S for 180°', () {
        expect(QiblaService.bearingToCompassDirection(180), 'S');
      });

      test('returns SW for 225°', () {
        expect(QiblaService.bearingToCompassDirection(225), 'SW');
      });

      test('returns W for 270°', () {
        expect(QiblaService.bearingToCompassDirection(270), 'W');
      });

      test('returns NW for 315°', () {
        expect(QiblaService.bearingToCompassDirection(315), 'NW');
      });
    });
  });
}
