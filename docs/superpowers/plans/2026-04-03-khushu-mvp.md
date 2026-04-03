# Khushu MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter prayer times app that supports Sunni (Standard + Hanafi) and Shia (Jafari) traditions with auto-detected regional calculation methods, Garden of Peace visual theme, and light/dark mode.

**Architecture:** Single-codebase Flutter app using Riverpod for state management, Hive for local persistence, and Dio for AlAdhan API calls. Feature-first project structure with three screens: onboarding, prayer times, and settings. GPS location with manual city fallback.

**Tech Stack:** Flutter 3.19+, Dart, flutter_riverpod, hive, dio, geolocator, geocoding, go_router

---

## File Structure

```
lib/
  main.dart                                    # App entry point, Hive init, ProviderScope
  core/
    theme/
      app_theme.dart                           # Garden of Peace ThemeData (light + dark)
      app_colors.dart                          # Color constants
    storage/
      hive_service.dart                        # Hive init, box references
    api/
      aladhan_api.dart                         # Dio client for AlAdhan API
    location/
      location_service.dart                    # GPS + geocoding logic
      region_detector.dart                     # Map coordinates → AlAdhan method ID
    models/
      prayer_times.dart                        # PrayerTimes data model
      user_settings.dart                       # UserSettings data model (Hive adapter)
  features/
    onboarding/
      onboarding_screen.dart                   # Mission statement + tradition picker
      onboarding_provider.dart                 # Onboarding completion state
    prayer_times/
      prayer_times_screen.dart                 # Main screen with dome header, next prayer, list
      prayer_times_provider.dart               # Fetches/caches prayer times, countdown timer
      widgets/
        dome_header.dart                       # SVG dome + minarets + crescent moon
        next_prayer_card.dart                  # Next prayer name + countdown
        prayer_time_row.dart                   # Single prayer time row
        prayer_times_list.dart                 # Full list (handles combine mode)
    settings/
      settings_screen.dart                     # All user preferences
      settings_provider.dart                   # Read/write UserSettings from Hive
  navigation/
    app_router.dart                            # GoRouter config: onboarding → prayer times → settings
test/
  core/
    api/
      aladhan_api_test.dart                    # API response parsing tests
    location/
      region_detector_test.dart                # Region → method mapping tests
    models/
      prayer_times_test.dart                   # Model serialization tests
      user_settings_test.dart                  # Settings model tests
  features/
    prayer_times/
      prayer_times_provider_test.dart          # Provider logic tests
```

---

### Task 0: Install Flutter and scaffold the project

**Files:**
- Create: entire Flutter project scaffold

- [ ] **Step 0.1: Install FVM (Flutter Version Management)**

```bash
brew install fvm
```

- [ ] **Step 0.2: Install Flutter via FVM and pin to project**

```bash
cd /Users/fatima/git/khushu
fvm install 3.24.0
fvm use 3.24.0
```

This creates a `.fvmrc` file in the project root (commit this) and downloads Flutter 3.24.0 into FVM's cache — not globally.

Add FVM's local symlink to `.gitignore`:

```bash
echo ".fvm/" >> .gitignore
```

Verify:

```bash
fvm flutter --version
fvm flutter doctor
```

Expected: Flutter 3.24.0 installed, Dart SDK included. Warnings about Xcode/Android Studio are OK for now.

**Note:** All `flutter` commands in this plan should be run as `fvm flutter` to use the project-pinned version.

- [ ] **Step 0.3: Create Flutter project**

```bash
cd /Users/fatima/git/khushu
fvm flutter create . --org com.khushu --project-name khushu --platforms android,ios
```

This creates the Flutter project in the existing repo directory.

- [ ] **Step 0.4: Verify the app builds**

```bash
fvm fvm flutter pub get
fvm fvm flutter analyze
```

Expected: No errors. Warnings are OK.

- [ ] **Step 0.5: Add dependencies to pubspec.yaml**

Replace the `dependencies` and `dev_dependencies` sections in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  dio: ^5.4.3+1
  geolocator: ^12.0.0
  geocoding: ^3.0.0
  go_router: ^14.2.0
  flutter_svg: ^2.0.10+1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  hive_generator: ^2.0.1
  riverpod_generator: ^2.4.0
  riverpod_lint: ^2.3.10
  mockito: ^5.4.4
  build_verify: ^3.1.0
```

Then run:

```bash
fvm flutter pub get
```

Expected: All packages resolve successfully.

- [ ] **Step 0.6: Create directory structure**

```bash
mkdir -p lib/core/theme lib/core/storage lib/core/api lib/core/location lib/core/models
mkdir -p lib/features/onboarding lib/features/prayer_times/widgets lib/features/settings
mkdir -p lib/navigation
mkdir -p test/core/api test/core/location test/core/models
mkdir -p test/features/prayer_times
```

- [ ] **Step 0.7: Commit**

```bash
git add -A
git commit -m "feat: scaffold Flutter project with dependencies"
```

---

### Task 1: Color constants and theme

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_theme.dart`

- [ ] **Step 1.1: Create color constants**

Create `lib/core/theme/app_colors.dart`:

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Garden of Peace palette
  static const sage = Color(0xFFA8C5A0);
  static const sand = Color(0xFFD4C9A8);
  static const cream = Color(0xFFF5F1EA);
  static const deepGreen = Color(0xFF3D5A3A);
  static const charcoal = Color(0xFF2C2C2C);

  // Light mode
  static const lightBackground = cream;
  static const lightSurface = Color(0xFFEDE8DF);
  static const lightPrimary = deepGreen;
  static const lightSecondary = Color(0xFF8A8275);

  // Dark mode
  static const darkBackground = Color(0xFF1E1E1C);
  static const darkSurface = Color(0xFF2A2A27);
  static const darkPrimary = sage;
  static const darkSecondary = Color(0xFF6B6B62);

  // Next prayer card gradient
  static const cardGradientLight = [deepGreen, Color(0xFF4A6D47)];
  static const cardGradientDark = [Color(0xFF2A4228), deepGreen];

  // Highlighted prayer row
  static const highlightLight = sand;
  static const highlightDark = Color(0xFF3A3529);
}
```

- [ ] **Step 1.2: Create theme data**

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepGreen,
        secondary: AppColors.sage,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.cream,
        onSurface: AppColors.deepGreen,
      ),
      textTheme: _textTheme(AppColors.deepGreen, AppColors.lightSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.deepGreen,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sage,
        secondary: AppColors.sage,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkBackground,
        onSurface: AppColors.sage,
      ),
      textTheme: _textTheme(AppColors.sage, AppColors.darkSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.sage,
        elevation: 0,
      ),
    );
  }

  static TextTheme _textTheme(Color primary, Color secondary) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.sage,
      ),
    );
  }
}
```

