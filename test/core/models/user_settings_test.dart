import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('default values are correct', () {
      const settings = UserSettings();

      expect(settings.fiqh, Fiqh.sunni);
      expect(settings.methodId, isNull);
      expect(settings.latitude, isNull);
      expect(settings.longitude, isNull);
      expect(settings.locationName, isNull);
      expect(settings.onboardingComplete, false);
    });

    test('apiMethod returns 0 for Jafari, methodId for Sunni', () {
      const jafari = UserSettings(fiqh: Fiqh.jafari, methodId: 2);
      expect(jafari.apiMethod, 0);

      const sunni = UserSettings(fiqh: Fiqh.sunni, methodId: 2);
      expect(sunni.apiMethod, 2);
    });

    test('migration: old sunniStandard(0) maps to sunni', () {
      final settings = UserSettings.fromJson({'fiqh': 0});
      expect(settings.fiqh, Fiqh.sunni);
    });

    test('migration: old sunniHanafi(1) maps to sunni', () {
      final settings = UserSettings.fromJson({'fiqh': 1});
      expect(settings.fiqh, Fiqh.sunni);
    });

    test('migration: old jafari(2) maps to jafari', () {
      final settings = UserSettings.fromJson({'fiqh': 2});
      expect(settings.fiqh, Fiqh.jafari);
    });
  });
}
