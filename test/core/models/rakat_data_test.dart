import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/rakat_data.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('RakatData - Sunni', () {
    const fiqh = Fiqh.sunni;

    test('Fajr: 2 Sunnah, 2 Fard', () {
      final items = RakatData.getRakat('Fajr', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '2 Sunnah');
      expect(items[1].display, '2 Fard');
    });

    test('Dhuhr: 2 Sunnah (4 for Hanafi), 4 Fard, 2 Sunnah', () {
      final items = RakatData.getRakat('Dhuhr', fiqh);
      expect(items.length, 3);
      expect(items[0].display, '2 Sunnah (4 for Hanafi)');
      expect(items[1].display, '4 Fard');
      expect(items[2].display, '2 Sunnah');
    });

    test('Asr: 4 Fard only', () {
      final items = RakatData.getRakat('Asr', fiqh);
      expect(items.length, 1);
      expect(items[0].display, '4 Fard');
    });

    test('Asr with school label normalizes to asr key', () {
      final items1 = RakatData.getRakat('Asr (Maliki, Hanbali, Shafi\'i)', fiqh);
      final items2 = RakatData.getRakat('Asr (Hanafi)', fiqh);
      expect(items1[0].display, '4 Fard');
      expect(items2[0].display, '4 Fard');
    });

    test('Maghrib: 3 Fard, 2 Sunnah', () {
      final items = RakatData.getRakat('Maghrib', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '3 Fard');
      expect(items[1].display, '2 Sunnah');
    });

    test('Isha: 4 Fard, 2 Sunnah, 3 Witr', () {
      final items = RakatData.getRakat('Isha', fiqh);
      expect(items.length, 3);
      expect(items[0].display, '4 Fard');
      expect(items[1].display, '2 Sunnah');
      expect(items[2].display, '3 Witr');
    });
  });

  group('RakatData - Ja\'fari', () {
    const fiqh = Fiqh.jafari;

    test('Fajr: 2 Nafilah, 2 Fard', () {
      final items = RakatData.getRakat('Fajr', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '2 Nafilah');
      expect(items[1].display, '2 Fard');
    });

    test('Dhuhr: 8 Nafilah, 4 Fard', () {
      final items = RakatData.getRakat('Dhuhr', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '8 Nafilah');
      expect(items[1].display, '4 Fard');
    });

    test('Asr: 8 Nafilah, 4 Fard', () {
      final items = RakatData.getRakat('Asr', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '8 Nafilah');
      expect(items[1].display, '4 Fard');
    });

    test('Maghrib: 3 Fard, 4 Nafilah', () {
      final items = RakatData.getRakat('Maghrib', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '3 Fard');
      expect(items[1].display, '4 Nafilah');
    });

    test('Isha: 4 Fard, 2 Nafilah', () {
      final items = RakatData.getRakat('Isha', fiqh);
      expect(items.length, 2);
      expect(items[0].display, '4 Fard');
      expect(items[1].display, '2 Nafilah');
    });
  });

  group('RakatData - Sunrise', () {
    test('Sunrise returns sunrise info for all fiqhs', () {
      for (final fiqh in Fiqh.values) {
        final info = RakatData.getInfo('Sunrise', fiqh);
        expect(info.isSunrise, true);
        expect(info.items, isEmpty);
      }
    });

    test('Sunrise note text is correct', () {
      expect(RakatInfo.sunriseNote, 'Marks the end of Fajr time — no prayer');
    });
  });

  group('RakatData - Terminology', () {
    test('Sunni uses Sunnah and Witr', () {
      final isha = RakatData.getRakat('Isha', Fiqh.sunni);
      expect(isha.any((r) => r.label == 'Sunnah'), true);
      expect(isha.any((r) => r.label == 'Witr'), true);
    });

    test('Ja\'fari uses Nafilah', () {
      final isha = RakatData.getRakat('Isha', Fiqh.jafari);
      expect(isha.any((r) => r.label == 'Nafilah'), true);
    });
  });
}
