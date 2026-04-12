## Context

Khushu currently shows prayer times and a countdown but has no way to proactively remind users when it's time to pray. The app supports timezone-aware prayer times for any location worldwide.

## Goals / Non-Goals

**Goals:**
- Notify users at each prayer time with their chosen alert type
- Per-prayer configuration (Fajr might get adhan, Dhuhr might get vibrate)
- Fajr-specific adhan audio (with "As-salatu khayrun min an-nawm")
- Work correctly for remote locations (timezone-aware)
- Persist across app restarts and device reboots
- Sound options: off, silent, vibrate, system default, custom gentle tone, adhan

**Non-Goals:**
- Prayer tracking / "mark as prayed" — future feature
- Pre-prayer reminders (e.g., 15 min before) — future feature
- Custom user-uploaded adhan audio — future feature
- iOS notifications — Android only for now

## Decisions

**1. Scheduling: `android_alarm_manager_plus`**

Use exact alarms for precise prayer time notifications. `workmanager` is designed for background tasks, not exact-time triggers. Exact alarms guarantee the notification fires at the right second.

*Alternative considered:* `flutter_local_notifications` scheduled notifications. Rejected because Android limits to 50 scheduled notifications and may batch them in Doze mode. Exact alarms are more reliable for time-critical events like prayer times.

**2. Audio: `just_audio` for adhan playback**

Play adhan audio from bundled assets when the alarm fires. Supports background playback and audio focus management (pauses other audio during adhan).

**3. Adhan source: Internet Archive Doha recordings (Public Domain)**

5 recordings covering all daily prayers including Fajr-specific adhan. Public Domain Mark 1.0 — no licensing concerns. Field recordings from Doha, Qatar (2013-2014).

**4. Per-prayer settings stored in UserSettings**

Each prayer gets a `NotificationType` enum: `off`, `silent`, `vibrate`, `sound`, `adhan`. Default: `sound` for all prayers. Stored in Hive alongside existing settings.

**5. Notification channel: single channel with per-notification customization**

One Android notification channel "Prayer Times" with importance HIGH. The alert type (sound, vibrate, etc.) is controlled per-notification, not per-channel.

**6. Re-schedule on boot and on prayer times refresh**

Register a `BOOT_COMPLETED` receiver to re-schedule notifications after device restart. Also re-schedule whenever prayer times are fetched (daily refresh or location/fiqh change).

## Risks / Trade-offs

- **[Doze mode]** Android may delay exact alarms in deep Doze. → Mitigation: use `SCHEDULE_EXACT_ALARM` permission and `setExactAndAllowWhileIdle`. On Android 12+, users must grant this permission.
- **[Audio quality]** Doha recordings are field recordings, not studio quality. → Acceptable for v1. Can add studio recordings later with proper licensing.
- **[APK size increase]** ~5-10MB for audio assets. → Acceptable — app is currently 28MB, this brings it to ~35MB.
- **[Android 13+ notification permission]** `POST_NOTIFICATIONS` requires runtime permission. → Must request on first app launch or when user enables notifications.
