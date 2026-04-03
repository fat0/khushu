# Khushu MVP — Design Spec

## Overview

Khushu (خشوع) is a cross-platform Islamic prayer times app built with Flutter. It supports Sunni and Shia prayer time calculations — promoting unity across the Ummah.

**Mission:** One Ummah Serving Allah

## Problem

Most prayer apps only support Sunni or Shia calculation methods. Salaat is shared by all Muslims and we want to foster Ummatic unity by accommodating each other's prayer schedules.

## Solution

A free, ad-free, open source prayer app that provides accurate prayer times for both Sunni and Shia traditions from a single, calm, welcoming interface. The app auto-detects the best regional calculation method and asks one simple question about the user's prayer tradition.

## MVP Scope

The MVP is focused exclusively on prayer times. All other features are deferred to the roadmap.

### Screens

**1. Onboarding (single screen)**
- "One Ummah Serving Allah" mission statement at top
- GPS location permission prompt — auto-detects regional calculation method
- If GPS denied, falls back to manual city search
- One simple question: "Which tradition do you follow?"
  - Sunni (Standard Asr)
  - Sunni (Hanafi Asr)
  - Shia (Jafari)
- Selection maps to API parameters:
  - Sunni Standard → regional method (auto-detected) + `school=0`
  - Sunni Hanafi → regional method (auto-detected) + `school=1`
  - Shia Jafari → `method=0` (Qum) + `school=0`
- Navigates straight to prayer times

**Regional method auto-detection:**
| User's region | AlAdhan method |
|---------------|----------------|
| North America | ISNA (2) |
| Europe | MWL (3) |
| Saudi Arabia | Umm Al-Qura (4) |
| Egypt / Africa | Egyptian (5) |
| Pakistan / India | Karachi (1) |
| Gulf states | Gulf (8) |
| Turkey | Turkey (13) |
| SE Asia | JAKIM (17) / Kemenag (20) |
| Iran (Shia) | Tehran (7) |
| Default | MWL (3) |

**2. Prayer Times (main screen)**
- Header: line art dome motif with app name, location, and date inside
- Next prayer card: prayer name + countdown timer
- Prayer times list: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha (always 6 rows for all traditions)
- "Combine prayers" toggle — available to all users (Sunni travelers, Jafari daily practice)
  - When enabled, Dhuhr+Asr shown as one combined row, Maghrib+Isha as one combined row
- Current/next prayer highlighted with accent bar
- Current date displayed
- Location name displayed

**3. Settings**
- Change tradition (Sunni Standard / Sunni Hanafi / Shia Jafari)
- Override calculation method (full list of all 20+ methods for power users)
- Change location (GPS auto-detect or manual city search)
- Toggle combine prayers
- Toggle light/dark mode

### Data Flow

1. App requests GPS location → coordinates stored in Hive
2. App auto-detects regional calculation method from coordinates
3. User selects tradition (Sunni Standard / Sunni Hanafi / Shia Jafari) → stored in Hive
4. App fetches prayer times from AlAdhan API using method + school + coordinates
5. Prayer times cached in Hive for the day
6. On next app open, cached times displayed immediately
7. Cache refreshed daily or when location/tradition changes

## Architecture

### Framework
- **Flutter 3.19+** — single codebase for Android and iOS
- **Dart** — Flutter's language, with adhan-dart library available for future offline calculation

### State Management
- **Riverpod** — manages reactive data flow (madhab selection → prayer time updates propagate everywhere)

### Local Storage
- **Hive** — lightweight, pure-Dart NoSQL database for:
  - User settings (tradition, calculation method, location, theme, combine prayers)
  - Cached prayer times (daily)

### Prayer Times Source (MVP)
- **AlAdhan API** — free, trusted Islamic prayer times API
  - Endpoint: `https://api.aladhan.com/v1/timings`
  - Two key parameters: `method` (0-23, calculation angles) and `school` (0=standard, 1=Hanafi Asr)
  - Cached daily — only needs internet once per day

### Project Structure
```
lib/
  core/              # Theme, storage, utils, API client
  features/
    prayer_times/    # Prayer time fetching, display, caching
    onboarding/      # Mission statement + madhab selection
    settings/        # User preferences
  navigation/        # GoRouter config
```

### Key Dependencies
- `flutter_riverpod` — state management
- `hive` + `hive_flutter` — local storage
- `dio` — API calls to AlAdhan (better error handling, interceptors for caching)
- `geolocator` — GPS location
- `geocoding` — city name ↔ coordinates
- `go_router` — navigation

## Visual Design

### Color Palette — "Garden of Peace"
| Name | Hex | Usage |
|------|-----|-------|
| Sage | #A8C5A0 | Accent color, active states, dates |
| Sand | #D4C9A8 | Highlighted prayer row background |
| Cream | #F5F1EA | Light mode background |
| Deep Green | #3D5A3A | Primary text (light mode), next prayer card |
| Charcoal | #2C2C2C | Dark mode background |

### Dark Mode
- Background: charcoal (#1E1E1C)
- Primary text: sage (#A8C5A0)
- Secondary text: muted gray (#6b6b62 / #8a8a80)
- Card backgrounds: dark earth (#2A2A27)
- Next prayer card: dark green gradient (#2A4228 → #3D5A3A)
- Follows system theme by default, overridable in settings

### Typography
- Light weight (300) for prayer names and large text
- Semi-bold (600) for prayer times and headings
- Generous letter-spacing on headings
- System font stack (San Francisco on iOS, Roboto on Android)

### Header Motif
- Line art half-circle dome outline
- Two simple minarets (parallel vertical lines, pointed tops, open bottom)
- Tilted crescent moon on top of dome (open side facing right)
- Single consistent line weight, low opacity
- App name (KHUSHU), location, and date sit inside the dome
- Sage green stroke in light mode, same color lower opacity in dark mode

### Style Principles
- Calm, peaceful, wellness-inspired
- Minimal — no busy patterns, no geometric ornaments, no clutter
- Generous whitespace and rounded corners (12-16px border radius)
- Subtle depth via soft shadows, not borders

## Environments

| Env | App ID | Purpose |
|-----|--------|---------|
| Debug | `com.khushu.app.debug` | Local development |
| Release | `com.khushu.app` | Play Store + App Store |

## Risks

- **AlAdhan API downtime:** Mitigated by daily caching — app only needs API once per day. Offline calculation (adhan-dart) is on the roadmap.
- **Jafari accuracy:** AlAdhan API supports two Shia methods — Qum (method 0) and Tehran (method 7). Tehran available as override in settings for users who prefer it.
- **GPS permission denied:** Falls back to manual city entry. App remains fully functional.

## Out of Scope (Future Roadmap)

1. Adhan alerts with audio
2. Qibla compass
3. Hijri calendar
4. Multi-language support (Arabic, English, Urdu, Turkish, French)
5. Optional in-app donations
6. Offline prayer time calculation (adhan-dart)
7. Dual source mode (adhan-dart + AlAdhan cross-validation)
