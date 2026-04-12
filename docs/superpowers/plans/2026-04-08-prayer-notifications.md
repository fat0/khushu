# Prayer Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add timezone-aware prayer notifications with per-prayer configuration and adhan audio playback.

**Architecture:** Exact alarms via `android_alarm_manager_plus` trigger at each prayer time. A `NotificationService` handles scheduling, cancellation, and re-scheduling. `just_audio` plays adhan from bundled assets. Per-prayer settings stored in `UserSettings` via Hive.

**Tech Stack:** Flutter, android_alarm_manager_plus, flutter_local_notifications, just_audio, timezone

---

## File Structure

| File | Responsibility |
|------|---------------|
| **Create:** `lib/core/models/notification_type.dart` | `NotificationType` enum and `SoundPreference` enum |
| **Create:** `lib/core/notifications/notification_service.dart` | Initialize channels, schedule/cancel alarms, fire notifications |
| **Create:** `lib/core/notifications/adhan_player.dart` | Play adhan audio from assets (standard + Fajr) |
| **Create:** `lib/core/notifications/alarm_callback.dart` | Top-level function called by alarm manager |
| **Modify:** `lib/core/models/user_settings.dart` | Add per-prayer notification prefs + sound preference |
| **Modify:** `lib/core/storage/hive_service.dart` | Serialize new settings fields |
| **Modify:** `lib/features/settings/settings_screen.dart` | Add Notifications section with per-prayer picker |
| **Modify:** `lib/features/settings/settings_provider.dart` | Add setNotificationType() and setSoundPreference() |
| **Modify:** `lib/features/prayer_times/prayer_times_provider.dart` | Trigger notification scheduling after prayer times load |
| **Modify:** `lib/main.dart` | Initialize NotificationService |
| **Modify:** `android/app/src/main/AndroidManifest.xml` | Add permissions and boot receiver |
| **Modify:** `pubspec.yaml` | Add packages and audio assets |
| **Create:** `assets/audio/adhan_standard.mp3` | Standard adhan (Doha, Public Domain) |
| **Create:** `assets/audio/adhan_fajr.mp3` | Fajr-specific adhan (Doha, Public Domain) |
| **Create:** `assets/audio/gentle_tone.mp3` | Custom gentle notification tone |
| **Create:** `test/core/models/notification_type_test.dart` | Tests for notification model |
| **Create:** `test/core/notifications/notification_service_test.dart` | Tests for scheduling logic |

---

### Task 0: Add packages and audio assets

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `assets/audio/` directory with audio files

- [ ] **Step 1: Add Flutter packages**

```bash
fvm flutter pub add flutter_local_notifications android_alarm_manager_plus just_audio
```

- [ ] **Step 2: Register audio assets in pubspec.yaml**

Add to the `flutter.assets` section in `pubspec.yaml`:

```yaml
  assets:
    - assets/images/
    - assets/audio/
```

- [ ] **Step 3: Download adhan audio from Internet Archive**

```bash
mkdir -p assets/audio
# Download Doha recordings (Public Domain Mark 1.0)
curl -L "https://archive.org/download/adhan.recordings.from.doha.qatar/Fajr%20Adhan.ogg" -o assets/audio/adhan_fajr_raw.ogg
curl -L "https://archive.org/download/adhan.recordings.from.doha.qatar/Dhuhr%20Adhan.ogg" -o assets/audio/adhan_standard_raw.ogg
```

Convert to MP3 and normalize:
```bash
ffmpeg -i assets/audio/adhan_fajr_raw.ogg -b:a 128k assets/audio/adhan_fajr.mp3
ffmpeg -i assets/audio/adhan_standard_raw.ogg -b:a 128k assets/audio/adhan_standard.mp3
rm assets/audio/*_raw.ogg
```

- [ ] **Step 4: Create a gentle notification tone**

Use `ffmpeg` to generate a soft chime (or download a CC0 tone from Freesound):
```bash
# Option A: Generate a simple sine wave chime
ffmpeg -f lavfi -i "sine=frequency=528:duration=2" -af "afade=t=in:st=0:d=0.3,afade=t=out:st=1.5:d=0.5" assets/audio/gentle_tone.mp3
```

- [ ] **Step 5: Add Android permissions to AndroidManifest.xml**

Add these permissions before `<application>` in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

Add boot receiver inside `<application>` after `</activity>`:

```xml
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
    </intent-filter>
</receiver>
<receiver
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
    android:exported="false" />
```

- [ ] **Step 6: Run `flutter pub get` and verify no errors**

