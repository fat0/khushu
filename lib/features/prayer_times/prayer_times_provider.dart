import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/aladhan_api.dart';
import '../../core/debug_log.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/location/timezone_util.dart';
import '../../core/models/prayer_times.dart';
import '../../core/models/user_settings.dart';
import '../../core/prayer/offline_calculator.dart';
import '../../core/storage/hive_service.dart';
import '../settings/settings_provider.dart';

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, PrayerTimes>(
  PrayerTimesNotifier.new,
);

class PrayerTimesNotifier extends AsyncNotifier<PrayerTimes> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  Future<PrayerTimes> build() async {
    final settings = ref.watch(settingsProvider);

    if (settings.latitude == null || settings.longitude == null) {
      throw Exception('Location not set');
    }

    // Listen for connectivity changes — auto-refresh when connection changes
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      final currentState = state.valueOrNull;
      if (currentState == null) return;

      if (hasConnection && currentState.isOffline) {
        // Back online — refetch from API
        DebugLog.info('[CONNECTIVITY] Online — refreshing from API');
        refresh();
      } else if (!hasConnection && !currentState.isOffline) {
        // Lost connection — recalculate offline
        DebugLog.info('[CONNECTIVITY] Offline — switching to local calculation');
        _switchToOffline(settings);
      }
    });

    ref.onDispose(() => _connectivitySub?.cancel());

    // Try cache first — must match location and fiqh
    final today = DateTime.now();
    final locationValid = HiveService.isCacheValidForLocation(today, settings.latitude!, settings.longitude!);
    final cached = locationValid ? HiveService.loadCachedPrayerTimes(today) : null;
    if (cached != null) {
      DebugLog.info('Cache hit: asr=${cached.asr}, asrHanafi=${cached.asrHanafi}, fiqh=${settings.fiqh}, source=${cached.source}');
      final sunniValid = settings.fiqh == Fiqh.sunni && cached.asrHanafi != null;
      final jafariValid = settings.fiqh == Fiqh.jafari && cached.asrHanafi == null;
      if (sunniValid || jafariValid) {
        // Prefer API-sourced cache — if cache is offline and we might have internet, refetch
        if (cached.isOffline) {
          DebugLog.info('Cache is offline-sourced — trying API first...');
          try {
            final times = await _fetchTimesFromApi(settings, today);
            await HiveService.cachePrayerTimes(times, lat: settings.latitude, lng: settings.longitude);
            NotificationService.scheduleAllPrayers(times: times, settings: settings);
            return times;
          } catch (_) {
            DebugLog.info('API still unavailable — using offline cache');
            NotificationService.scheduleAllPrayers(times: cached, settings: settings);
            return cached;
          }
        }
        NotificationService.scheduleAllPrayers(times: cached, settings: settings);
        return cached;
      }
      DebugLog.info('Cache mismatch for ${settings.fiqh}, refetching...');
    }

    // Try API first, fall back to offline calculation
    final times = await _fetchTimesWithFallback(settings, today);
    await HiveService.cachePrayerTimes(times, lat: settings.latitude, lng: settings.longitude);
    NotificationService.scheduleAllPrayers(times: times, settings: settings);
    return times;
  }

  /// Try API → if fails → try adhan-dart → if fails → throw error
  Future<PrayerTimes> _fetchTimesWithFallback(UserSettings settings, DateTime date) async {
    try {
      final times = await _fetchTimesFromApi(settings, date);
      DebugLog.info('Fetched from API: asr=${times.asr}, asrHanafi=${times.asrHanafi}');
      return times;
    } catch (e) {
      DebugLog.info('API failed ($e) — calculating offline...');
      try {
        final times = OfflineCalculator.calculate(
          latitude: settings.latitude!,
          longitude: settings.longitude!,
          methodId: settings.apiMethod,
          isSunni: settings.fiqh == Fiqh.sunni,
          date: date,
        );
        return times;
      } catch (offlineError) {
        DebugLog.info('Offline calculation also failed: $offlineError');
        throw PrayerTimesException('Could not calculate prayer times. Please check your location settings.');
      }
    }
  }

  /// Switch to offline calculation when connectivity is lost
  void _switchToOffline(UserSettings settings) {
    if (settings.latitude == null || settings.longitude == null) return;
    try {
      final times = OfflineCalculator.calculate(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        methodId: settings.apiMethod,
        isSunni: settings.fiqh == Fiqh.sunni,
        date: DateTime.now(),
      );
      HiveService.cachePrayerTimes(times, lat: settings.latitude, lng: settings.longitude);
      NotificationService.scheduleAllPrayers(times: times, settings: settings);
      state = AsyncData(times);
    } catch (e) {
      DebugLog.info('[CONNECTIVITY] Offline calculation failed: $e');
    }
  }

  /// Fetch from AlAdhan API (with rate limit retry built in)
  Future<PrayerTimes> _fetchTimesFromApi(UserSettings settings, DateTime date) async {
    final times = await AlAdhanApi.fetchPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.apiMethod,
      school: 0,
      date: date,
    );

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
      final times = await _fetchTimesWithFallback(settings, DateTime.now());
      await HiveService.cachePrayerTimes(times, lat: settings.latitude, lng: settings.longitude);
      NotificationService.scheduleAllPrayers(times: times, settings: settings);
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
        final hasLocation = settings.latitude != null && settings.longitude != null;
        final now = hasLocation
            ? TimezoneUtil.nowAt(settings.latitude!, settings.longitude!)
            : DateTime.now();
        final next = times.nextPrayer(now);
        final parts = next.time.split(':');
        var targetHour = int.parse(parts[0]);
        var targetMinute = int.parse(parts[1]);

        var target = hasLocation
            ? TimezoneUtil.timeAt(settings.latitude!, settings.longitude!, targetHour, targetMinute)
            : DateTime(now.year, now.month, now.day, targetHour, targetMinute);

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
