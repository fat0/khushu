# Hijri Calendar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add optional Hijri date display in the dome header, toggled via Settings (Gregorian default).

**Architecture:** `hijri` package for offline Gregorian→Hijri conversion, AlAdhan API Hijri date parsed from existing response as primary source. New `CalendarType` enum in UserSettings. Dome header switches date format based on setting.

**Tech Stack:** Flutter, Riverpod, hijri package, AlAdhan API, Hive

---

### Task 1: Add hijri Dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add hijri to pubspec.yaml**

Add under `dependencies:` after `connectivity_plus`:

```yaml
  hijri: ^3.0.0
```

- [ ] **Step 2: Run pub get**

Run: `fvm flutter pub get`
Expected: Dependencies resolve successfully.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat(hijri): add hijri package dependency"
```

---

### Task 2: Add CalendarType to UserSettings

**Files:**
- Modify: `lib/core/models/user_settings.dart`
- Create: `test/core/models/user_settings_calendar_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/models/user_settings_calendar_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/models/user_settings.dart';

void main() {
  group('CalendarType in UserSettings', () {
    test('default calendarType is gregorian', () {
      const settings = UserSettings();
      expect(settings.calendarType, CalendarType.gregorian);
    });

    test('copyWith updates calendarType', () {
      const settings = UserSettings();
      final updated = settings.copyWith(calendarType: CalendarType.hijri);
      expect(updated.calendarType, CalendarType.hijri);
    });

    test('toJson includes calendarType', () {
      const settings = UserSettings(calendarType: CalendarType.hijri);
      final json = settings.toJson();
      expect(json['calendarType'], 1);
    });

    test('fromJson reads calendarType', () {
      final settings = UserSettings.fromJson({'calendarType': 1});
      expect(settings.calendarType, CalendarType.hijri);
    });

    test('fromJson defaults to gregorian when calendarType missing', () {
      final settings = UserSettings.fromJson({});
      expect(settings.calendarType, CalendarType.gregorian);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/models/user_settings_calendar_test.dart`
Expected: FAIL — `CalendarType` not defined.

- [ ] **Step 3: Add CalendarType enum and field to UserSettings**

In `lib/core/models/user_settings.dart`, add the enum after the `Fiqh` enum:

```dart
enum CalendarType {
  gregorian,
  hijri,
}
```

Add `calendarType` field to `UserSettings`:

```dart
  final CalendarType calendarType;
```

Update constructor default:

```dart
  const UserSettings({
    this.fiqh = Fiqh.sunni,
    this.methodId,
    this.latitude,
    this.longitude,
    this.locationName,
    this.onboardingComplete = false,
    this.notificationTypes = const {},
    this.calendarType = CalendarType.gregorian,
  });
```

Update `copyWith`:

```dart
  UserSettings copyWith({
    Fiqh? fiqh,
    int? methodId,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? onboardingComplete,
    Map<String, NotificationType>? notificationTypes,
    CalendarType? calendarType,
  }) {
    return UserSettings(
      fiqh: fiqh ?? this.fiqh,
      methodId: methodId ?? this.methodId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      notificationTypes: notificationTypes ?? this.notificationTypes,
      calendarType: calendarType ?? this.calendarType,
    );
  }
```

Update `toJson`:

```dart
  Map<String, dynamic> toJson() => {
        'fiqh': fiqh.index,
        'methodId': methodId,
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'onboardingComplete': onboardingComplete,
        'notificationTypes': notificationTypes.map(
          (key, value) => MapEntry(key, value.index),
        ),
        'calendarType': calendarType.index,
      };
```

Update `fromJson` — add before the `return` statement:

```dart
    final calendarIndex = json['calendarType'] as int? ?? 0;
    final calendarType = calendarIndex < CalendarType.values.length
        ? CalendarType.values[calendarIndex]
        : CalendarType.gregorian;
```

And add `calendarType: calendarType,` to the `return UserSettings(...)`.

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/core/models/user_settings_calendar_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/models/user_settings.dart test/core/models/user_settings_calendar_test.dart
git commit -m "feat(hijri): add CalendarType enum and field to UserSettings"
```

---

### Task 3: Add setCalendarType to Settings Provider

**Files:**
- Modify: `lib/features/settings/settings_provider.dart`

- [ ] **Step 1: Add setCalendarType method**

In `lib/features/settings/settings_provider.dart`, add after `setNotificationType`:

```dart
  Future<void> setCalendarType(CalendarType type) async {
    state = state.copyWith(calendarType: type);
    await HiveService.saveSettings(state);
  }
```

Add the import at the top if not already present:

```dart
import '../../core/models/user_settings.dart';
```

Note: No cache clearing needed — calendar type only affects display.

- [ ] **Step 2: Run existing tests**

Run: `fvm flutter test`
Expected: All tests pass (no breaking changes).

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/settings_provider.dart
git commit -m "feat(hijri): add setCalendarType to settings provider"
```

---

### Task 4: Hijri Service

**Files:**
- Create: `lib/core/hijri/hijri_service.dart`
- Create: `test/core/hijri/hijri_service_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/hijri/hijri_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/hijri/hijri_service.dart';

void main() {
  group('HijriService', () {
    group('fromGregorian', () {
      test('converts a known date', () {
        // 2026-04-13 is approximately 15 Shawwal 1448
        final result = HijriService.fromGregorian(DateTime(2026, 4, 13));
        expect(result.day, isA<int>());
        expect(result.monthName, isNotEmpty);
        expect(result.year, greaterThan(1400));
      });

      test('returns valid month name', () {
        final result = HijriService.fromGregorian(DateTime(2026, 1, 1));
        final validMonths = [
          'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
          'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Shaban',
          'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah',
        ];
        expect(validMonths, contains(result.monthName));
      });
    });

    group('fromApiResponse', () {
      test('parses AlAdhan hijri date response', () {
        final hijriJson = {
          'day': '15',
          'month': {'number': 10, 'en': 'Shawwāl'},
          'year': '1448',
        };
        final result = HijriService.fromApiResponse(hijriJson);
        expect(result.day, 15);
        expect(result.monthName, 'Shawwal');
        expect(result.year, 1448);
      });

      test('returns null for invalid response', () {
        final result = HijriService.fromApiResponse({});
        expect(result, isNull);
      });
    });

    group('formatHijriDate', () {
      test('formats as day monthName year', () {
        final date = HijriDate(day: 15, monthName: 'Shawwal', year: 1448);
        expect(HijriService.formatHijriDate(date), '15 Shawwal 1448');
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/hijri/hijri_service_test.dart`
Expected: FAIL — files don't exist.

- [ ] **Step 3: Write the implementation**

Create `lib/core/hijri/hijri_service.dart`:

```dart
import 'package:hijri/hijri_calendar.dart';

class HijriDate {
  final int day;
  final String monthName;
  final int year;

  const HijriDate({
    required this.day,
    required this.monthName,
    required this.year,
  });
}

class HijriService {
  static const _monthNames = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Shaban',
    'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah',
  ];

  /// Convert Gregorian DateTime to HijriDate using the hijri package.
  static HijriDate fromGregorian(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthIndex = hijri.hMonth - 1;
    final monthName = (monthIndex >= 0 && monthIndex < _monthNames.length)
        ? _monthNames[monthIndex]
        : 'Unknown';
    return HijriDate(
      day: hijri.hDay,
      monthName: monthName,
      year: hijri.hYear,
    );
  }

  /// Parse Hijri date from AlAdhan API response.
  /// Response format: { "day": "15", "month": { "number": 10, "en": "Shawwāl" }, "year": "1448" }
  static HijriDate? fromApiResponse(Map<String, dynamic> json) {
    try {
      final dayStr = json['day'] as String?;
      final monthMap = json['month'] as Map<String, dynamic>?;
      final yearStr = json['year'] as String?;

      if (dayStr == null || monthMap == null || yearStr == null) return null;

      final day = int.parse(dayStr);
      final monthNumber = monthMap['number'] as int;
      final year = int.parse(yearStr);

      final monthIndex = monthNumber - 1;
      final monthName = (monthIndex >= 0 && monthIndex < _monthNames.length)
          ? _monthNames[monthIndex]
          : 'Unknown';

      return HijriDate(day: day, monthName: monthName, year: year);
    } catch (_) {
      return null;
    }
  }

  /// Format a HijriDate as "15 Shawwal 1448".
  static String formatHijriDate(HijriDate date) {
    return '${date.day} ${date.monthName} ${date.year}';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/core/hijri/hijri_service_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/hijri/hijri_service.dart test/core/hijri/hijri_service_test.dart
git commit -m "feat(hijri): add HijriService with package conversion and API parsing"
```

---

### Task 5: Parse Hijri Date from API Response

**Files:**
- Modify: `lib/core/models/prayer_times.dart`
- Modify: `lib/core/api/aladhan_api.dart`

- [ ] **Step 1: Add hijriDate field to PrayerTimes model**

In `lib/core/models/prayer_times.dart`, add field:

```dart
  final String? hijriDate; // e.g. "15 Shawwal 1448" — from API
```

Add to constructor, `fromAlAdhanJson`, `withHanafiAsr`, and `copyWith` (if exists). In `fromAlAdhanJson`, accept an optional `hijriDate` parameter:

```dart
  factory PrayerTimes.fromAlAdhanJson(
    Map<String, dynamic> timings,
    DateTime date, {
    String? hijriDate,
  }) {
    return PrayerTimes(
      fajr: timings['Fajr'] as String,
      sunrise: timings['Sunrise'] as String,
      dhuhr: timings['Dhuhr'] as String,
      asr: timings['Asr'] as String,
      maghrib: timings['Maghrib'] as String,
      isha: timings['Isha'] as String,
      date: date,
      source: PrayerTimeSource.api,
      hijriDate: hijriDate,
    );
  }
```

Update `withHanafiAsr` to preserve `hijriDate`:

```dart
  PrayerTimes withHanafiAsr(String hanafi) {
    return PrayerTimes(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      asrHanafi: hanafi,
      maghrib: maghrib,
      isha: isha,
      date: date,
      source: source,
      hijriDate: hijriDate,
    );
  }
```

- [ ] **Step 2: Update AlAdhan API to parse Hijri date**

In `lib/core/api/aladhan_api.dart`, update `parseResponse` to extract and format the Hijri date:

Add import at top:
```dart
import '../hijri/hijri_service.dart';
```

Update `parseResponse`:

```dart
  static PrayerTimes parseResponse(Map<String, dynamic> json, DateTime date) {
    final data = json['data'];
    if (data == null) {
      throw PrayerTimesException('Prayer times service returned an invalid response');
    }
    final timings = data['timings'];
    if (timings == null) {
      throw PrayerTimesException('Prayer times not available for this location');
    }

    // Parse Hijri date from response
    String? hijriDate;
    final hijriJson = data['date']?['hijri'] as Map<String, dynamic>?;
    if (hijriJson != null) {
      final parsed = HijriService.fromApiResponse(hijriJson);
      if (parsed != null) {
        hijriDate = HijriService.formatHijriDate(parsed);
      }
    }

    return PrayerTimes.fromAlAdhanJson(
      timings as Map<String, dynamic>,
      date,
      hijriDate: hijriDate,
    );
  }
```

- [ ] **Step 3: Run all tests**

Run: `fvm flutter test`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/core/models/prayer_times.dart lib/core/api/aladhan_api.dart
git commit -m "feat(hijri): parse Hijri date from AlAdhan API response"
```

---

### Task 6: Update Hive Cache for Hijri Date

**Files:**
- Modify: `lib/core/storage/hive_service.dart`

- [ ] **Step 1: Update cachePrayerTimes to store hijriDate**

In `lib/core/storage/hive_service.dart`, in the `cachePrayerTimes` method, add `hijriDate` to the stored map:

```dart
  'hijriDate': times.hijriDate,
```

- [ ] **Step 2: Update loadCachedPrayerTimes to read hijriDate**

In the `loadCachedPrayerTimes` method, pass `hijriDate` when constructing PrayerTimes:

```dart
  hijriDate: cached['hijriDate'] as String?,
```

- [ ] **Step 3: Run all tests**

Run: `fvm flutter test`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/core/storage/hive_service.dart
git commit -m "feat(hijri): persist Hijri date in prayer times cache"
```

---

### Task 7: Update Dome Header for Two-Line Date

**Files:**
- Modify: `lib/features/prayer_times/widgets/dome_header.dart`
- Modify: `lib/features/prayer_times/prayer_times_screen.dart`

- [ ] **Step 1: Add calendarType and hijriDate props to DomeHeader**

In `lib/features/prayer_times/widgets/dome_header.dart`, add to the widget's fields:

```dart
  final CalendarType calendarType;
  final String? hijriDate;
```

Update the constructor to accept them.

Import:
```dart
import '../../../core/models/user_settings.dart';
import '../../../core/hijri/hijri_service.dart';
```

- [ ] **Step 2: Update date display to two lines**

Replace the single-line date+time text (currently `'$dateStr  ·  $timeStr'`) with:

```dart
  // Date line — depends on calendar type
  final String dateDisplay;
  if (widget.calendarType == CalendarType.hijri) {
    if (widget.hijriDate != null) {
      dateDisplay = widget.hijriDate!;
    } else {
      // Offline fallback — calculate from current date
      final hijri = HijriService.fromGregorian(_now);
      dateDisplay = HijriService.formatHijriDate(hijri);
    }
  } else {
    dateDisplay = DateFormat('EEE, MMM d, y').format(_now);
  }
  final timeStr = DateFormat('h:mm a').format(_now);
```

Replace the single-line Text widget with two lines:

```dart
  Text(
    dateDisplay,
    style: TextStyle(fontSize: 13, color: isDark ? AppColors.sage : AppColors.deepGreen.withValues(alpha: 0.6)),
    textAlign: TextAlign.center,
  ),
  const SizedBox(height: 2),
  Text(
    timeStr,
    style: TextStyle(fontSize: 13, color: isDark ? AppColors.sage.withValues(alpha: 0.6) : AppColors.deepGreen.withValues(alpha: 0.4)),
    textAlign: TextAlign.center,
  ),
```

- [ ] **Step 3: Adjust textTop for extra line**

Change `textTop` from `containerHeight * 0.65` to `containerHeight * 0.58`. This may need tuning on device.

- [ ] **Step 4: Update PrayerTimesScreen to pass new props**

In `lib/features/prayer_times/prayer_times_screen.dart`, update the `DomeHeader` widget call to pass `calendarType` and `hijriDate`:

```dart
  DomeHeader(
    locationName: settings.locationName ?? 'Unknown',
    latitude: settings.latitude,
    longitude: settings.longitude,
    isOffline: times.isOffline,
    calendarType: settings.calendarType,
    hijriDate: times.hijriDate,
  ),
```

- [ ] **Step 5: Run all tests**

Run: `fvm flutter test`
Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/features/prayer_times/widgets/dome_header.dart lib/features/prayer_times/prayer_times_screen.dart
git commit -m "feat(hijri): two-line date in dome header with calendar type support"
```

---

### Task 8: Add Calendar Section to Settings Screen

**Files:**
- Modify: `lib/features/settings/settings_screen.dart`

- [ ] **Step 1: Reorder sections and add Calendar**

In `lib/features/settings/settings_screen.dart`, reorder the sections in the ListView children to:

1. Fiqh
2. Calculation Method
3. Location
4. Notifications
5. Calendar (new)

Add the Calendar section at the bottom using the same tile style as Fiqh:

```dart
  // Calendar
  const SizedBox(height: 24),
  const _SectionHeader('Calendar'),
  const SizedBox(height: 8),
  ...CalendarType.values.map((t) => _CalendarTile(
        calendarType: t,
        isSelected: settings.calendarType == t,
        isDark: isDark,
        onTap: () => ref.read(settingsProvider.notifier).setCalendarType(t),
      )),
```

- [ ] **Step 2: Create _CalendarTile widget**

Add a new private widget class (similar to `_FiqhTile`):

```dart
class _CalendarTile extends StatelessWidget {
  final CalendarType calendarType;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CalendarTile({
    required this.calendarType,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  String get label {
    switch (calendarType) {
      case CalendarType.gregorian:
        return 'Gregorian';
      case CalendarType.hijri:
        return 'Hijri (Islamic)';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same structure as _FiqhTile — container with label and optional checkmark
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final checkColor = isDark ? AppColors.sage : AppColors.deepGreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: checkColor, size: 20),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run all tests**

Run: `fvm flutter test`
Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/settings_screen.dart
git commit -m "feat(hijri): add Calendar setting, reorder settings sections"
```

---

### Task 9: Push and Verify

- [ ] **Step 1: Run full test suite**

Run: `fvm flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run flutter analyze**

Run: `fvm flutter analyze`
Expected: No new errors.

- [ ] **Step 3: Push to remote**

```bash
git push origin feat/hijri-calendar
```

- [ ] **Step 4: Deploy to device and verify**

Run: `fvm flutter run -d 57301JEBF06408 --release`

Verify:
- Dome header shows Gregorian date on two lines (date + time)
- Settings → Calendar section at bottom with Gregorian/Hijri toggle
- Switch to Hijri → dome header shows Hijri date
- Switch back to Gregorian → dome header shows Gregorian date
- Kill and reopen app → calendar preference persisted
- Take phone screenshot via adb to verify layout
