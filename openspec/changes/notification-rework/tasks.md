## 1. Remove Old Packages

- [ ] 1.1 Remove `android_alarm_manager_plus`, `just_audio`, `permission_handler`, `path_provider`, `audio_session` from pubspec.yaml
- [ ] 1.2 Add `alarm` package to pubspec.yaml
- [ ] 1.3 Run `flutter pub get` — verify no errors

## 2. Clean Up Old Code

- [ ] 2.1 Delete `lib/core/notifications/alarm_callback.dart`
- [ ] 2.2 Delete `lib/core/notifications/adhan_player.dart`
- [ ] 2.3 Remove old receivers/services from `AndroidManifest.xml` (alarm_manager, flutter_local_notifications boot receiver)
- [ ] 2.4 Add `alarm` package requirements to `AndroidManifest.xml` (permissions + service)
- [ ] 2.5 Revert `MainActivity.kt` to standard `FlutterActivity` (if not already)
- [ ] 2.6 Remove `audio_service` service/receiver from manifest (if still present)

## 3. Rewrite NotificationService

- [ ] 3.1 Initialize `Alarm` in `main.dart` (replace old init)
- [ ] 3.2 Rewrite `NotificationService.scheduleAllPrayers()`:
  - For Adhan type: use `Alarm.set()` with `assetAudioPath` and `NotificationSettings(stopButton: 'Stop Adhan')`
  - For Sound type: use `flutter_local_notifications.zonedSchedule()`
  - Skip Off type and Sunrise
- [ ] 3.3 Rewrite `NotificationService.cancelAll()` — use `Alarm.stopAll()` + cancel flutter_local_notifications
- [ ] 3.4 Rewrite `NotificationService.fireTestNotification()`:
  - For Adhan: use `Alarm.set()` with dateTime 2 seconds from now
  - For Sound: use `flutter_local_notifications.show()` immediately
- [ ] 3.5 Listen to `Alarm.ringStream` in main.dart or notification service for cleanup after adhan finishes

## 4. Update AndroidManifest.xml

- [ ] 4.1 Add alarm package permissions: FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PLAYBACK, ACCESS_NOTIFICATION_POLICY
- [ ] 4.2 Add alarm package service: `com.gdelataillade.alarm.services.NotificationOnKillService`
- [ ] 4.3 Keep existing permissions: SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE, WAKE_LOCK, USE_FULL_SCREEN_INTENT
- [ ] 4.4 Remove old alarm_manager receivers/services

## 5. Testing Infrastructure

- [ ] 5.1 Update test button to use `Alarm.set()` with dateTime 3 seconds from now (gives time to lock screen)
- [ ] 5.2 Add a "Test in 30s" button — schedules adhan for 30 seconds from now so user can lock screen and wait
- [ ] 5.3 Add "Test Sound" button — fires a Sound-type notification immediately
- [ ] 5.4 Add debug overlay on notification settings page showing: next scheduled alarm, alarm package status, last fired alarm

## 6. Automated Tests

- [ ] 6.1 Unit test: `NotificationService.scheduleAllPrayers()` creates correct number of alarms (skip off, skip past, skip Sunrise)
- [ ] 6.2 Unit test: notification type mapping — Adhan uses `Alarm.set()`, Sound uses `flutter_local_notifications`
- [ ] 6.3 Unit test: test button fires immediately without crashing
- [ ] 6.4 Run all existing tests — verify no regressions

## 7. Manual Test Checklist (Release Build)

- [ ] 7.1 Test adhan with screen unlocked — verify plays + Stop button works
- [ ] 7.2 Test adhan with screen locked — verify plays + Stop works from lock screen
- [ ] 7.3 Test "Test in 30s" — lock screen, wait, verify adhan fires over lock screen
- [ ] 7.4 Test Sound notification — verify system ping, no adhan audio
- [ ] 7.5 Kill app (swipe away) → wait for scheduled alarm → verify adhan still fires
- [ ] 7.6 Adhan auto-stops when audio finishes — notification dismisses
- [ ] 7.7 Test with remote location (timezone-aware scheduling still works)
- [ ] 7.8 Reboot phone → verify scheduled alarms persist
