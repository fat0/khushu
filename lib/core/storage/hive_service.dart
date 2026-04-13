import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/prayer_times.dart';

class HiveService {
  static const _settingsBox = 'settings';
  static const _cacheBox = 'prayer_cache';
  static const _settingsKey = 'user_settings';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
    _initialized = true;
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
    final map = Map<String, dynamic>.from(json);
    final sourceStr = map['source'] as String?;
    final source = sourceStr == 'offline' ? PrayerTimeSource.offline : PrayerTimeSource.api;
    var times = PrayerTimes.fromAlAdhanJson(map, date);
    times = PrayerTimes(
      fajr: times.fajr, sunrise: times.sunrise, dhuhr: times.dhuhr,
      asr: times.asr, maghrib: times.maghrib, isha: times.isha,
      date: times.date, source: source,
    );
    final asrHanafi = map['AsrHanafi'] as String?;
    if (asrHanafi != null) return times.withHanafiAsr(asrHanafi);
    return times;
  }

  static Future<void> clearPrayerCache() async {
    final box = Hive.box(_cacheBox);
    await box.clear();
  }

  static Future<void> cachePrayerTimes(PrayerTimes times, {double? lat, double? lng}) async {
    final box = Hive.box(_cacheBox);
    final key = '${times.date.year}-${times.date.month}-${times.date.day}';
    await box.put(key, {
      'Fajr': times.fajr,
      'Sunrise': times.sunrise,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      if (times.asrHanafi != null) 'AsrHanafi': times.asrHanafi,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
      if (lat != null) 'cachedLat': lat,
      if (lng != null) 'cachedLng': lng,
      'source': times.source == PrayerTimeSource.offline ? 'offline' : 'api',
    });
  }

  static bool isCacheValidForLocation(DateTime date, double lat, double lng) {
    final box = Hive.box(_cacheBox);
    final key = '${date.year}-${date.month}-${date.day}';
    final json = box.get(key);
    if (json == null) return false;
    final map = Map<String, dynamic>.from(json);
    final cachedLat = map['cachedLat'] as double?;
    final cachedLng = map['cachedLng'] as double?;
    if (cachedLat == null || cachedLng == null) return false;
    // Check if coordinates match (within ~1km)
    return (cachedLat - lat).abs() < 0.01 && (cachedLng - lng).abs() < 0.01;
  }
}
