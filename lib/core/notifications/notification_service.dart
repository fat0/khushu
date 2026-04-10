import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../debug_log.dart';
import '../location/timezone_util.dart';
import '../models/notification_type.dart';
import '../models/prayer_times.dart';
import '../models/user_settings.dart';
import 'adhan_player.dart';
import 'alarm_callback.dart';

class NotificationService {
  static const _prayerIds = {
    'Fajr': 0,
    'Dhuhr': 1,
    'Asr': 2,
    'Maghrib': 3,
    'Isha': 4,
  };

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        AdhanPlayer.stop();
        plugin.cancel(response.id ?? 0);
        DebugLog.info('[NOTIFY] Notification tapped — stopping adhan');
      },
    );

    // Create the notification channel
    final androidPlugin =
        plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_notifications',
          'Prayer Notifications',
          description: 'Notifications for prayer times',
          importance: Importance.high,
        ),
      );
    }

    DebugLog.info('[NOTIFY] NotificationService initialized');
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    DebugLog.info('[NOTIFY] Permission status: ${status.name}');
    return status.isGranted;
  }

  static Future<void> scheduleAllPrayers({
    required PrayerTimes times,
    required UserSettings settings,
  }) async {
    await cancelAll();

    final lat = settings.latitude;
    final lng = settings.longitude;
    if (lat == null || lng == null) {
      DebugLog.info('[NOTIFY] No location set — skipping schedule');
      return;
    }

    final now = TimezoneUtil.nowAt(lat, lng);

    final prayerTimeStrings = {
      'Fajr': times.fajr,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    };

    for (final entry in prayerTimeStrings.entries) {
      final name = entry.key;
      final timeStr = entry.value;
      final alarmId = _prayerIds[name]!;

      final type = settings.notificationFor(name);
      if (type == NotificationType.off) {
        DebugLog.info('[NOTIFY] $name is off — skipping');
        continue;
      }

      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final scheduledTime = TimezoneUtil.timeAt(lat, lng, hour, minute);

      if (scheduledTime.isBefore(now)) {
        DebugLog.info('[NOTIFY] $name ($timeStr) already passed — skipping');
        continue;
      }

      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        onAlarmFired,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
      );

      DebugLog.info('[NOTIFY] Scheduled $name at $timeStr (id=$alarmId)');
    }
  }

  /// Fire a test notification immediately using the first non-off prayer's type
  static Future<void> fireTestNotification(UserSettings settings) async {
    const testPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    var testPrayer = 'Dhuhr';
    var testType = NotificationType.sound;

    for (final p in testPrayers) {
      final t = settings.notificationFor(p);
      if (t != NotificationType.off) {
        testPrayer = p;
        testType = t;
        break;
      }
    }

    DebugLog.info('[NOTIFY] Test firing: $testPrayer as ${testType.name}');

    // Directly call the alarm callback with a test ID
    await onAlarmFired(_prayerIds[testPrayer]!);
  }

  static Future<void> cancelAll() async {
    for (final id in _prayerIds.values) {
      await AndroidAlarmManager.cancel(id);
    }
    DebugLog.info('[NOTIFY] All alarms cancelled');
  }
}
