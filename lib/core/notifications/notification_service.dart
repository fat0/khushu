import 'package:alarm/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../debug_log.dart';
import '../location/timezone_util.dart';
import '../models/notification_type.dart';
import '../models/prayer_times.dart';
import '../models/user_settings.dart';

class NotificationService {
  static const _prayerIds = {
    'Fajr': 1,
    'Dhuhr': 2,
    'Asr': 3,
    'Maghrib': 4,
    'Isha': 5,
  };

  // IDs 10+ for sound-type notifications
  static const _soundIdOffset = 10;

  static final _notifPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize alarm package
    await Alarm.init();

    // Initialize flutter_local_notifications (for Sound type only)
    await _notifPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Create notification channel for Sound type
    final androidPlugin = _notifPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'prayer_sound',
          'Prayer Reminders',
          description: 'Prayer time sound notifications',
          importance: Importance.high,
        ),
      );
    }

    DebugLog.info('[NOTIFY] NotificationService initialized (alarm + local_notifications)');
  }

  /// Schedule notifications for all prayers that haven't passed yet today.
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

      if (type == NotificationType.adhan) {
        await _scheduleAdhan(
          id: alarmId,
          prayerName: name,
          dateTime: scheduledTime,
          isFajr: name == 'Fajr',
        );
      } else {
        await _scheduleSound(
          id: alarmId + _soundIdOffset,
          prayerName: name,
          dateTime: scheduledTime,
        );
      }
    }
  }

  static Future<void> _scheduleAdhan({
    required int id,
    required String prayerName,
    required DateTime dateTime,
    required bool isFajr,
  }) async {
    final asset = isFajr
        ? 'assets/audio/adhan_fajr.ogg'
        : 'assets/audio/adhan_standard.ogg';

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: asset,
      loopAudio: false,
      vibrate: false,
      volumeSettings: const VolumeSettings.fixed(volume: 1.0),
      androidFullScreenIntent: false,
      warningNotificationOnKill: false,
      androidStopAlarmOnTermination: false,
      notificationSettings: NotificationSettings(
        title: 'Time for $prayerName',
        body: '',
        stopButton: 'Stop Adhan',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    DebugLog.info('[NOTIFY] Scheduled ADHAN for $prayerName at ${dateTime.hour}:${dateTime.minute} (id=$id)');
  }

  static Future<void> _scheduleSound({
    required int id,
    required String prayerName,
    required DateTime dateTime,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_sound',
      'Prayer Reminders',
      channelDescription: 'Prayer time sound notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifPlugin.zonedSchedule(
      id,
      'Time for $prayerName',
      'It is time to pray $prayerName',
      tz.TZDateTime.from(dateTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    DebugLog.info('[NOTIFY] Scheduled SOUND for $prayerName at ${dateTime.hour}:${dateTime.minute} (id=$id)');
  }

  static Future<void> cancelAll() async {
    // Cancel all alarm-package alarms
    await Alarm.stopAll();
    // Cancel all flutter_local_notifications
    await _notifPlugin.cancelAll();
    DebugLog.info('[NOTIFY] All alarms cancelled');
  }

}
