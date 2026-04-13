import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/aladhan_api.dart';
import '../../core/debug_log.dart';
import '../../core/location/location_service.dart';
import '../../core/location/region_detector.dart';
import '../../core/location/timezone_util.dart';
import '../../core/theme/app_colors.dart';
import '../qibla/widgets/qibla_button.dart';
import '../settings/settings_provider.dart';
import 'prayer_times_provider.dart';
import 'widgets/dome_header.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_times_list.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  bool _checkedLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocation());
  }

  Future<void> _checkLocation() async {
    if (_checkedLocation) return;
    _checkedLocation = true;
    final settings = ref.read(settingsProvider);
    if (settings.latitude != null && settings.longitude != null) {
      DebugLog.gps('Location already set: ${settings.locationName}');
      return;
    }

    // Request location permission explicitly
    DebugLog.gps('First launch: requesting location permission...');
    final permission = await Geolocator.requestPermission();
    DebugLog.gps('Location permission: $permission');

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      DebugLog.gpsWarning('Location permission denied — showing city dialog');
      if (mounted) _showLocationDialog();
      return;
    }

    // Permission granted — try GPS
    DebugLog.gps('Trying GPS...');
    final result = await LocationService.getCurrentLocation();

    if (result != null && mounted) {
      DebugLog.gps('GPS success: ${result.name}');
      final methodId = RegionDetector.detectMethod(result.latitude, result.longitude);
      final notifier = ref.read(settingsProvider.notifier);
      await notifier.setLocation(result.latitude, result.longitude, result.name);
      await notifier.setMethodId(methodId);
      return;
    }

    // GPS failed — show fallback dialog
    if (mounted) {
      DebugLog.gpsWarning('GPS failed, showing location dialog');
      _showLocationDialog();
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LocationDialog(
        onLocationSet: (result) {
          final methodId = RegionDetector.detectMethod(result.latitude, result.longitude);
          final notifier = ref.read(settingsProvider.notifier);
          notifier.setLocation(result.latitude, result.longitude, result.name);
          notifier.setMethodId(methodId);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final timesAsync = ref.watch(prayerTimesProvider);
    final countdownAsync = ref.watch(countdownProvider);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: timesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Could not load prayer times',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error is PrayerTimesException
                            ? error.message
                            : 'Please check your internet connection and try again.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(prayerTimesProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (times) {
                final now = (settings.latitude != null && settings.longitude != null)
                    ? TimezoneUtil.nowAt(settings.latitude!, settings.longitude!)
                    : DateTime.now();
                final currentPrayer = times.currentPrayer(now);
                final nextPrayer = times.nextPrayer(now);
                final currentName = currentPrayer?.name ?? '';

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      DomeHeader(
                        locationName: settings.locationName ?? 'Unknown',
                        latitude: settings.latitude,
                        longitude: settings.longitude,
                        isOffline: times.isOffline,
                      ),
                      const SizedBox(height: 8),
                      countdownAsync.when(
                        data: (countdown) => NextPrayerCard(
                          currentPrayerName: currentName,
                          nextPrayerName: nextPrayer.name,
                          countdown: countdown,
                        ),
                        loading: () => NextPrayerCard(
                          currentPrayerName: currentName,
                          nextPrayerName: nextPrayer.name,
                          countdown: Duration.zero,
                        ),
                        error: (_, __) => NextPrayerCard(
                          currentPrayerName: currentName,
                          nextPrayerName: nextPrayer.name,
                          countdown: Duration.zero,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrayerTimesList(
                        prayerTimes: times,
                        currentPrayerName: currentName,
                        fiqh: settings.fiqh,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Qibla button — bottom-left
          Positioned(
            left: 16,
            bottom: 0,
            child: SafeArea(
              child: QiblaButton(onPressed: () => context.push('/qibla')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push('/settings'),
        backgroundColor: AppColors.sage,
        child: const Icon(Icons.settings, color: AppColors.cream, size: 20),
      ),
    );
  }
}

class _LocationDialog extends StatefulWidget {
  final void Function(LocationResult result) onLocationSet;

  const _LocationDialog({required this.onLocationSet});

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  final _controller = TextEditingController();
  bool _searching = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _error = null;
    });

    final result = await LocationService.searchCity(query);

    if (!mounted) return;

    if (result != null) {
      widget.onLocationSet(result);
    } else {
      setState(() {
        _searching = false;
        _error = 'Could not find "$query". Try another city name.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Set Your Location',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.sage : AppColors.deepGreen,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'We need your location to calculate accurate prayer times for your area.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_searching,
            decoration: InputDecoration(
              hintText: 'Enter your city...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ),
        ],
      ),
      actions: [
        _searching
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage,
                  foregroundColor: AppColors.cream,
                ),
                child: const Text('Find'),
              ),
      ],
    );
  }
}