```bash
fvm flutter pub get
fvm flutter analyze
```

Expected: No errors.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/audio/ android/app/src/main/AndroidManifest.xml
git commit -m "feat: add notification packages, audio assets, and Android permissions"
```

---

### Task 1: NotificationType model and UserSettings update

**Files:**
- Create: `lib/core/models/notification_type.dart`
- Modify: `lib/core/models/user_settings.dart`
- Create: `test/core/models/notification_type_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/models/notification_type_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/notification_type.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('NotificationType', () {
    test('has all expected values', () {
      expect(NotificationType.values.length, 5);
      expect(NotificationType.values, contains(NotificationType.off));
      expect(NotificationType.values, contains(NotificationType.silent));
      expect(NotificationType.values, contains(NotificationType.vibrate));
      expect(NotificationType.values, contains(NotificationType.sound));
      expect(NotificationType.values, contains(NotificationType.adhan));
    });
  });

  group('SoundPreference', () {
    test('has system and gentle options', () {
      expect(SoundPreference.values.length, 2);
      expect(SoundPreference.values, contains(SoundPreference.system));
      expect(SoundPreference.values, contains(SoundPreference.gentle));
    });
  });

  group('UserSettings with notifications', () {
    test('defaults all prayers to sound', () {
      const settings = UserSettings();
      expect(settings.notificationFor('Fajr'), NotificationType.sound);
      expect(settings.notificationFor('Dhuhr'), NotificationType.sound);
      expect(settings.notificationFor('Asr'), NotificationType.sound);
      expect(settings.notificationFor('Maghrib'), NotificationType.sound);
      expect(settings.notificationFor('Isha'), NotificationType.sound);
    });

    test('defaults sound preference to system', () {
      const settings = UserSettings();
      expect(settings.soundPreference, SoundPreference.system);
    });

    test('serializes and deserializes notification settings', () {
      final settings = const UserSettings().copyWith(
        notificationTypes: {'Fajr': NotificationType.adhan, 'Dhuhr': NotificationType.vibrate},
        soundPreference: SoundPreference.gentle,
      );
      final json = settings.toJson();
      final restored = UserSettings.fromJson(json);
      expect(restored.notificationFor('Fajr'), NotificationType.adhan);
      expect(restored.notificationFor('Dhuhr'), NotificationType.vibrate);
      expect(restored.notificationFor('Asr'), NotificationType.sound);
      expect(restored.soundPreference, SoundPreference.gentle);
    });

    test('Sunrise returns off and cannot be changed', () {
      const settings = UserSettings();
      expect(settings.notificationFor('Sunrise'), NotificationType.off);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
fvm flutter test test/core/models/notification_type_test.dart
```

Expected: FAIL — `notification_type.dart` doesn't exist.

- [ ] **Step 3: Create NotificationType enum**

Create `lib/core/models/notification_type.dart`:

```dart
enum NotificationType {
  off,
  silent,
  vibrate,
  sound,
  adhan,
}

enum SoundPreference {
  system,
  gentle,
}
```

- [ ] **Step 4: Update UserSettings with notification fields**

Modify `lib/core/models/user_settings.dart`:

```dart
import 'notification_type.dart';

enum Fiqh {
  sunni,
  jafari,
}

class UserSettings {
  final Fiqh fiqh;
  final int? methodId;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool onboardingComplete;
  final Map<String, NotificationType> notificationTypes;
  final SoundPreference soundPreference;

  static const _defaultNotificationType = NotificationType.sound;
  static const _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  const UserSettings({
    this.fiqh = Fiqh.sunni,
    this.methodId,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
    this.notificationTypes = const {},
    this.soundPreference = SoundPreference.system,
  });

  NotificationType notificationFor(String prayerName) {
    if (prayerName == 'Sunrise') return NotificationType.off;
    return notificationTypes[prayerName] ?? _defaultNotificationType;
  }

  int get apiMethod {
    if (fiqh == Fiqh.jafari) return 0;
    return methodId ?? 3;
  }

  UserSettings copyWith({
    Fiqh? fiqh,
    int? methodId,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? onboardingComplete,
    Map<String, NotificationType>? notificationTypes,
    SoundPreference? soundPreference,
  }) {
    return UserSettings(
      fiqh: fiqh ?? this.fiqh,
      methodId: methodId ?? this.methodId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      soundPreference: soundPreference ?? this.soundPreference,
    );
  }

  Map<String, dynamic> toJson() => {
        'fiqh': fiqh.index,
        'methodId': methodId,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
        'notificationTypes': notificationTypes.map(
          (k, v) => MapEntry(k, v.index),
        ),
        'soundPreference': soundPreference.index,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final fiqhIndex = json['fiqh'] as int? ?? 0;
    final fiqh = fiqhIndex >= 2 ? Fiqh.jafari : Fiqh.sunni;

    final rawNotifications = json['notificationTypes'] as Map?;
    final notificationTypes = <String, NotificationType>{};
    if (rawNotifications != null) {
      for (final entry in rawNotifications.entries) {
        final index = entry.value as int;
        if (index >= 0 && index < NotificationType.values.length) {
          notificationTypes[entry.key as String] = NotificationType.values[index];
        }
      }
    }

    final soundIndex = json['soundPreference'] as int? ?? 0;
    final soundPreference = soundIndex >= 0 && soundIndex < SoundPreference.values.length
        ? SoundPreference.values[soundIndex]
        : SoundPreference.system;

    return UserSettings(
      fiqh: fiqh,
      methodId: json['methodId'] as int?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['locationName'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      notificationTypes: notificationTypes,
      soundPreference: soundPreference,
    );
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
fvm flutter test test/core/models/notification_type_test.dart
```

Expected: ALL PASS

- [ ] **Step 6: Run all existing tests for regressions**

```bash
fvm flutter test
```

Expected: ALL PASS (existing user_settings_test.dart should still work — new fields have defaults).

- [ ] **Step 7: Commit**

```bash
git add lib/core/models/notification_type.dart lib/core/models/user_settings.dart test/core/models/notification_type_test.dart
git commit -m "feat: add NotificationType model and per-prayer settings to UserSettings"
```

---

### Task 2: NotificationService — initialize and schedule

**Files:**
- Create: `lib/core/notifications/notification_service.dart`
- Create: `lib/core/notifications/alarm_callback.dart`

- [ ] **Step 1: Create alarm_callback.dart**

This must be a top-level function (not a class method) for `android_alarm_manager_plus`:

Create `lib/core/notifications/alarm_callback.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_type.dart';
import '../models/user_settings.dart';
import '../storage/hive_service.dart';
import 'adhan_player.dart';

/// Top-level function — called by android_alarm_manager when alarm fires.
/// The alarmId encodes the prayer: 0=Fajr, 1=Dhuhr, 2=Asr, 3=Maghrib, 4=Isha
@pragma('vm:entry-point')
Future<void> onAlarmFired(int alarmId) async {
  await Hive.initFlutter();
  await Hive.openBox('settings');

  final settings = HiveService.loadSettings();
  final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  if (alarmId < 0 || alarmId >= prayerNames.length) return;

  final prayerName = prayerNames[alarmId];
  final notifType = settings.notificationFor(prayerName);

  if (notifType == NotificationType.off) return;

  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  if (notifType == NotificationType.adhan) {
    await AdhanPlayer.play(isFajr: prayerName == 'Fajr');
  }

  final androidDetails = AndroidNotificationDetails(
    'prayer_times',
    'Prayer Times',
    channelDescription: 'Prayer time notifications',
    importance: Importance.high,
    priority: Priority.high,
    playSound: notifType == NotificationType.sound,
    enableVibration: notifType == NotificationType.vibrate || notifType == NotificationType.sound,
    silent: notifType == NotificationType.silent,
  );

  await plugin.show(
    alarmId,
    'Time for $prayerName',
    'It is time to pray $prayerName',
    NotificationDetails(android: androidDetails),
  );
}
```

- [ ] **Step 2: Create notification_service.dart**

Create `lib/core/notifications/notification_service.dart`:

```dart
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../location/timezone_util.dart';
import '../models/notification_type.dart';
import '../models/prayer_times.dart';
import '../models/user_settings.dart';
import 'alarm_callback.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    await AndroidAlarmManager.initialize();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'prayer_times',
      'Prayer Times',
      description: 'Prayer time notifications',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Schedule notifications for all prayers that haven't passed yet today.
  static Future<void> scheduleAllPrayers({
    required PrayerTimes times,
    required UserSettings settings,
  }) async {
    // Cancel all existing alarms first
    await cancelAll();

    if (settings.latitude == null || settings.longitude == null) return;

    final prayerEntries = {
      0: ('Fajr', times.fajr),
      1: ('Dhuhr', times.dhuhr),
      2: ('Asr', times.asr),
      3: ('Maghrib', times.maghrib),
      4: ('Isha', times.isha),
    };

    final now = TimezoneUtil.nowAt(settings.latitude!, settings.longitude!);

    for (final entry in prayerEntries.entries) {
      final alarmId = entry.key;
      final prayerName = entry.value.$1;
      final timeStr = entry.value.$2;
      final notifType = settings.notificationFor(prayerName);

      if (notifType == NotificationType.off) continue;

      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final target = TimezoneUtil.timeAt(
        settings.latitude!,
        settings.longitude!,
        hour,
        minute,
      );

      // Skip if prayer time has already passed
      if (target.isBefore(now)) continue;

      // Schedule exact alarm
      await AndroidAlarmManager.oneShotAt(
        target,
        alarmId,
        onAlarmFired,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
      );
    }
  }

  static Future<void> cancelAll() async {
    for (var i = 0; i < 5; i++) {
      await AndroidAlarmManager.cancel(i);
    }
  }
}
```

- [ ] **Step 3: Verify it compiles**

```bash
fvm flutter analyze
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/core/notifications/
git commit -m "feat: add NotificationService with alarm scheduling and callback"
```

---

### Task 3: AdhanPlayer

**Files:**
- Create: `lib/core/notifications/adhan_player.dart`

- [ ] **Step 1: Create adhan_player.dart**

```dart
import 'package:just_audio/just_audio.dart';
import '../debug_log.dart';

class AdhanPlayer {
  static AudioPlayer? _player;

  static Future<void> play({required bool isFajr}) async {
    try {
      await stop(); // Stop any currently playing adhan

      _player = AudioPlayer();
      final asset = isFajr ? 'assets/audio/adhan_fajr.mp3' : 'assets/audio/adhan_standard.mp3';
      await _player!.setAsset(asset);
      await _player!.play();

      // Clean up after playback completes
      _player!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          stop();
        }
      });
    } catch (e) {
      DebugLog.info('Adhan playback error: $e');
    }
  }

  static Future<void> stop() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
fvm flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/core/notifications/adhan_player.dart
git commit -m "feat: add AdhanPlayer for adhan audio playback from assets"
```

---

### Task 4: Settings provider and UI

**Files:**
- Modify: `lib/features/settings/settings_provider.dart`
- Modify: `lib/features/settings/settings_screen.dart`

- [ ] **Step 1: Add notification methods to SettingsNotifier**

Add to `lib/features/settings/settings_provider.dart`:

```dart
  Future<void> setNotificationType(String prayerName, NotificationType type) async {
    final updated = Map<String, NotificationType>.from(state.notificationTypes);
    updated[prayerName] = type;
    state = state.copyWith(notificationTypes: updated);
    await HiveService.saveSettings(state);
  }

  Future<void> setSoundPreference(SoundPreference pref) async {
    state = state.copyWith(soundPreference: pref);
    await HiveService.saveSettings(state);
  }
```

Add imports at the top:
```dart
import '../../core/models/notification_type.dart';
```

- [ ] **Step 2: Add Notifications section to settings screen**

Add between the Calculation Method section and Location section in `lib/features/settings/settings_screen.dart`:

```dart
          const SizedBox(height: 24),

          // Notifications
          const _SectionHeader('Notifications'),
          const SizedBox(height: 8),
          ...['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((prayer) {
            final notifType = settings.notificationFor(prayer);
            return _NotificationTile(
              prayer: prayer,
              type: notifType,
              isDark: isDark,
              onTap: () => _showNotificationPicker(context, ref, prayer, notifType),
            );
          }),
          const SizedBox(height: 8),
          _SoundPreferenceTile(
            preference: settings.soundPreference,
            isDark: isDark,
            onTap: () {
              final newPref = settings.soundPreference == SoundPreference.system
                  ? SoundPreference.gentle
                  : SoundPreference.system;
              ref.read(settingsProvider.notifier).setSoundPreference(newPref);
            },
          ),
```

Add the `_showNotificationPicker` method:

```dart
  void _showNotificationPicker(BuildContext context, WidgetRef ref, String prayer, NotificationType current) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(prayer, style: TextStyle(color: isDark ? AppColors.sage : AppColors.deepGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: NotificationType.values.map((type) {
              final label = switch (type) {
                NotificationType.off => 'Off',
                NotificationType.silent => 'Silent',
                NotificationType.vibrate => 'Vibrate',
                NotificationType.sound => 'Sound',
                NotificationType.adhan => 'Adhan',
              };
              return RadioListTile<NotificationType>(
                title: Text(label, style: TextStyle(color: isDark ? AppColors.sage : AppColors.deepGreen)),
                value: type,
                groupValue: current,
                activeColor: AppColors.sage,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setNotificationType(prayer, value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
```

Add these widget classes at the bottom of the file:

```dart
class _NotificationTile extends StatelessWidget {
  final String prayer;
  final NotificationType type;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.prayer,
    required this.type,
    required this.isDark,
    required this.onTap,
  });

  String get _typeLabel => switch (type) {
        NotificationType.off => 'Off',
        NotificationType.silent => 'Silent',
        NotificationType.vibrate => 'Vibrate',
        NotificationType.sound => 'Sound',
        NotificationType.adhan => 'Adhan',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(prayer, style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.sage : AppColors.deepGreen,
                )),
                Text(_typeLabel, style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundPreferenceTile extends StatelessWidget {
  final SoundPreference preference;
  final bool isDark;
  final VoidCallback onTap;

  const _SoundPreferenceTile({
    required this.preference,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = preference == SoundPreference.system ? 'System default' : 'Gentle tone';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notification sound', style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.sage : AppColors.deepGreen,
                )),
                Text(label, style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

Add imports at the top of settings_screen.dart:
```dart
import '../../core/models/notification_type.dart';
```

- [ ] **Step 3: Verify it compiles**

```bash
fvm flutter analyze
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/settings_provider.dart lib/features/settings/settings_screen.dart
git commit -m "feat: add notification settings UI with per-prayer configuration"
```

---

### Task 5: Integration — wire up scheduling

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/features/prayer_times/prayer_times_provider.dart`

- [ ] **Step 1: Initialize NotificationService in main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'core/notifications/notification_service.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  await HiveService.init();
  await NotificationService.init();
  runApp(const ProviderScope(child: KhushuApp()));
}
```

- [ ] **Step 2: Schedule notifications after prayer times load**

In `lib/features/prayer_times/prayer_times_provider.dart`, add scheduling after the cache or fetch returns in `build()`:

```dart
import '../../core/notifications/notification_service.dart';
```

After the line `return times;` in the build method (both cache hit and fetch paths), add:

```dart
    // Schedule notifications
    NotificationService.scheduleAllPrayers(times: times, settings: settings);
```

Also add re-scheduling in the `refresh()` method after `return times;`.

- [ ] **Step 3: Re-schedule when notification settings change**

In `lib/features/settings/settings_provider.dart`, add re-scheduling after notification settings change:

```dart
import '../../core/notifications/notification_service.dart';
```

The re-scheduling happens automatically because `settingsProvider` state change triggers `prayerTimesProvider` rebuild (via `ref.watch(settingsProvider)`), which calls `scheduleAllPrayers`.

- [ ] **Step 4: Request permission on Android 13+**

In the `_showNotificationPicker` method in settings_screen.dart, add permission request before setting a non-off type:

```dart
onChanged: (value) async {
  if (value != null && value != NotificationType.off) {
    await NotificationService.requestPermission();
  }
  if (value != null) {
    ref.read(settingsProvider.notifier).setNotificationType(prayer, value);
    Navigator.pop(context);
  }
},
```

- [ ] **Step 5: Verify it compiles and all tests pass**

```bash
fvm flutter analyze
fvm flutter test
```

Expected: ALL PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/main.dart lib/features/prayer_times/prayer_times_provider.dart lib/features/settings/settings_provider.dart lib/features/settings/settings_screen.dart
git commit -m "feat: wire up notification scheduling on prayer times load and settings change"
```

---

### Task 6: Deploy and test on phone

**Files:** None — manual testing only.

- [ ] **Step 1: Build and install on phone**

```bash
fvm flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

- [ ] **Step 2: Test notification types**

1. Open Settings → Notifications
2. Set Fajr to "Adhan" — verify adhan audio plays at Fajr time
3. Set Dhuhr to "Vibrate" — verify phone vibrates at Dhuhr
4. Set Asr to "Off" — verify no notification at Asr
5. Set Maghrib to "Sound" — verify notification sound plays

- [ ] **Step 3: Test with remote location**

1. Set location to Istanbul
2. Verify notifications fire at Istanbul prayer times (not local time)

- [ ] **Step 4: Test persistence**

1. Close the app completely
2. Wait for next prayer time — verify notification fires
3. Reboot phone — verify notifications still fire

- [ ] **Step 5: Run all tests one final time**

```bash
fvm flutter test
```

Expected: ALL PASS.

- [ ] **Step 6: Commit any fixes, create PR**

```bash
git push -u origin feat/prayer-notifications
gh pr create --title "feat: prayer notifications with adhan audio" --body "..."
```
