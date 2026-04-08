import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../debug_log.dart';
import '../models/notification_type.dart';
import '../storage/hive_service.dart';
import 'adhan_player.dart';

const _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

@pragma('vm:entry-point')
Future<void> onAlarmFired(int alarmId) async {
  if (alarmId < 0 || alarmId >= _prayerNames.length) {
    DebugLog.info('[NOTIFY] Unknown alarm id: $alarmId');
    return;
  }

  await HiveService.init();
  final settings = HiveService.loadSettings();
  final prayerName = _prayerNames[alarmId];
  final type = settings.notificationFor(prayerName);

  DebugLog.info('[NOTIFY] Alarm fired for $prayerName — type: ${type.name}');

  if (type == NotificationType.off) return;

  if (type == NotificationType.adhan) {
    await AdhanPlayer.play(isFajr: prayerName == 'Fajr');
  }

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  final androidDetails = AndroidNotificationDetails(
    'prayer_notifications',
    'Prayer Notifications',
    channelDescription: 'Notifications for prayer times',
    importance: Importance.high,
    priority: Priority.high,
    playSound: type == NotificationType.sound,
    enableVibration:
        type == NotificationType.vibrate || type == NotificationType.sound,
    silent: type == NotificationType.silent,
  );

  await plugin.show(
    alarmId,
    'Time for $prayerName',
    'It is time to pray $prayerName',
    NotificationDetails(android: androidDetails),
  );
}
