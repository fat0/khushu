## Why

Prayer apps without notifications are just clocks. Users need to be reminded when it's time to pray — especially when busy, traveling, or in a different timezone. This is the #1 feature that keeps users engaged with a prayer app.

## What Changes

- Push notifications at each prayer time with configurable alert type per prayer
- Adhan audio playback option using public domain recordings (Internet Archive Doha set)
- Fajr-specific adhan with "As-salatu khayrun min an-nawm"
- Per-prayer configuration: off, silent, vibrate, notification sound, or adhan
- Timezone-aware scheduling — notifications fire at the correct time for the selected location
- Notification settings screen integrated into existing Settings
- Background scheduling that persists across app restarts

## Capabilities

### New Capabilities
- `notification-scheduling`: Background service that schedules and fires prayer time notifications, timezone-aware, persists across restarts
- `adhan-audio`: Bundled adhan audio assets (Internet Archive Doha public domain set) with playback at prayer time
- `notification-settings`: Per-prayer notification configuration UI (off/silent/vibrate/sound/adhan)

### Modified Capabilities

## Impact

- New Flutter packages: `flutter_local_notifications`, `android_alarm_manager_plus` or `workmanager`
- New audio assets: adhan recordings (~5-10MB total)
- `lib/features/settings/settings_screen.dart` — add notification settings section
- `lib/core/models/user_settings.dart` — add per-prayer notification preferences
- Android permissions: `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`
- `AndroidManifest.xml` — new permissions and broadcast receivers
