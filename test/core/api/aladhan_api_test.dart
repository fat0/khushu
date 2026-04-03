import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/api/aladhan_api.dart';

void main() {
  group('AlAdhanApi', () {
    test('parseResponse extracts prayer times from API JSON', () {
      final apiResponse = {
        'code': 200,
        'status': 'OK',
        'data': {
          'timings': {
            'Fajr': '05:38',
            'Sunrise': '06:52',
            'Dhuhr': '13:13',
            'Asr': '16:48',
            'Sunset': '19:35',
            'Maghrib': '19:35',
            'Isha': '20:49',
            'Imsak': '05:28',
            'Midnight': '01:13',
            'Firstthird': '23:20',
            'Lastthird': '03:06',
          },
        },
      };

      final times = AlAdhanApi.parseResponse(apiResponse, DateTime(2026, 4, 3));

      expect(times.fajr, '05:38');
      expect(times.sunrise, '06:52');
      expect(times.dhuhr, '13:13');
      expect(times.asr, '16:48');
      expect(times.maghrib, '19:35');
      expect(times.isha, '20:49');
      expect(times.date, DateTime(2026, 4, 3));
    });

    test('buildUrl constructs correct API URL', () {
      final url = AlAdhanApi.buildUrl(
        latitude: 37.7749,
        longitude: -122.4194,
        method: 2,
        school: 0,
        date: DateTime(2026, 4, 3),
      );

      expect(url, contains('api.aladhan.com'));
      expect(url, contains('latitude=37.7749'));
      expect(url, contains('longitude=-122.4194'));
      expect(url, contains('method=2'));
      expect(url, contains('school=0'));
      expect(url, contains('03-04-2026'));
    });
  });
}
