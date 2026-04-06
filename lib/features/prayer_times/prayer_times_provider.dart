import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/aladhan_api.dart';
import '../../core/debug_log.dart';
import '../../core/location/timezone_util.dart';
import '../../core/models/prayer_times.dart';
import '../../core/models/user_settings.dart';
import '../../core/storage/hive_service.dart';
import '../settings/settings_provider.dart';

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, PrayerTimes>(
  PrayerTimesNotifier.new,
);

class PrayerTimesNotifier extends AsyncNotifier<PrayerTimes> {
  @override
  Future<PrayerTimes> build() async {
    final settings = ref.watch(settingsProvider);

    if (settings.latitude == null || settings.longitude == null) {
      throw Exception('Location not set');
    }

    // Try cache first
    final today = DateTime.now();
    final cached = HiveService.loadCachedPrayerTimes(today);
    if (cached != null) {
      DebugLog.info('Cache hit: asr=${cached.asr}, asrHanafi=${cached.asrHanafi}, fiqh=${settings.fiqh}');
      // For Sunni, cache must include Hanafi Asr
      // For Ja'fari, cache must NOT include Hanafi Asr
      final sunniValid = settings.fiqh == Fiqh.sunni && cached.asrHanafi != null;
      final jafariValid = settings.fiqh == Fiqh.jafari && cached.asrHanafi == null;
      if (sunniValid || jafariValid) {
        return cached;
      }
      DebugLog.info('Cache mismatch for ${settings.fiqh}, refetching...');
    }

    final times = await _fetchTimes(settings, today);
    DebugLog.info('Fetched: asr=${times.asr}, asrHanafi=${times.asrHanafi}');

    // Cache for today
    await HiveService.cachePrayerTimes(times);
    return times;
  }

  Future<PrayerTimes> _fetchTimes(UserSettings settings, DateTime date) async {
    // For Sunni, fetch standard (school=0) as base
    final times = await AlAdhanApi.fetchPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.apiMethod,
      school: 0,
      date: date,
    );

    // For Sunni, also fetch Hanafi Asr (school=1)
    if (settings.fiqh == Fiqh.sunni) {
      final hanafiTimes = await AlAdhanApi.fetchPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.apiMethod,
        school: 1,
        date: date,
      );
      return times.withHanafiAsr(hanafiTimes.asr);
    }

    return times;
  }

  Future<void> refresh() async {
    final settings = ref.read(settingsProvider);
    if (settings.latitude == null || settings.longitude == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final times = await _fetchTimes(settings, DateTime.now());
      await HiveService.cachePrayerTimes(times);
      return times;
    });
  }
}

// Countdown timer that ticks every second
final countdownProvider = StreamProvider<Duration>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);
  final settings = ref.watch(settingsProvider);

  return timesAsync.when(
    data: (times) {
      return Stream.periodic(const Duration(seconds: 1), (_) {
        final now = (settings.latitude != null && settings.longitude != null)
            ? TimezoneUtil.nowAt(settings.latitude!, settings.longitude!)
            : DateTime.now();
        final next = times.nextPrayer(now);
        final parts = next.time.split(':');
        var targetHour = int.parse(parts[0]);
        var targetMinute = int.parse(parts[1]);

        var target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);

        // If next prayer is tomorrow's Fajr
        if (target.isBefore(now)) {
          target = target.add(const Duration(days: 1));
        }

        return target.difference(now);
      });
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
