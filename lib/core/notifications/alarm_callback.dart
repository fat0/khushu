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

  final isAdhan = type == NotificationType.adhan;

  // Show notification
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (response) {
      DebugLog.info('[NOTIFY] Notification tapped — stopping adhan');
      AdhanPlayer.stop();
      plugin.cancel(response.id ?? 0);
    },
  );

  final androidDetails = AndroidNotificationDetails(
    'prayer_notifications',
    'Prayer Notifications',
    channelDescription: 'Notifications for prayer times',
    importance: Importance.high,
    priority: Priority.high,
    playSound: !isAdhan,
    enableVibration: !isAdhan,
    ongoing: isAdhan,
    autoCancel: true,
  );

  await plugin.show(
    alarmId,
    isAdhan ? 'Adhan — $prayerName' : 'Time for $prayerName',
    isAdhan ? 'Tap to stop adhan' : 'It is time to pray $prayerName',
    NotificationDetails(android: androidDetails),
  );

  DebugLog.info('[NOTIFY] Notification shown for $prayerName');

  // Play adhan after showing notification
  if (isAdhan) {
    await AdhanPlayer.play(isFajr: prayerName == 'Fajr');
    AdhanPlayer.waitForCompletion().then((_) {
      plugin.cancel(alarmId);
      DebugLog.info('[NOTIFY] Adhan done, notification dismissed');
    });
  }
}
