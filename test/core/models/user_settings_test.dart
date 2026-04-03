import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('default values are correct', () {
      const settings = UserSettings();

      expect(settings.tradition, Tradition.sunniStandard);
      expect(settings.methodId, isNull);
      expect(settings.combinePrayers, false);
      expect(settings.darkMode, isNull);
      expect(settings.latitude, isNull);
      expect(settings.longitude, isNull);
      expect(settings.locationName, isNull);
      expect(settings.onboardingComplete, false);
    });

    test('apiSchool returns 1 for Hanafi, 0 otherwise', () {
      const hanafi = UserSettings(tradition: Tradition.sunniHanafi);
      expect(hanafi.apiSchool, 1);

      const standard = UserSettings(tradition: Tradition.sunniStandard);
      expect(standard.apiSchool, 0);

      const jafari = UserSettings(tradition: Tradition.jafari);
      expect(jafari.apiSchool, 0);
    });

    test('apiMethod returns 0 for Jafari, methodId for Sunni', () {
      const jafari = UserSettings(tradition: Tradition.jafari, methodId: 2);
      expect(jafari.apiMethod, 0);

      const sunni = UserSettings(tradition: Tradition.sunniStandard, methodId: 2);
      expect(sunni.apiMethod, 2);
    });
  });
}