- [ ] **Step 1.3: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add Garden of Peace color palette and theme"
```

---

### Task 2: Data models

**Files:**
- Create: `lib/core/models/prayer_times.dart`
- Create: `lib/core/models/user_settings.dart`
- Create: `test/core/models/prayer_times_test.dart`
- Create: `test/core/models/user_settings_test.dart`

- [ ] **Step 2.1: Write PrayerTimes model test**

Create `test/core/models/prayer_times_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/prayer_times.dart';

void main() {
  group('PrayerTimes', () {
    test('fromAlAdhanJson parses API response correctly', () {
      final json = {
        'Fajr': '05:38',
        'Sunrise': '06:52',
        'Dhuhr': '13:13',
        'Asr': '16:48',
        'Maghrib': '19:35',
        'Isha': '20:49',
      };

      final times = PrayerTimes.fromAlAdhanJson(json, DateTime(2026, 4, 3));

      expect(times.fajr, '05:38');
      expect(times.sunrise, '06:52');
      expect(times.dhuhr, '13:13');
      expect(times.asr, '16:48');
      expect(times.maghrib, '19:35');
      expect(times.isha, '20:49');
      expect(times.date, DateTime(2026, 4, 3));
    });

    test('nextPrayer returns correct prayer based on current time', () {
      final times = PrayerTimes(
        fajr: '05:38',
        sunrise: '06:52',
        dhuhr: '13:13',
        asr: '16:48',
        maghrib: '19:35',
        isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      // At 14:00, next prayer should be Asr
      final next = times.nextPrayer(DateTime(2026, 4, 3, 14, 0));
      expect(next.name, 'Asr');
      expect(next.time, '16:48');
    });

    test('nextPrayer returns Fajr when after Isha', () {
      final times = PrayerTimes(
        fajr: '05:38',
        sunrise: '06:52',
        dhuhr: '13:13',
        asr: '16:48',
        maghrib: '19:35',
        isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final next = times.nextPrayer(DateTime(2026, 4, 3, 22, 0));
      expect(next.name, 'Fajr');
    });

    test('combinedList returns 4 rows when combine is true', () {
      final times = PrayerTimes(
        fajr: '05:38',
        sunrise: '06:52',
        dhuhr: '13:13',
        asr: '16:48',
        maghrib: '19:35',
        isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final combined = times.toDisplayList(combine: true);
      expect(combined.length, 4);
      expect(combined[0].name, 'Fajr');
      expect(combined[1].name, 'Sunrise');
      expect(combined[2].name, 'Dhuhr + Asr');
      expect(combined[3].name, 'Maghrib + Isha');
    });

    test('toDisplayList returns 6 rows when combine is false', () {
      final times = PrayerTimes(
        fajr: '05:38',
        sunrise: '06:52',
        dhuhr: '13:13',
        asr: '16:48',
        maghrib: '19:35',
        isha: '20:49',
        date: DateTime(2026, 4, 3),
      );

      final list = times.toDisplayList(combine: false);
      expect(list.length, 6);
    });
  });
}
```

- [ ] **Step 2.2: Run test to verify it fails**

```bash
fvm flutter test test/core/models/prayer_times_test.dart
```

Expected: FAIL — `prayer_times.dart` doesn't exist.

- [ ] **Step 2.3: Implement PrayerTimes model**

Create `lib/core/models/prayer_times.dart`:

```dart
class PrayerTimeEntry {
  final String name;
  final String time;
  final bool isCombined;

  const PrayerTimeEntry({
    required this.name,
    required this.time,
    this.isCombined = false,
  });
}

class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final DateTime date;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerTimes.fromAlAdhanJson(Map<String, dynamic> json, DateTime date) {
    return PrayerTimes(
      fajr: json['Fajr'] as String,
      sunrise: json['Sunrise'] as String,
      dhuhr: json['Dhuhr'] as String,
      asr: json['Asr'] as String,
      maghrib: json['Maghrib'] as String,
      isha: json['Isha'] as String,
      date: date,
    );
  }

  List<PrayerTimeEntry> toDisplayList({required bool combine}) {
    if (combine) {
      return [
        PrayerTimeEntry(name: 'Fajr', time: fajr),
        PrayerTimeEntry(name: 'Sunrise', time: sunrise),
        PrayerTimeEntry(name: 'Dhuhr + Asr', time: '$dhuhr - $asr', isCombined: true),
        PrayerTimeEntry(name: 'Maghrib + Isha', time: '$maghrib - $isha', isCombined: true),
      ];
    }
    return [
      PrayerTimeEntry(name: 'Fajr', time: fajr),
      PrayerTimeEntry(name: 'Sunrise', time: sunrise),
      PrayerTimeEntry(name: 'Dhuhr', time: dhuhr),
      PrayerTimeEntry(name: 'Asr', time: asr),
      PrayerTimeEntry(name: 'Maghrib', time: maghrib),
      PrayerTimeEntry(name: 'Isha', time: isha),
    ];
  }

  PrayerTimeEntry nextPrayer(DateTime now) {
    final entries = [
      PrayerTimeEntry(name: 'Fajr', time: fajr),
      PrayerTimeEntry(name: 'Sunrise', time: sunrise),
      PrayerTimeEntry(name: 'Dhuhr', time: dhuhr),
      PrayerTimeEntry(name: 'Asr', time: asr),
      PrayerTimeEntry(name: 'Maghrib', time: maghrib),
      PrayerTimeEntry(name: 'Isha', time: isha),
    ];

    final nowMinutes = now.hour * 60 + now.minute;

    for (final entry in entries) {
      final parts = entry.time.split(':');
      final entryMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (entryMinutes > nowMinutes) {
        return entry;
      }
    }

    // After Isha — next prayer is tomorrow's Fajr
    return PrayerTimeEntry(name: 'Fajr', time: fajr);
  }
}
```

- [ ] **Step 2.4: Run test to verify it passes**

```bash
fvm flutter test test/core/models/prayer_times_test.dart
```

Expected: All 5 tests PASS.

- [ ] **Step 2.5: Write UserSettings model test**

Create `test/core/models/user_settings_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('default values are correct', () {
      final settings = UserSettings();

      expect(settings.tradition, Tradition.sunniStandard);
      expect(settings.methodId, isNull);
      expect(settings.combinePrayers, false);
      expect(settings.darkMode, isNull);
      expect(settings.latitude, isNull);
      expect(settings.longitude, isNull);
      expect(settings.locationName, isNull);
      expect(settings.onboardingComplete, false);
    });

    test('apiSchool returns 1 for Hanafi, 0 otherwise', () {
      final hanafi = UserSettings(tradition: Tradition.sunniHanafi);
      expect(hanafi.apiSchool, 1);

      final standard = UserSettings(tradition: Tradition.sunniStandard);
      expect(standard.apiSchool, 0);

      final jafari = UserSettings(tradition: Tradition.jafari);
      expect(jafari.apiSchool, 0);
    });

    test('apiMethod returns 0 for Jafari, methodId for Sunni', () {
      final jafari = UserSettings(tradition: Tradition.jafari, methodId: 2);
      expect(jafari.apiMethod, 0);

      final sunni = UserSettings(tradition: Tradition.sunniStandard, methodId: 2);
      expect(sunni.apiMethod, 2);
    });
  });
}
```

- [ ] **Step 2.6: Run test to verify it fails**

```bash
fvm flutter test test/core/models/user_settings_test.dart
```

Expected: FAIL — `user_settings.dart` doesn't exist.

- [ ] **Step 2.7: Implement UserSettings model**

Create `lib/core/models/user_settings.dart`:

```dart
import 'package:hive/hive.dart';

