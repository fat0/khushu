# Hijri Calendar — Design Spec

## Overview

Add optional Hijri (Islamic) date display to Khushu. Users choose between Gregorian and Hijri in Settings. The selected calendar's date appears in the dome header, replacing the current single-line date+time with a two-line layout.

## Approach

**Hijri Dart package + AlAdhan API fallback.** A dedicated Hijri date package handles offline conversion. The AlAdhan API response already includes Hijri date data — parse and use it when available.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Calendar options | Gregorian or Hijri (simple toggle) | YAGNI — no "both" option for now |
| Default | Gregorian | Most users expect Gregorian by default |
| Hijri source | AlAdhan API + Hijri package offline fallback | Matches prayer times pattern (API first, offline fallback) |
| Gregorian format | `Mon, Apr 13, 2026` | Weekday + month + day + year |
| Hijri format | `15 Shawwal 1447` | Day + month name + year, no weekday |
| Date/time layout | Two lines (date above, time below) | Single line too long with year added |
| Settings placement | Bottom of settings screen, after Notifications | New "Calendar" section |
| Weekday in Hijri | No | Can add later if needed |

## Data Flow

1. Prayer times fetched from AlAdhan API → Hijri date parsed from `data.date.hijri` → stored in Hive cache with prayer times
2. If offline (adhan-dart fallback) → Hijri package converts current Gregorian date locally
3. Settings provider stores `calendarType` (Gregorian or Hijri, default Gregorian)
4. Dome header reads `calendarType` and displays the appropriate date format
5. Time always shown on second line regardless of calendar type

## Settings & Storage

- `CalendarType` enum: `gregorian`, `hijri`
- Added to `UserSettings` model, persisted in Hive
- Default: `gregorian`
- Changing calendar type updates dome header immediately (reactive via Riverpod)
- No cache clearing needed — only changes date display, not prayer times data

## Settings Screen

- Reorder existing sections (currently: Fiqh, Calculation Method, Notifications, Location)
- New order: Fiqh, Calculation Method, Location, Notifications, Calendar
- New "Calendar" section at the bottom
- Same tile style as Fiqh selector — two radio options: Gregorian, Hijri

## Dome Header Changes

- Split current `"Mon, Apr 13 · 12:22 AM"` into two lines
- Line 1: date (Gregorian or Hijri depending on setting)
- Line 2: time (`12:22 AM`)
- `textTop` adjusted from `containerHeight * 0.65` to ~0.55–0.60 (tuned on device)
- New props: `calendarType`, `hijriDate` (optional)

## File Structure

```
lib/
  core/
    models/
      user_settings.dart        # Add CalendarType enum + field
    hijri/
      hijri_service.dart        # Hijri date conversion (package + API parsing)
  features/
    prayer_times/
      widgets/
        dome_header.dart        # Two-line date, calendar-aware
      prayer_times_provider.dart # Parse Hijri from API response, fallback to package
    settings/
      settings_screen.dart      # Add Calendar section at bottom
      settings_provider.dart    # Persist calendarType
```

## Dependencies

| Package | Purpose | Status |
|---------|---------|--------|
| `hijri` | Gregorian → Hijri conversion (offline) | New — add to pubspec |
| AlAdhan API | Hijri date in prayer times response | Already used |

## Testing

- Unit tests for `hijri_service.dart` (known date conversions, API response parsing)
- Widget test for dome header (Gregorian mode, Hijri mode)
- Widget test for settings screen (Calendar section renders, toggle works)
- Manual test on device — verify dome header layout with both calendar types
- Manual test — verify offline Hijri date matches API Hijri date

## Out of Scope

- Browsable Hijri calendar view
- Arabic weekday names
- "Both calendars" display option
- Hijri date notifications
