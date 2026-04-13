import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/hijri/hijri_service.dart';

void main() {
  group('HijriService', () {
    group('fromGregorian', () {
      test('converts a known date', () {
        // 2026-04-13 is approximately 15 Shawwal 1447
        final result = HijriService.fromGregorian(DateTime(2026, 4, 13));
        expect(result.day, isA<int>());
        expect(result.monthName, isNotEmpty);
        expect(result.year, greaterThan(1400));
      });

      test('returns valid month name', () {
        final result = HijriService.fromGregorian(DateTime(2026, 1, 1));
        final validMonths = [
          'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
          'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Shaban',
          'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah',
        ];
        expect(validMonths, contains(result.monthName));
      });
    });

    group('fromApiResponse', () {
      test('parses AlAdhan hijri date response', () {
        final hijriJson = {
          'day': '15',
          'month': {'number': 10, 'en': 'Shawwāl'},
          'year': '1448',
        };
        final result = HijriService.fromApiResponse(hijriJson);
        expect(result!.day, 15);
        expect(result.monthName, 'Shawwal');
        expect(result.year, 1448);
      });

      test('returns null for invalid response', () {
        final result = HijriService.fromApiResponse({});
        expect(result, isNull);
      });
    });

    group('formatHijriDate', () {
      test('formats as day monthName year', () {
        final date = HijriDate(day: 15, monthName: 'Shawwal', year: 1448);
        expect(HijriService.formatHijriDate(date), '15 Shawwal 1448');
      });
    });
  });
}
