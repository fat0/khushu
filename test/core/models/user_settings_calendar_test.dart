import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('CalendarType in UserSettings', () {
    test('default calendarType is gregorian', () {
      const settings = UserSettings();
      expect(settings.calendarType, CalendarType.gregorian);
    });

    test('copyWith updates calendarType', () {
      const settings = UserSettings();
      final updated = settings.copyWith(calendarType: CalendarType.hijri);
      expect(updated.calendarType, CalendarType.hijri);
    });

    test('toJson includes calendarType', () {
      const settings = UserSettings(calendarType: CalendarType.hijri);
      final json = settings.toJson();
      expect(json['calendarType'], 1);
    });

    test('fromJson reads calendarType', () {
      final settings = UserSettings.fromJson({'calendarType': 1});
      expect(settings.calendarType, CalendarType.hijri);
    });

    test('fromJson defaults to gregorian when calendarType missing', () {
      final settings = UserSettings.fromJson({});
      expect(settings.calendarType, CalendarType.gregorian);
    });
  });
}
