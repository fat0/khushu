import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/location/region_detector.dart';

void main() {
  group('RegionDetector', () {
    test('North America returns ISNA (2)', () {
      expect(RegionDetector.detectMethod(37.77, -122.42), 2);
    });

    test('Europe returns MWL (3)', () {
      expect(RegionDetector.detectMethod(51.51, -0.13), 3);
    });

    test('Saudi Arabia returns Umm Al-Qura (4)', () {
      expect(RegionDetector.detectMethod(21.39, 39.86), 4);
    });

    test('Egypt returns Egyptian (5)', () {
      expect(RegionDetector.detectMethod(30.04, 31.24), 5);
    });

    test('Pakistan returns Karachi (1)', () {
      expect(RegionDetector.detectMethod(24.86, 67.01), 1);
    });

    test('Turkey returns Turkey (13)', () {
      expect(RegionDetector.detectMethod(41.01, 28.98), 13);
    });

    test('Iran returns Tehran (7)', () {
      expect(RegionDetector.detectMethod(35.69, 51.39), 7);
    });

    test('unknown region defaults to MWL (3)', () {
      expect(RegionDetector.detectMethod(-80.0, 0.0), 3);
    });
  });
}