enum Tradition {
  sunniStandard,
  sunniHanafi,
  jafari,
}

class UserSettings {
  final Tradition tradition;
  final int? methodId;
  final bool combinePrayers;
  final bool? darkMode; // null = follow system
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool onboardingComplete;

  const UserSettings({
    this.tradition = Tradition.sunniStandard,
    this.methodId,
    this.combinePrayers = false,
    this.darkMode,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
  });

  int get apiSchool => tradition == Tradition.sunniHanafi ? 1 : 0;

  int get apiMethod {
    if (tradition == Tradition.jafari) return 0;
    return methodId ?? 3; // default MWL
  }

  UserSettings copyWith({
    Tradition? tradition,
    int? methodId,
    bool? combinePrayers,
    bool? darkMode,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? onboardingComplete,
  }) {
    return UserSettings(
      tradition: tradition ?? this.tradition,
      methodId: methodId ?? this.methodId,
      combinePrayers: combinePrayers ?? this.combinePrayers,
      darkMode: darkMode ?? this.darkMode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'tradition': tradition.index,
        'methodId': methodId,
        'combinePrayers': combinePrayers,
        'darkMode': darkMode,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        tradition: Tradition.values[json['tradition'] as int? ?? 0],
        methodId: json['methodId'] as int?,
        combinePrayers: json['combinePrayers'] as bool? ?? false,
        darkMode: json['darkMode'] as bool?,
        latitude: json['latitude'] as double?,
        longitude: json['longitude'] as double?,
        locationName: json['locationName'] as String?,
        onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      );
}
```

- [ ] **Step 2.8: Run test to verify it passes**

```bash
fvm flutter test test/core/models/user_settings_test.dart
```

Expected: All 3 tests PASS.

- [ ] **Step 2.9: Commit**

```bash
git add lib/core/models/ test/core/models/
git commit -m "feat: add PrayerTimes and UserSettings data models with tests"
```

---

### Task 3: Region detector

**Files:**
- Create: `lib/core/location/region_detector.dart`
- Create: `test/core/location/region_detector_test.dart`

- [ ] **Step 3.1: Write region detector test**

Create `test/core/location/region_detector_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/location/region_detector.dart';

void main() {
  group('RegionDetector', () {
    test('North America returns ISNA (2)', () {
      // San Francisco
      expect(RegionDetector.detectMethod(37.77, -122.42), 2);
    });

    test('Europe returns MWL (3)', () {
      // London
      expect(RegionDetector.detectMethod(51.51, -0.13), 3);
    });

    test('Saudi Arabia returns Umm Al-Qura (4)', () {
      // Makkah
      expect(RegionDetector.detectMethod(21.39, 39.86), 4);
    });

    test('Egypt returns Egyptian (5)', () {
      // Cairo
      expect(RegionDetector.detectMethod(30.04, 31.24), 5);
    });

    test('Pakistan returns Karachi (1)', () {
      // Karachi
      expect(RegionDetector.detectMethod(24.86, 67.01), 1);
    });

    test('Turkey returns Turkey (13)', () {
      // Istanbul
      expect(RegionDetector.detectMethod(41.01, 28.98), 13);
    });

    test('Iran returns Tehran (7)', () {
      // Tehran
      expect(RegionDetector.detectMethod(35.69, 51.39), 7);
    });

    test('unknown region defaults to MWL (3)', () {
      // Antarctica
      expect(RegionDetector.detectMethod(-80.0, 0.0), 3);
    });
  });
}
```

- [ ] **Step 3.2: Run test to verify it fails**

```bash
fvm flutter test test/core/location/region_detector_test.dart
```

Expected: FAIL — `region_detector.dart` doesn't exist.

- [ ] **Step 3.3: Implement region detector**

Create `lib/core/location/region_detector.dart`:

```dart
class RegionDetector {
  /// Maps GPS coordinates to the best AlAdhan calculation method ID.
  /// Uses bounding-box regions — not perfect, but good enough for auto-detection.
  /// Users can override in settings.
  static int detectMethod(double latitude, double longitude) {
    // Turkey
    if (_inBox(latitude, longitude, 36, 42, 26, 45)) return 13;

    // Iran
    if (_inBox(latitude, longitude, 25, 40, 44, 63)) return 7;

    // Saudi Arabia + Yemen + Oman
    if (_inBox(latitude, longitude, 12, 32, 34, 56)) return 4;

    // Gulf states (UAE, Qatar, Bahrain, Kuwait)
    if (_inBox(latitude, longitude, 22, 32, 45, 56)) return 8;

    // Egypt
    if (_inBox(latitude, longitude, 22, 32, 24, 37)) return 5;

    // North Africa (Morocco, Algeria, Tunisia, Libya)
    if (_inBox(latitude, longitude, 18, 38, -18, 25)) return 5;

    // Pakistan, India, Bangladesh
    if (_inBox(latitude, longitude, 5, 38, 60, 93)) return 1;

    // SE Asia (Malaysia, Indonesia)
    if (_inBox(latitude, longitude, -11, 8, 95, 141)) return 17;

    // North America
    if (_inBox(latitude, longitude, 15, 72, -170, -50)) return 2;

    // Europe
    if (_inBox(latitude, longitude, 35, 72, -25, 45)) return 3;

    // Default: Muslim World League
    return 3;
  }

