## Why

The current notification system uses `android_alarm_manager_plus` + `just_audio` + `flutter_local_notifications`. This has fundamental flaws:
- Alarm callback runs in a background isolate where audio playback fails when screen is locked
- Stop button can't reach the audio player (cross-isolate)
- Full-screen intent doesn't trigger reliably
- Multiple packages fighting each other with conflicting lifecycle management

The `alarm` package solves all of these in one integrated solution — foreground service, audio playback, stop button, and lock screen display.

## What Changes

- Replace `android_alarm_manager_plus`, `just_audio`, `flutter_local_notifications`, `permission_handler`, `path_provider`, `audio_session` with the `alarm` package
- Rewrite `NotificationService` to use `Alarm.set()` for scheduling
- Remove `AdhanPlayer` — `alarm` handles audio playback internally
- Remove `alarm_callback.dart` — no more background isolate callbacks
- Simplify `AndroidManifest.xml` — remove old receivers/services, add alarm-specific ones
- Keep `flutter_local_notifications` only for "Sound" type (non-adhan system notification)

## Capabilities

### Modified Capabilities
- `notification-scheduling`: Replace android_alarm_manager with alarm package
- `adhan-audio`: Replace just_audio with alarm package's built-in audio

### New Capabilities

## Impact

- Remove packages: `android_alarm_manager_plus`, `just_audio`, `permission_handler`, `path_provider`, `audio_session`
- Add package: `alarm`
- Delete: `lib/core/notifications/alarm_callback.dart`, `lib/core/notifications/adhan_player.dart`
- Rewrite: `lib/core/notifications/notification_service.dart`
- Update: `AndroidManifest.xml`, `pubspec.yaml`, `main.dart`
- Keep: `notification_settings_screen.dart`, `notification_type.dart`, `user_settings.dart` (no changes)
