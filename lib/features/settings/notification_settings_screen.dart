import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/notification_type.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_colors.dart';
import 'settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: theme.textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: _prayers.map((prayer) {
          final type = settings.notificationFor(prayer);
          return _PrayerNotificationTile(
            prayer: prayer,
            type: type,
            isDark: isDark,
            onChanged: (newType) async {
              if (newType != NotificationType.off) {
                await NotificationService.requestPermission();
              }
              ref.read(settingsProvider.notifier).setNotificationType(prayer, newType);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _PrayerNotificationTile extends StatelessWidget {
  final String prayer;
  final NotificationType type;
  final bool isDark;
  final ValueChanged<NotificationType> onChanged;

  const _PrayerNotificationTile({
    required this.prayer,
    required this.type,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              prayer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.sage : AppColors.deepGreen,
              ),
            ),
            const Spacer(),
            SegmentedButton<NotificationType>(
              segments: const [
                ButtonSegment(value: NotificationType.off, label: Text('Off')),
                ButtonSegment(value: NotificationType.sound, label: Text('Sound')),
                ButtonSegment(value: NotificationType.adhan, label: Text('Adhan')),
              ],
              selected: {type},
              onSelectionChanged: (selected) => onChanged(selected.first),
              showSelectedIcon: false,
              style: ButtonStyle(
                textStyle: WidgetStatePropertyAll(
                  const TextStyle(fontSize: 12),
                ),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStatePropertyAll(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.sage;
                  }
                  return isDark ? AppColors.darkBackground : AppColors.cream;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.cream;
                  }
                  return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
                }),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: isDark ? AppColors.darkSecondary.withValues(alpha: 0.3) : AppColors.lightSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
