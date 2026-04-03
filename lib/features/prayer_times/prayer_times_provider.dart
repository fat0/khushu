import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/aladhan_api.dart';
import '../../core/models/prayer_times.dart';
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
    if (cached != null) return cached;

    // Fetch from API
    final times = await AlAdhanApi.fetchPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.apiMethod,
      school: settings.apiSchool,
      date: today,
    );

    // Cache for today
    await HiveService.cachePrayerTimes(times);
    return times;
  }

  Future<void> refresh() async {
    final settings = ref.read(settingsProvider);
    if (settings.latitude == null || settings.longitude == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final times = await AlAdhanApi.fetchPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.apiMethod,
        school: settings.apiSchool,
        date: DateTime.now(),
      );
      await HiveService.cachePrayerTimes(times);
      return times;
    });
  }
}

// Countdown timer that ticks every second
final countdownProvider = StreamProvider<Duration>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);

  return timesAsync.when(
    data: (times) {
      return Stream.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
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
