## Context

Khushu's notification system was built with `android_alarm_manager_plus` (scheduling) + `just_audio` (audio) + `flutter_local_notifications` (notifications). This three-package approach has a fundamental flaw: the alarm fires in a background isolate where audio playback fails when the screen is locked, and the stop button runs in the main isolate which can't reach the player.

## Goals / Non-Goals

**Goals:**
- Adhan plays at exact prayer time even when screen is locked and app is killed
- Stop button on notification works from lock screen without unlocking
- Clean single-package solution — no cross-isolate hacks
- Keep existing per-prayer settings (Off/Sound/Adhan)
- Keep existing test button in notification settings

**Non-Goals:**
- Custom adhan selection (future feature)
- Pre-prayer reminders (future feature)

## Decisions

**1. Use the `alarm` package for adhan notifications**

The `alarm` package (pub.dev/packages/alarm) provides an integrated solution:
- Foreground service keeps the process alive for audio playback
- Built-in audio playback from assets
- Stop button on notification (`NotificationSettings.stopButton`)
- Full-screen intent for lock screen display
- Survives app being killed
- One package replaces three

**2. Keep `flutter_local_notifications` for "Sound" type only**

When a prayer is set to "Sound" (not adhan), we still need a simple system notification ping. `flutter_local_notifications` handles this well and doesn't need background audio or foreground services.

**3. Two notification paths**

- **Adhan:** `Alarm.set()` → foreground service → audio plays → stop button works → auto-dismiss when done
- **Sound:** `flutter_local_notifications.show()` → system ping → auto-dismiss

**4. Scheduling: `alarm` package for adhan, `flutter_local_notifications` scheduled notifications for sound**

The `alarm` package handles exact scheduling internally. For "Sound" type, we use `flutter_local_notifications.zonedSchedule()` which is simpler than `android_alarm_manager_plus`.

**5. Remove old packages**

Delete: `android_alarm_manager_plus`, `just_audio`, `permission_handler`, `path_provider`, `audio_session`
Delete files: `alarm_callback.dart`, `adhan_player.dart`
Clean up: `AndroidManifest.xml` — remove old receivers/services

## Risks / Trade-offs

- **[OEM battery killers]** Samsung, Xiaomi, etc. may still kill the foreground service. → Mitigation: link to dontkillmyapp.com in settings
- **[Play Store USE_FULL_SCREEN_INTENT]** Google restricts this permission. → Prayer/alarm apps qualify — include justification in Play Store listing
- **[Migration]** Users with saved notification settings won't be affected — the `NotificationType` enum and `UserSettings` stay the same
