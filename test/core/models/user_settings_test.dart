import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('default values are correct', () {
      const settings = UserSettings();

      expect(settings.fiqh, Fiqh.sunniStandard);
      expect(settings.methodId, isNull);
      expect(settings.combinePrayers, false);
      expect(settings.darkMode, isNull);
      expect(settings.latitude, isNull);
      expect(settings.longitude, isNull);
      expect(settings.locationName, isNull);
      expect(settings.onboardingComplete, false);
    });

    test('apiSchool returns 1 for Hanafi, 0 otherwise', () {
      const hanafi = UserSettings(fiqh: Fiqh.sunniHanafi);
      expect(hanafi.apiSchool, 1);

      const standard = UserSettings(fiqh: Fiqh.sunniStandard);
      expect(standard.apiSchool, 0);

      const jafari = UserSettings(fiqh: Fiqh.jafari);
      expect(jafari.apiSchool, 0);
    });

    test('apiMethod returns 0 for Jafari, methodId for Sunni', () {
      const jafari = UserSettings(fiqh: Fiqh.jafari, methodId: 2);
      expect(jafari.apiMethod, 0);

      const sunni = UserSettings(fiqh: Fiqh.sunniStandard, methodId: 2);
      expect(sunni.apiMethod, 2);
    });
  });
}
