import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/prayer_times.dart';

void main() {
  group('PrayerTimes', () {
    test('fromAlAdhanJson parses API response correctly', () {
      final json = {
        'Fajr': '05:38',
        'Sunrise': '06:52',
        'Dhuhr': '13:13',
        'Asr': '16:48',
        'Maghrib': '19:35',
        'Isha': '20:49',
      };

      final times = PrayerTimes.fromAlAdhanJson(json, DateTime(2026, 4, 3));

      expect(times.fajr, '05:38');
      expect(times.sunrise, '06:52');
      expect(times.dhuhr, '13:13');
      expect(times.asr, '16:48');
      expect(times.maghrib, '19:35');
      expect(times.isha, '20:49');
      expect(times.date, DateTime(2026, 4, 3));
    });

    test('nextPrayer returns correct prayer based on current time', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final next = times.nextPrayer(DateTime(2026, 4, 3, 14, 0));
      expect(next.name, 'Asr');
      expect(next.time, '16:48');
    });

    test('currentPrayer returns null between Sunrise and Dhuhr', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      // During Fajr — should return Fajr
      expect(times.currentPrayer(DateTime(2026, 4, 3, 6, 0))?.name, 'Fajr');
      // After Sunrise, before Dhuhr — no active prayer
      expect(times.currentPrayer(DateTime(2026, 4, 3, 7, 0)), isNull);
      expect(times.currentPrayer(DateTime(2026, 4, 3, 12, 0)), isNull);
      // At Dhuhr — should return Dhuhr
      expect(times.currentPrayer(DateTime(2026, 4, 3, 13, 13))?.name, 'Dhuhr');
    });

    test('nextPrayer returns Fajr when after Isha', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final next = times.nextPrayer(DateTime(2026, 4, 3, 22, 0));
      expect(next.name, 'Fajr');
    });

    test('toDisplayList returns 6 rows always', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final list = times.toDisplayList();
      expect(list.length, 6);
      expect(list[3].name, 'Asr');
      expect(list[3].hasDualTime, false);
    });

    test('toDisplayList Asr has dual time with Hanafi', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      ).withHanafiAsr('17:45');

      final list = times.toDisplayList();
      expect(list.length, 6);
      expect(list[3].name, 'Asr');
      expect(list[3].time, '16:48');
      expect(list[3].hasDualTime, true);
      expect(list[3].secondaryName, 'Asr (Hanafi)');
      expect(list[3].secondaryTime, '17:45');
    });
  });
}
