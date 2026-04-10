import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../debug_log.dart';
import '../models/notification_type.dart';
import '../storage/hive_service.dart';
import 'adhan_player.dart';

const _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
const stopAdhanActionId = 'stop_adhan';

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

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (response) {
      if (response.actionId == stopAdhanActionId) {
        AdhanPlayer.stop();
        plugin.cancel(response.id ?? 0);
      }
    },
  );

  final actions = isAdhan
      ? <AndroidNotificationAction>[
          const AndroidNotificationAction(
            stopAdhanActionId,
            'Stop Adhan',
            showsUserInterface: false,
          ),
        ]
      : <AndroidNotificationAction>[];

  final androidDetails = AndroidNotificationDetails(
    'prayer_notifications',
    'Prayer Notifications',
    channelDescription: 'Notifications for prayer times',
    importance: Importance.high,
    priority: Priority.high,
    playSound: type == NotificationType.sound,
    enableVibration: type == NotificationType.sound,
    actions: actions,
    ongoing: isAdhan,
    autoCancel: !isAdhan,
  );

  await plugin.show(
    alarmId,
    'Time for $prayerName',
    'It is time to pray $prayerName',
    NotificationDetails(android: androidDetails),
  );

  // Start adhan AFTER showing notification (fire-and-forget)
  if (isAdhan) {
    AdhanPlayer.play(isFajr: prayerName == 'Fajr').then((_) {
      // Dismiss notification when adhan finishes
      plugin.cancel(alarmId);
    });
  }
}

/// Called when user taps "Stop Adhan" action on the notification
@pragma('vm:entry-point')
void onNotificationResponse(NotificationResponse response) {
  if (response.actionId == stopAdhanActionId) {
    AdhanPlayer.stop();
    // Dismiss the notification
    FlutterLocalNotificationsPlugin().cancel(response.id ?? 0);
  }
}