  static bool _inBox(
    double lat,
    double lng,
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}
```

- [ ] **Step 3.4: Run test to verify it passes**

```bash
fvm flutter test test/core/location/region_detector_test.dart
```

Expected: All 8 tests PASS.

- [ ] **Step 3.5: Commit**

```bash
git add lib/core/location/region_detector.dart test/core/location/
git commit -m "feat: add region detector for auto-detecting AlAdhan method"
```

---

### Task 4: Hive storage service

**Files:**
- Create: `lib/core/storage/hive_service.dart`

- [ ] **Step 4.1: Implement Hive service**

Create `lib/core/storage/hive_service.dart`:

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/prayer_times.dart';

class HiveService {
  static const _settingsBox = 'settings';
  static const _cacheBox = 'prayer_cache';
  static const _settingsKey = 'user_settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
  }

  static UserSettings loadSettings() {
    final box = Hive.box(_settingsBox);
    final json = box.get(_settingsKey);
    if (json == null) return const UserSettings();
    return UserSettings.fromJson(Map<String, dynamic>.from(json));
  }

  static Future<void> saveSettings(UserSettings settings) async {
    final box = Hive.box(_settingsBox);
    await box.put(_settingsKey, settings.toJson());
  }

  static PrayerTimes? loadCachedPrayerTimes(DateTime date) {
    final box = Hive.box(_cacheBox);
    final key = '${date.year}-${date.month}-${date.day}';
    final json = box.get(key);
    if (json == null) return null;
    return PrayerTimes.fromAlAdhanJson(Map<String, dynamic>.from(json), date);
  }

  static Future<void> cachePrayerTimes(PrayerTimes times) async {
    final box = Hive.box(_cacheBox);
    final key = '${times.date.year}-${times.date.month}-${times.date.day}';
    await box.put(key, {
      'Fajr': times.fajr,
      'Sunrise': times.sunrise,
      'Dhuhr': times.dhuhr,
      'Asr': times.asr,
      'Maghrib': times.maghrib,
      'Isha': times.isha,
    });
  }
}
```

- [ ] **Step 4.2: Commit**

```bash
git add lib/core/storage/
git commit -m "feat: add Hive storage service for settings and prayer cache"
```

---

### Task 5: AlAdhan API client

**Files:**
- Create: `lib/core/api/aladhan_api.dart`
- Create: `test/core/api/aladhan_api_test.dart`

- [ ] **Step 5.1: Write API parsing test**

Create `test/core/api/aladhan_api_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/api/aladhan_api.dart';
import 'package:khushu/core/models/prayer_times.dart';

void main() {
  group('AlAdhanApi', () {
    test('parseResponse extracts prayer times from API JSON', () {
      final apiResponse = {
        'code': 200,
        'status': 'OK',
        'data': {
          'timings': {
            'Fajr': '05:38',
            'Sunrise': '06:52',
            'Dhuhr': '13:13',
            'Asr': '16:48',
            'Sunset': '19:35',
            'Maghrib': '19:35',
            'Isha': '20:49',
            'Imsak': '05:28',
            'Midnight': '01:13',
            'Firstthird': '23:20',
            'Lastthird': '03:06',
          },
        },
      };

      final times = AlAdhanApi.parseResponse(apiResponse, DateTime(2026, 4, 3));

      expect(times.fajr, '05:38');
      expect(times.sunrise, '06:52');
      expect(times.dhuhr, '13:13');
      expect(times.asr, '16:48');
      expect(times.maghrib, '19:35');
      expect(times.isha, '20:49');
      expect(times.date, DateTime(2026, 4, 3));
    });

    test('buildUrl constructs correct API URL', () {
      final url = AlAdhanApi.buildUrl(
        latitude: 37.7749,
        longitude: -122.4194,
        method: 2,
        school: 0,
        date: DateTime(2026, 4, 3),
      );

      expect(url, contains('api.aladhan.com'));
      expect(url, contains('latitude=37.7749'));
      expect(url, contains('longitude=-122.4194'));
      expect(url, contains('method=2'));
      expect(url, contains('school=0'));
      expect(url, contains('03-04-2026'));
    });
  });
}
```

- [ ] **Step 5.2: Run test to verify it fails**

```bash
fvm flutter test test/core/api/aladhan_api_test.dart
```

Expected: FAIL — `aladhan_api.dart` doesn't exist.

- [ ] **Step 5.3: Implement AlAdhan API client**

Create `lib/core/api/aladhan_api.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/prayer_times.dart';

class AlAdhanApi {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static String buildUrl({
    required double latitude,
    required double longitude,
    required int method,
    required int school,
    required DateTime date,
  }) {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    return 'https://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$method'
        '&school=$school';
  }

  static PrayerTimes parseResponse(Map<String, dynamic> json, DateTime date) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    return PrayerTimes.fromAlAdhanJson(timings, date);
  }

  static Future<PrayerTimes> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int school,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final url = buildUrl(
      latitude: latitude,
      longitude: longitude,
      method: method,
      school: school,
      date: targetDate,
    );

    final response = await _dio.get(url);
    return parseResponse(response.data as Map<String, dynamic>, targetDate);
  }
}
```

- [ ] **Step 5.4: Run test to verify it passes**

```bash
fvm flutter test test/core/api/aladhan_api_test.dart
```

Expected: All 2 tests PASS.

- [ ] **Step 5.5: Commit**

```bash
git add lib/core/api/ test/core/api/
git commit -m "feat: add AlAdhan API client with URL builder and response parser"
```

---

### Task 6: Location service

**Files:**
- Create: `lib/core/location/location_service.dart`

- [ ] **Step 6.1: Implement location service**

Create `lib/core/location/location_service.dart`:

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String name;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}

class LocationService {
  static Future<LocationResult?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    final name = await _reverseGeocode(position.latitude, position.longitude);

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      name: name,
    );
  }

  static Future<LocationResult?> searchCity(String query) async {
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;

      final loc = locations.first;
      final name = await _reverseGeocode(loc.latitude, loc.longitude);

      return LocationResult(
        latitude: loc.latitude,
        longitude: loc.longitude,
        name: name,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final city = p.locality ?? p.subAdministrativeArea ?? '';
        final country = p.isoCountryCode ?? '';
        if (city.isNotEmpty && country.isNotEmpty) return '$city, $country';
        if (city.isNotEmpty) return city;
        return country;
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';
  }
}
```

- [ ] **Step 6.2: Commit**

```bash
git add lib/core/location/location_service.dart
git commit -m "feat: add location service with GPS and city search"
```

---

### Task 7: Settings provider (Riverpod)

**Files:**
- Create: `lib/features/settings/settings_provider.dart`

- [ ] **Step 7.1: Implement settings provider**

Create `lib/features/settings/settings_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_settings.dart';
import '../../core/storage/hive_service.dart';

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(HiveService.loadSettings());

  Future<void> setTradition(Tradition tradition) async {
    state = state.copyWith(tradition: tradition);
    await HiveService.saveSettings(state);
  }

  Future<void> setMethodId(int methodId) async {
    state = state.copyWith(methodId: methodId);
    await HiveService.saveSettings(state);
  }

  Future<void> setLocation(double lat, double lng, String name) async {
    state = state.copyWith(latitude: lat, longitude: lng, locationName: name);
    await HiveService.saveSettings(state);
  }

  Future<void> setCombinePrayers(bool combine) async {
    state = state.copyWith(combinePrayers: combine);
    await HiveService.saveSettings(state);
  }

  Future<void> setDarkMode(bool? darkMode) async {
    state = state.copyWith(darkMode: darkMode);
    await HiveService.saveSettings(state);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingComplete: true);
    await HiveService.saveSettings(state);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});
