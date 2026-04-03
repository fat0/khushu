import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_provider.dart';
import 'prayer_times_provider.dart';
import 'widgets/dome_header.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_times_list.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final timesAsync = ref.watch(prayerTimesProvider);
    final countdownAsync = ref.watch(countdownProvider);

    return Scaffold(
      body: SafeArea(
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
                    error.toString(),
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
            final nextPrayer = times.nextPrayer(DateTime.now());
            final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

            return SingleChildScrollView(
              child: Column(
                children: [
                  DomeHeader(
                    locationName: settings.locationName ?? 'Unknown',
                    date: dateStr,
                  ),
                  const SizedBox(height: 8),
                  countdownAsync.when(
                    data: (countdown) => NextPrayerCard(
                      prayerName: nextPrayer.name,
                      countdown: countdown,
                    ),
                    loading: () => NextPrayerCard(
                      prayerName: nextPrayer.name,
                      countdown: Duration.zero,
                    ),
                    error: (_, __) => NextPrayerCard(
                      prayerName: nextPrayer.name,
                      countdown: Duration.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrayerTimesList(
                    prayerTimes: times,
                    combinePrayers: settings.combinePrayers,
                    nextPrayerName: nextPrayer.name,
                  ),
                  const SizedBox(height: 16),
                  // Combine prayers toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Combine prayers',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Switch(
                          value: settings.combinePrayers,
                          activeColor: AppColors.sage,
                          onChanged: (value) {
                            ref.read(settingsProvider.notifier).setCombinePrayers(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push('/settings'),
        backgroundColor: AppColors.sage,
        child: const Icon(Icons.settings, color: AppColors.cream, size: 20),
      ),
    );
  }
}
