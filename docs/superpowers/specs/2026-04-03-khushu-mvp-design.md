# Khushu MVP — Design Spec

## Overview

Khushu (خشوع) is a cross-platform Islamic prayer times app built with Flutter. It supports all 6 major madhabs — Hanafi, Maliki, Shafi'i, Hanbali (Sunni) and Jafari, Zaidi (Shia) — promoting unity across the Ummah.

**Mission:** One Ummah Serving Allah

## Problem

Existing prayer apps in app stores serve either Sunni or Shia Muslims, reinforcing sectarian divisions. There is no single prayer app that treats all madhabs as first-class citizens.

## Solution

A free, ad-free, open source prayer app that provides accurate prayer times for all 6 madhabs from a single, calm, welcoming interface. No sect is labeled or grouped — users simply pick their madhab by name.

## MVP Scope

The MVP is focused exclusively on prayer times. All other features are deferred to the roadmap.

### Screens

**1. Onboarding (single screen)**
- "One Ummah Serving Allah" mission statement at top
- Flat list of 6 madhabs below: Hanafi, Maliki, Shafi'i, Hanbali, Jafari, Zaidi
- No Sunni/Shia grouping — all presented equally
- Selecting a madhab triggers GPS location permission prompt, then navigates to prayer times
- If GPS is denied, falls back to manual city search

**2. Prayer Times (main screen)**
- Header: line art dome motif with app name, location, and date inside
- Next prayer card: prayer name + countdown timer
- Prayer times list for the day:
  - Sunni madhabs + Zaidi (default): Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha (6 rows)
  - Jafari: Fajr, Sunrise, Dhuhr+Asr (combined), Maghrib+Isha (combined) (4 rows)
  - Zaidi: user can toggle between combined and separate display
- Current/next prayer highlighted with accent bar
- Current date displayed
- Location name displayed

**3. Settings**
- Change madhab (flat list of 6)
- Change location (GPS auto-detect or manual city search)
- Toggle light/dark mode
- Zaidi users: toggle combined/separate prayer display

### Data Flow

1. User selects madhab during onboarding → stored in Hive
2. App requests GPS location → coordinates stored in Hive
3. App fetches prayer times from AlAdhan API using madhab + coordinates
4. Prayer times cached in Hive for the day
5. On next app open, cached times displayed immediately
6. Cache refreshed daily or when location/madhab changes

## Architecture

### Framework
- **Flutter 3.19+** — single codebase for Android and iOS
- **Dart** — Flutter's language, with adhan-dart library available for future offline calculation

### State Management
- **Riverpod** — manages reactive data flow (madhab selection → prayer time updates propagate everywhere)

### Local Storage
- **Hive** — lightweight, pure-Dart NoSQL database for:
  - User settings (madhab, location, theme preference)
  - Cached prayer times (daily)

### Prayer Times Source (MVP)
- **AlAdhan API** — free, trusted Islamic prayer times API
  - Endpoint: `https://api.aladhan.com/v1/timings`
  - Supports all 6 madhabs via calculation method parameters
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
- **Jafari/Zaidi accuracy:** AlAdhan API supports Jafari (method 0/7) and general Shia methods. Zaidi may need custom parameters — will validate against known correct times during development.
- **GPS permission denied:** Falls back to manual city entry. App remains fully functional.

## Out of Scope (Future Roadmap)

1. Adhan alerts with audio
2. Qibla compass
3. Hijri calendar
4. Multi-language support (Arabic, English, Urdu, Turkish, French)
5. Optional in-app donations
6. Offline prayer time calculation (adhan-dart)
7. Dual source mode (adhan-dart + AlAdhan cross-validation)