```

- [ ] **Step 7.2: Commit**

```bash
git add lib/features/settings/settings_provider.dart
git commit -m "feat: add Riverpod settings provider"
```

---

### Task 8: Prayer times provider

**Files:**
- Create: `lib/features/prayer_times/prayer_times_provider.dart`

- [ ] **Step 8.1: Implement prayer times provider**

Create `lib/features/prayer_times/prayer_times_provider.dart`:

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/aladhan_api.dart';
import '../../core/models/prayer_times.dart';
import '../../core/storage/hive_service.dart';
import '../settings/settings_provider.dart';

final prayerTimesProvider =
    AsyncNotifierProvider<PrayerTimesNotifier, PrayerTimes>(
  PrayerTimesNotifier.new,
);

class PrayerTimesNotifier extends AsyncNotifier<PrayerTimes> {
  @override
  Future<PrayerTimes> build() async {
    final settings = ref.watch(settingsProvider);

    if (settings.latitude == null || settings.longitude == null) {
      throw Exception('Location not set');
    }

    // Try cache first
    final today = DateTime.now();
    final cached = HiveService.loadCachedPrayerTimes(today);
    if (cached != null) return cached;

    // Fetch from API
    final times = await AlAdhanApi.fetchPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.apiMethod,
      school: settings.apiSchool,
      date: today,
    );

    // Cache for today
    await HiveService.cachePrayerTimes(times);
    return times;
  }

  Future<void> refresh() async {
    final settings = ref.read(settingsProvider);
    if (settings.latitude == null || settings.longitude == null) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final times = await AlAdhanApi.fetchPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.apiMethod,
        school: settings.apiSchool,
        date: DateTime.now(),
      );
      await HiveService.cachePrayerTimes(times);
      return times;
    });
  }
}

// Countdown timer that ticks every second
final countdownProvider = StreamProvider<Duration>((ref) {
  final timesAsync = ref.watch(prayerTimesProvider);

  return timesAsync.when(
    data: (times) {
      return Stream.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        final next = times.nextPrayer(now);
        final parts = next.time.split(':');
        var targetHour = int.parse(parts[0]);
        var targetMinute = int.parse(parts[1]);

        var target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);

        // If next prayer is tomorrow's Fajr
        if (target.isBefore(now)) {
          target = target.add(const Duration(days: 1));
        }

        return target.difference(now);
      });
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
```

