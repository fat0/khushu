import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/prayer_times.dart';

class HiveService {
  static const _settingsBox = 'settings';
  static const _cacheBox = 'prayer_cache';
  static const _settingsKey = 'user_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
  }

  static UserSettings loadSettings() {
    final box = Hive.box(_settingsBox);
    final json = box.get(_settingsKey);
    if (json == null) return const UserSettings();
    return UserSettings.fromJson(Map<String, dynamic>.from(json));
  }

  static Future<void> saveSettings(UserSettings settings) async {
    final box = Hive.box(_settingsBox);
    await box.put(_settingsKey, settings.toJson());
  }

  static PrayerTimes? loadCachedPrayerTimes(DateTime date) {
    final box = Hive.box(_cacheBox);
    final key = '${date.year}-${date.month}-${date.day}';
    final json = box.get(key);
    if (json == null) return null;
    return PrayerTimes.fromAlAdhanJson(Map<String, dynamic>.from(json), date);
  }

  static Future<void> clearPrayerCache() async {
    final box = Hive.box(_cacheBox);
    await box.clear();
  }

  static Future<void> cachePrayerTimes(PrayerTimes times) async {
    final box = Hive.box(_cacheBox);
    final key = '${times.date.year}-${times.date.month}-${times.date.day}';
    await box.put(key, {
      'Fajr': times.fajr,
      'Sunrise': times.sunrise,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    });
  }
}
