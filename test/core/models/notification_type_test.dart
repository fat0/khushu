import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/notification_type.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('NotificationType', () {
    test('has all expected values', () {
      expect(NotificationType.values.length, 5);
      expect(NotificationType.values, contains(NotificationType.off));
      expect(NotificationType.values, contains(NotificationType.silent));
      expect(NotificationType.values, contains(NotificationType.vibrate));
      expect(NotificationType.values, contains(NotificationType.sound));
      expect(NotificationType.values, contains(NotificationType.adhan));
    });
  });

  group('SoundPreference', () {
    test('has system and gentle options', () {
      expect(SoundPreference.values.length, 2);
      expect(SoundPreference.values, contains(SoundPreference.system));
      expect(SoundPreference.values, contains(SoundPreference.gentle));
    });
  });

  group('UserSettings with notifications', () {
    test('defaults all prayers to sound', () {
      const settings = UserSettings();
      expect(settings.notificationFor('Fajr'), NotificationType.sound);
      expect(settings.notificationFor('Dhuhr'), NotificationType.sound);
      expect(settings.notificationFor('Asr'), NotificationType.sound);
      expect(settings.notificationFor('Maghrib'), NotificationType.sound);
      expect(settings.notificationFor('Isha'), NotificationType.sound);
    });

    test('defaults sound preference to system', () {
      const settings = UserSettings();
      expect(settings.soundPreference, SoundPreference.system);
    });

    test('serializes and deserializes notification settings', () {
      final settings = const UserSettings().copyWith(
        notificationTypes: {'Fajr': NotificationType.adhan, 'Dhuhr': NotificationType.vibrate},
        soundPreference: SoundPreference.gentle,
      );
      final json = settings.toJson();
      final restored = UserSettings.fromJson(json);
      expect(restored.notificationFor('Fajr'), NotificationType.adhan);
      expect(restored.notificationFor('Dhuhr'), NotificationType.vibrate);
      expect(restored.notificationFor('Asr'), NotificationType.sound);
      expect(restored.soundPreference, SoundPreference.gentle);
    });

    test('Sunrise returns off', () {
      const settings = UserSettings();
      expect(settings.notificationFor('Sunrise'), NotificationType.off);
    });
  });
}