- [ ] **Step 8.2: Commit**

```bash
git add lib/features/prayer_times/prayer_times_provider.dart
git commit -m "feat: add prayer times provider with caching and countdown"
```

---

### Task 9: Navigation (GoRouter)

**Files:**
- Create: `lib/navigation/app_router.dart`

- [ ] **Step 9.1: Implement router**

Create `lib/navigation/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/prayer_times/prayer_times_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/settings_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);

  return GoRouter(
    initialLocation: settings.onboardingComplete ? '/prayer-times' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/prayer-times',
        builder: (context, state) => const PrayerTimesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
```

- [ ] **Step 9.2: Commit**

```bash
git add lib/navigation/
git commit -m "feat: add GoRouter navigation with onboarding guard"
```

---

### Task 10: Onboarding screen

**Files:**
- Create: `lib/features/onboarding/onboarding_screen.dart`
- Create: `lib/features/onboarding/onboarding_provider.dart`

- [ ] **Step 10.1: Create onboarding provider**

Create `lib/features/onboarding/onboarding_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/location/location_service.dart';
import '../../core/location/region_detector.dart';
import '../../core/models/user_settings.dart';
import '../settings/settings_provider.dart';

final onboardingProvider = Provider((ref) => OnboardingController(ref));

class OnboardingController {
  final Ref _ref;

  OnboardingController(this._ref);

  Future<bool> setupLocation() async {
    final result = await LocationService.getCurrentLocation();
    if (result == null) return false;

    final methodId = RegionDetector.detectMethod(result.latitude, result.longitude);
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.setLocation(result.latitude, result.longitude, result.name);
    await notifier.setMethodId(methodId);
    return true;
  }

  Future<void> selectTradition(Tradition tradition) async {
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.setTradition(tradition);
    await notifier.completeOnboarding();
  }

  Future<LocationResult?> searchCity(String query) async {
    final result = await LocationService.searchCity(query);
    if (result == null) return null;

    final methodId = RegionDetector.detectMethod(result.latitude, result.longitude);
    final notifier = _ref.read(settingsProvider.notifier);
    await notifier.setLocation(result.latitude, result.longitude, result.name);
    await notifier.setMethodId(methodId);
    return result;
  }
}
```

- [ ] **Step 10.2: Create onboarding screen**

