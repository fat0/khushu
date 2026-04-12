## 1. Audio Assets

- [ ] 1.1 Download Doha adhan recordings from Internet Archive (all 5 prayers including Fajr)
- [ ] 1.2 Convert to appropriate format (MP3/OGG) and optimize file size
- [ ] 1.3 Add audio files to `assets/audio/` and register in `pubspec.yaml`
- [ ] 1.4 Create or source a gentle notification tone asset

## 2. Data Model

- [ ] 2.1 Add `NotificationType` enum: off, silent, vibrate, sound, adhan
- [ ] 2.2 Add per-prayer notification settings to `UserSettings` (Map of prayer name → NotificationType)
- [ ] 2.3 Add sound preference to `UserSettings` (system default vs gentle tone)
- [ ] 2.4 Update Hive serialization for new settings fields
- [ ] 2.5 Write unit tests for notification settings model

## 3. Notification Scheduling

- [ ] 3.1 Add `flutter_local_notifications` and `android_alarm_manager_plus` packages
- [ ] 3.2 Create `NotificationService` — initialize channels, request permissions
- [ ] 3.3 Implement `scheduleAllPrayers()` — schedule exact alarms for today's remaining prayers using location timezone
- [ ] 3.4 Implement alarm callback — fire notification with correct type (silent/vibrate/sound/adhan)
- [ ] 3.5 Add `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` permissions to AndroidManifest
- [ ] 3.6 Create boot receiver to re-schedule notifications on device restart
- [ ] 3.7 Re-schedule notifications when prayer times refresh (location/fiqh/method change)
- [ ] 3.8 Skip Sunrise — no notification for Sunrise

## 4. Adhan Playback

- [ ] 4.1 Add `just_audio` package
- [ ] 4.2 Implement adhan playback from assets — standard and Fajr-specific
- [ ] 4.3 Handle audio focus (pause other audio during adhan)
- [ ] 4.4 Respect system volume (no audio on silent/vibrate mode)

## 5. Settings UI

- [ ] 5.1 Add "Notifications" section to settings screen
- [ ] 5.2 Show each prayer with current notification type
- [ ] 5.3 Tap prayer → picker dialog with notification type options
- [ ] 5.4 Add sound preference toggle (system default vs gentle tone)
- [ ] 5.5 Request POST_NOTIFICATIONS permission on Android 13+ when first notification enabled

## 6. Integration

- [ ] 6.1 Initialize NotificationService in main.dart
- [ ] 6.2 Schedule notifications after prayer times load in provider
- [ ] 6.3 Cancel and re-schedule on settings changes

## 7. Testing

- [ ] 7.1 Unit tests for NotificationType model and serialization
- [ ] 7.2 Unit tests for notification scheduling logic (timezone, skip past prayers, skip Sunrise)
- [ ] 7.3 Deploy to phone and test: set Fajr to adhan, Dhuhr to vibrate — verify both work
- [ ] 7.4 Test with remote location — verify notifications fire at correct timezone
- [ ] 7.5 Reboot phone — verify notifications persist
