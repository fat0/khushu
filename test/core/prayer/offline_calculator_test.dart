import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/prayer_times.dart';
import 'package:khushu/core/prayer/offline_calculator.dart';

void main() {
  group('OfflineCalculator', () {
    test('calculates correct times for ISNA method (Sterling, VA)', () {
      final times = OfflineCalculator.calculate(
        latitude: 39.0066,
        longitude: -77.4286,
        methodId: 2, // ISNA
        isSunni: true,
        date: DateTime(2026, 4, 13),
      );

      expect(times.fajr, isNotEmpty);
      expect(times.sunrise, isNotEmpty);
      expect(times.dhuhr, isNotEmpty);
      expect(times.asr, isNotEmpty);
      expect(times.maghrib, isNotEmpty);
      expect(times.isha, isNotEmpty);
      expect(times.source, PrayerTimeSource.offline);
    });

    test('calculates dual Asr for Sunni', () {
      final times = OfflineCalculator.calculate(
        latitude: 39.0066,
        longitude: -77.4286,
        methodId: 2,
        isSunni: true,
        date: DateTime(2026, 4, 13),
      );

      expect(times.asrHanafi, isNotNull);
      expect(times.asrHanafi, isNotEmpty);
      // Hanafi Asr should be later than standard Asr
      final standardMinutes = _parseMinutes(times.asr);
      final hanafiMinutes = _parseMinutes(times.asrHanafi!);
      expect(hanafiMinutes, greaterThan(standardMinutes));
    });

    test('no Hanafi Asr for Ja\'fari', () {
      final times = OfflineCalculator.calculate(
        latitude: 39.0066,
        longitude: -77.4286,
        methodId: 0, // Jafari
        isSunni: false,
        date: DateTime(2026, 4, 13),
      );

      expect(times.asrHanafi, isNull);
      expect(times.source, PrayerTimeSource.offline);
    });

    test('method ID mapping covers all supported methods', () {
      final methodIds = [0, 1, 2, 3, 4, 5, 7, 8, 9, 11, 13, 15];

      for (final methodId in methodIds) {
        final times = OfflineCalculator.calculate(
          latitude: 21.3891,
          longitude: 39.8579, // Makkah
          methodId: methodId,
          isSunni: methodId != 0,
          date: DateTime(2026, 4, 13),
        );

        expect(times.fajr, isNotEmpty, reason: 'Method $methodId should return Fajr');
        expect(times.isha, isNotEmpty, reason: 'Method $methodId should return Isha');
      }
    });

    test('unmapped method ID falls back to MWL', () {
      final times = OfflineCalculator.calculate(
        latitude: 39.0066,
        longitude: -77.4286,
        methodId: 99, // Unknown method
        isSunni: true,
        date: DateTime(2026, 4, 13),
      );

      expect(times.fajr, isNotEmpty);
      expect(times.source, PrayerTimeSource.offline);
    });

    test('source is always offline', () {
      final times = OfflineCalculator.calculate(
        latitude: 51.5074,
        longitude: -0.1278, // London
        methodId: 3, // MWL
        isSunni: true,
        date: DateTime(2026, 4, 13),
      );

      expect(times.source, PrayerTimeSource.offline);
      expect(times.isOffline, true);
    });
  });

  group('PrayerTimeSource', () {
    test('API source is not offline', () {
      final times = PrayerTimes(
        fajr: '05:00', sunrise: '06:30', dhuhr: '13:00',
        asr: '16:30', maghrib: '19:30', isha: '21:00',
        date: DateTime(2026, 4, 13),
        source: PrayerTimeSource.api,
      );

      expect(times.isOffline, false);
    });

    test('offline source is offline', () {
      final times = PrayerTimes(
        fajr: '05:00', sunrise: '06:30', dhuhr: '13:00',
        asr: '16:30', maghrib: '19:30', isha: '21:00',
        date: DateTime(2026, 4, 13),
        source: PrayerTimeSource.offline,
      );

      expect(times.isOffline, true);
    });

    test('default source is api', () {
      final times = PrayerTimes(
        fajr: '05:00', sunrise: '06:30', dhuhr: '13:00',
        asr: '16:30', maghrib: '19:30', isha: '21:00',
        date: DateTime(2026, 4, 13),
      );

      expect(times.source, PrayerTimeSource.api);
      expect(times.isOffline, false);
    });

    test('withHanafiAsr preserves source', () {
      final times = PrayerTimes(
        fajr: '05:00', sunrise: '06:30', dhuhr: '13:00',
        asr: '16:30', maghrib: '19:30', isha: '21:00',
        date: DateTime(2026, 4, 13),
        source: PrayerTimeSource.offline,
      ).withHanafiAsr('17:30');

      expect(times.source, PrayerTimeSource.offline);
      expect(times.asrHanafi, '17:30');
    });
  });
}

int _parseMinutes(String time) {
  final parts = time.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}
