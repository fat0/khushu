import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/qibla_provider.dart';

void main() {
  group('QiblaState', () {
    test('creates loading state', () {
      const state = QiblaState.loading();
      expect(state.isLoading, true);
      expect(state.hasMagnetometer, true);
      expect(state.needsCalibration, false);
    });

    test('creates no-magnetometer state with bearing', () {
      const state = QiblaState.noMagnetometer(
        staticBearing: 58.2,
        compassDirection: 'NE',
      );
      expect(state.hasMagnetometer, false);
      expect(state.staticBearing, 58.2);
      expect(state.compassDirection, 'NE');
      expect(state.isLoading, false);
    });

    test('creates active compass state', () {
      const state = QiblaState(
        isLoading: false,
        hasMagnetometer: true,
        qiblaDirection: 58.2,
        compassHeading: 142.0,
        needsCalibration: false,
      );
      expect(state.qiblaDirection, 58.2);
      expect(state.compassHeading, 142.0);
      expect(state.isAligned, false);
    });

    test('isAligned is true when qibla screen angle is near 0', () {
      const state = QiblaState(
        isLoading: false,
        hasMagnetometer: true,
        qiblaDirection: 3.0, // near 0 = phone pointing at Qibla
        compassHeading: 56.0,
        needsCalibration: false,
      );
      expect(state.isAligned, true);
    });
  });
}