Create `lib/features/onboarding/onboarding_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _locationReady = false;
  bool _locationLoading = true;
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    final controller = ref.read(onboardingProvider);
    final success = await controller.setupLocation();
    if (mounted) {
      setState(() {
        _locationReady = success;
        _locationLoading = false;
      });
    }
  }

  Future<void> _searchCity() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) return;

    final controller = ref.read(onboardingProvider);
    final result = await controller.searchCity(query);
    if (result != null && mounted) {
      setState(() => _locationReady = true);
    }
  }

  Future<void> _selectTradition(Tradition tradition) async {
    final controller = ref.read(onboardingProvider);
    await controller.selectTradition(tradition);
    if (mounted) context.go('/prayer-times');
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Text(
                'KHUSHU',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'One Ummah Serving Allah',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Location status
              if (_locationLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (!_locationReady) ...[
                Text(
                  'Enter your city',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          hintText: 'e.g. London, UK',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _searchCity(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _searchCity,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Tradition selection
              if (_locationReady) ...[
                Text(
                  'Which tradition do you follow?',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 16),
                _TraditionButton(
                  label: 'Sunni (Standard Asr)',
                  subtitle: 'Maliki, Shafi\'i, Hanbali',
                  isDark: isDark,
                  onTap: () => _selectTradition(Tradition.sunniStandard),
                ),
                const SizedBox(height: 10),
                _TraditionButton(
                  label: 'Sunni (Hanafi Asr)',
                  subtitle: 'Later Asr prayer time',
                  isDark: isDark,
                  onTap: () => _selectTradition(Tradition.sunniHanafi),
                ),
                const SizedBox(height: 10),
                _TraditionButton(
                  label: 'Shia (Jafari)',
                  subtitle: 'Ithna-Ashari tradition',
                  isDark: isDark,
                  onTap: () => _selectTradition(Tradition.jafari),
                ),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraditionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _TraditionButton({
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.sage : AppColors.deepGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.sage,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 10.3: Commit**

```bash
git add lib/features/onboarding/
git commit -m "feat: add onboarding screen with tradition picker and location setup"
```

---

### Task 11: Prayer times screen widgets

**Files:**
- Create: `lib/features/prayer_times/widgets/dome_header.dart`
- Create: `lib/features/prayer_times/widgets/next_prayer_card.dart`
- Create: `lib/features/prayer_times/widgets/prayer_time_row.dart`
- Create: `lib/features/prayer_times/widgets/prayer_times_list.dart`

- [ ] **Step 11.1: Create dome header widget**

Create `lib/features/prayer_times/widgets/dome_header.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DomeHeader extends StatelessWidget {
  final String locationName;
  final String date;

  const DomeHeader({
    super.key,
    required this.locationName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strokeColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final strokeOpacity = isDark ? 0.32 : 0.45;
    final textColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return SizedBox(
      height: 135,
      child: CustomPaint(
        painter: _DomePainter(
          strokeColor: strokeColor,
          opacity: strokeOpacity,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KHUSHU',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  locationName,
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: AppColors.sage),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DomePainter extends CustomPainter {
  final Color strokeColor;
  final double opacity;

  _DomePainter({required this.strokeColor, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final cx = size.width / 2;
    final bottom = size.height;

    // Left minaret
    canvas.drawLine(Offset(cx - 115, bottom), Offset(cx - 115, 50), paint);
    canvas.drawLine(Offset(cx - 105, bottom), Offset(cx - 105, 50), paint);
    // Left minaret pointed top
    final leftTop = Path()
      ..moveTo(cx - 115, 50)
      ..quadraticBezierTo(cx - 115, 38, cx - 110, 28)
      ..quadraticBezierTo(cx - 105, 38, cx - 105, 50);
    canvas.drawPath(leftTop, paint);

    // Right minaret
    canvas.drawLine(Offset(cx + 105, bottom), Offset(cx + 105, 50), paint);
    canvas.drawLine(Offset(cx + 115, bottom), Offset(cx + 115, 50), paint);
    // Right minaret pointed top
    final rightTop = Path()
      ..moveTo(cx + 105, 50)
      ..quadraticBezierTo(cx + 105, 38, cx + 110, 28)
      ..quadraticBezierTo(cx + 115, 38, cx + 115, 50);
    canvas.drawPath(rightTop, paint);

    // Dome arc
    final dome = Path()
      ..moveTo(cx - 105, bottom)
      ..arcToPoint(
        Offset(cx + 105, bottom),
        radius: const Radius.elliptical(120, 95),
        clockwise: false,
      );
    canvas.drawPath(dome, paint);

    // Crescent moon on top — tilted, open side right
    canvas.save();
    canvas.translate(cx, 14);
    canvas.rotate(-0.52); // ~-30 degrees
    canvas.scale(-1, 1); // flip horizontal

    final moonOuter = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 6));
    canvas.drawPath(moonOuter, paint);

    final moonInner = Paint()
      ..color = Theme.of(WidgetsBinding.instance.platformDispatcher.views.first
                  .platformDispatcher.platformBrightness ==
              Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(2.8, -1.5), 5, moonInner);

    canvas.restore();

    // Finial stem
    canvas.drawLine(Offset(cx, 24), Offset(cx, 34), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 11.2: Create next prayer card widget**

Create `lib/features/prayer_times/widgets/next_prayer_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NextPrayerCard extends StatelessWidget {
  final String prayerName;
  final Duration countdown;

  const NextPrayerCard({
    super.key,
    required this.prayerName,
    required this.countdown,
  });

  String _formatCountdown(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'NEXT PRAYER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prayerName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCountdown(countdown),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.sage,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 11.3: Create prayer time row widget**

Create `lib/features/prayer_times/widgets/prayer_time_row.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrayerTimeRow extends StatelessWidget {
  final String name;
  final String time;
  final bool isHighlighted;

  const PrayerTimeRow({
    super.key,
    required this.name,
    required this.time,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color background;
    Color nameColor;
    Color timeColor;

    if (isHighlighted) {
      background = isDark ? AppColors.highlightDark : AppColors.highlightLight;
      nameColor = isDark ? AppColors.cream : AppColors.deepGreen;
      timeColor = isDark ? AppColors.sage : AppColors.deepGreen;
    } else {
      background = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      nameColor = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
      timeColor = isDark ? AppColors.sage : AppColors.deepGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? const Border(left: BorderSide(color: AppColors.sage, width: 3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              color: nameColor,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: timeColor,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 11.4: Create prayer times list widget**

Create `lib/features/prayer_times/widgets/prayer_times_list.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/models/prayer_times.dart';
import 'prayer_time_row.dart';

class PrayerTimesList extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final bool combinePrayers;
  final String nextPrayerName;

  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
    required this.combinePrayers,
    required this.nextPrayerName,
  });

  @override
  Widget build(BuildContext context) {
    final entries = prayerTimes.toDisplayList(combine: combinePrayers);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: entries.map((entry) {
          return PrayerTimeRow(
            name: entry.name,
            time: entry.time,
            isHighlighted: entry.name == nextPrayerName ||
                (entry.isCombined && entry.name.contains(nextPrayerName)),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 11.5: Commit**

```bash
git add lib/features/prayer_times/widgets/
git commit -m "feat: add prayer times UI widgets (dome, card, rows, list)"
```

---

### Task 12: Prayer times screen

**Files:**
- Create: `lib/features/prayer_times/prayer_times_screen.dart`

- [ ] **Step 12.1: Implement prayer times screen**

Create `lib/features/prayer_times/prayer_times_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../settings/settings_provider.dart';
import 'prayer_times_provider.dart';
import 'widgets/dome_header.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_times_list.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final timesAsync = ref.watch(prayerTimesProvider);
    final countdownAsync = ref.watch(countdownProvider);

    return Scaffold(
      body: SafeArea(
        child: timesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Could not load prayer times',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(prayerTimesProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (times) {
            final nextPrayer = times.nextPrayer(DateTime.now());
            final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

            return SingleChildScrollView(
              child: Column(
                children: [
                  DomeHeader(
                    locationName: settings.locationName ?? 'Unknown',
                    date: dateStr,
                  ),
                  const SizedBox(height: 8),
                  countdownAsync.when(
                    data: (countdown) => NextPrayerCard(
                      prayerName: nextPrayer.name,
                      countdown: countdown,
                    ),
                    loading: () => NextPrayerCard(
                      prayerName: nextPrayer.name,
                      countdown: Duration.zero,
                    ),
                    error: (_, __) => NextPrayerCard(
                      prayerName: nextPrayer.name,
                      countdown: Duration.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrayerTimesList(
                    prayerTimes: times,
                    combinePrayers: settings.combinePrayers,
                    nextPrayerName: nextPrayer.name,
                  ),
                  const SizedBox(height: 16),
                  // Combine prayers toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Combine prayers',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Switch(
                          value: settings.combinePrayers,
                          activeColor: AppColors.sage,
                          onChanged: (value) {
                            ref.read(settingsProvider.notifier).setCombinePrayers(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push('/settings'),
        backgroundColor: AppColors.sage,
        child: Icon(Icons.settings, color: AppColors.cream, size: 20),
      ),
    );
  }
}
```

- [ ] **Step 12.2: Commit**

```bash
git add lib/features/prayer_times/prayer_times_screen.dart
git commit -m "feat: add prayer times main screen"
```

---

### Task 13: Settings screen

**Files:**
- Create: `lib/features/settings/settings_screen.dart`

- [ ] **Step 13.1: Implement settings screen**

Create `lib/features/settings/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/location/location_service.dart';
import '../../core/location/region_detector.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/app_colors.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _cityController = TextEditingController();
  bool _showMethodOverride = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: theme.textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Tradition
          _SectionHeader('Prayer Tradition'),
          const SizedBox(height: 8),
          ...Tradition.values.map((t) => _TraditionTile(
                tradition: t,
                isSelected: settings.tradition == t,
                isDark: isDark,
                onTap: () => ref.read(settingsProvider.notifier).setTradition(t),
              )),

          const SizedBox(height: 24),

          // Location
          _SectionHeader('Location'),
          const SizedBox(height: 8),
          _InfoTile(
            label: 'Current',
            value: settings.locationName ?? 'Not set',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await LocationService.getCurrentLocation();
                    if (result != null) {
                      final method = RegionDetector.detectMethod(
                          result.latitude, result.longitude);
                      ref.read(settingsProvider.notifier).setLocation(
                          result.latitude, result.longitude, result.name);
                      ref.read(settingsProvider.notifier).setMethodId(method);
                    }
                  },
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Use GPS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    foregroundColor: AppColors.cream,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _searchCity(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _searchCity, icon: const Icon(Icons.search)),
            ],
          ),

          const SizedBox(height: 24),

          // Combine prayers
          _SectionHeader('Display'),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Combine prayers',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.sage : AppColors.deepGreen)),
            subtitle: Text('Show Dhuhr+Asr and Maghrib+Isha together',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary)),
            value: settings.combinePrayers,
            activeColor: AppColors.sage,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setCombinePrayers(v),
          ),

          const SizedBox(height: 16),

          // Dark mode
          SwitchListTile(
            title: Text('Dark mode',
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.sage : AppColors.deepGreen)),
            subtitle: Text('Follow system when off',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary)),
            value: settings.darkMode ?? false,
            activeColor: AppColors.sage,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setDarkMode(v ? true : null),
          ),

          const SizedBox(height: 24),

          // Advanced: method override
          TextButton(
            onPressed: () => setState(() => _showMethodOverride = !_showMethodOverride),
            child: Text(
              _showMethodOverride ? 'Hide advanced' : 'Advanced: Override calculation method',
              style: TextStyle(fontSize: 12, color: AppColors.sage),
            ),
          ),
          if (_showMethodOverride) ...[
            const SizedBox(height: 8),
            ..._methods.entries.map((e) => RadioListTile<int>(
                  title: Text(e.value,
                      style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.sage : AppColors.deepGreen)),
                  value: e.key,
                  groupValue: settings.apiMethod,
                  activeColor: AppColors.sage,
                  onChanged: (v) {
                    if (v != null) ref.read(settingsProvider.notifier).setMethodId(v);
                  },
                )),
          ],
        ],
      ),
    );
  }

  Future<void> _searchCity() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) return;
    final result = await LocationService.searchCity(query);
    if (result != null) {
      final method =
          RegionDetector.detectMethod(result.latitude, result.longitude);
      ref
          .read(settingsProvider.notifier)
          .setLocation(result.latitude, result.longitude, result.name);
      ref.read(settingsProvider.notifier).setMethodId(method);
      _cityController.clear();
    }
  }

  static const _methods = {
    0: 'Shia Ithna-Ashari (Qum)',
    1: 'University of Islamic Sciences, Karachi',
    2: 'ISNA (North America)',
    3: 'Muslim World League',
    4: 'Umm Al-Qura (Makkah)',
    5: 'Egyptian General Authority',
    7: 'Tehran (Univ. of Geophysics)',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'Singapore (MUIS)',
    12: 'France (UOIF)',
    13: 'Turkey (Diyanet)',
    14: 'Russia',
    15: 'Moonsighting Committee',
  };
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: AppColors.sage,
      ),
    );
  }
}

class _TraditionTile extends StatelessWidget {
  final Tradition tradition;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TraditionTile({
    required this.tradition,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  String get _label => switch (tradition) {
        Tradition.sunniStandard => 'Sunni (Standard Asr)',
        Tradition.sunniHanafi => 'Sunni (Hanafi Asr)',
        Tradition.jafari => 'Shia (Jafari)',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected
            ? (isDark ? AppColors.highlightDark : AppColors.highlightLight)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isDark ? AppColors.sage : AppColors.deepGreen,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check, color: AppColors.sage, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.sage : AppColors.deepGreen)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 13.2: Commit**

```bash
git add lib/features/settings/settings_screen.dart
git commit -m "feat: add settings screen with tradition, location, and method override"
```

---

### Task 14: Wire up main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 14.1: Replace main.dart**

Replace the contents of `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_provider.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: KhushuApp()));
}

class KhushuApp extends ConsumerWidget {
  const KhushuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    final themeMode = switch (settings.darkMode) {
      true => ThemeMode.dark,
      false => ThemeMode.light,
      null => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'Khushu',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 14.2: Run the app**

```bash
fvm flutter run
```

Expected: App launches. Shows onboarding screen with "KHUSHU" and "One Ummah Serving Allah", requests location, then shows tradition picker. After selection, navigates to prayer times screen.

- [ ] **Step 14.3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: wire up main.dart with theme, routing, and Hive init"
```

---

### Task 15: Run all tests and verify

- [ ] **Step 15.1: Run full test suite**

```bash
fvm flutter test
```

Expected: All tests pass (PrayerTimes model, UserSettings model, RegionDetector, AlAdhan API parsing).

- [ ] **Step 15.2: Run analyzer**

```bash
fvm flutter analyze
```

Expected: No errors. Fix any warnings.

- [ ] **Step 15.3: Final commit**

```bash
git add -A
git commit -m "chore: fix any remaining analyzer warnings"
```

Only commit if there are changes to fix.
