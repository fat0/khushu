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

    test('nextPrayer returns Fajr when after Isha', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final next = times.nextPrayer(DateTime(2026, 4, 3, 22, 0));
      expect(next.name, 'Fajr');
    });

    test('combinedList returns 4 rows when combine is true', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final combined = times.toDisplayList(combine: true);
      expect(combined.length, 4);
      expect(combined[0].name, 'Fajr');
      expect(combined[1].name, 'Sunrise');
      expect(combined[2].name, 'Dhuhr + Asr');
      expect(combined[3].name, 'Maghrib + Isha');
    });

    test('toDisplayList returns 6 rows when combine is false', () {
      final times = PrayerTimes(
        fajr: '05:38', sunrise: '06:52', dhuhr: '13:13',
        asr: '16:48', maghrib: '19:35', isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final list = times.toDisplayList(combine: false);
      expect(list.length, 6);
    });
  });
}
