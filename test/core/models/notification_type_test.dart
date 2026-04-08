import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/notification_type.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('NotificationType', () {
    test('has 3 values: off, sound, adhan', () {
      expect(NotificationType.values.length, 3);
      expect(NotificationType.values, contains(NotificationType.off));
      expect(NotificationType.values, contains(NotificationType.sound));
      expect(NotificationType.values, contains(NotificationType.adhan));
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

    test('serializes and deserializes notification settings', () {
      final settings = const UserSettings().copyWith(
        notificationTypes: {'Fajr': NotificationType.adhan, 'Dhuhr': NotificationType.off},
      );
      final json = settings.toJson();
      final restored = UserSettings.fromJson(json);
      expect(restored.notificationFor('Fajr'), NotificationType.adhan);
      expect(restored.notificationFor('Dhuhr'), NotificationType.off);
      expect(restored.notificationFor('Asr'), NotificationType.sound);
    });

    test('Sunrise returns off', () {
      const settings = UserSettings();
      expect(settings.notificationFor('Sunrise'), NotificationType.off);
    });
  });
}
