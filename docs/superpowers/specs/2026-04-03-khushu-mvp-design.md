# Khushu MVP — Design Spec

## Overview

Khushu (خشوع) is a cross-platform Islamic prayer times app built with Flutter. It supports different Sunni and Shia prayer time calculations — promoting unity across the Ummah.

**Mission:** One Ummah Serving Allah

## Problem

Most prayer apps only support Sunni or Shia calculation methods, and none help you learn how to pray. Salaat is shared by all Muslims — reverts, children, and lifelong practitioners alike deserve a single app that meets them wherever they are in their learning journey.

## Solution

A free, ad-free, open source prayer app with a clean, simple interface that helps you wherever you are along your salaat learning journey. It provides accurate prayer times for both Sunni and Shia fiqhs, shows rakat breakdowns per prayer per fiqh, and promotes Ummatic unity by treating all fiqhs as first-class citizens.

## MVP Scope

The MVP is focused exclusively on prayer times. All other features are deferred to the roadmap.

### First Launch

No onboarding screen. On first launch:
- GPS auto-detects location silently in the background
- If GPS fails, a dialog prompts the user to enter their city (with explanation of why location is needed)
- Default fiqh: Maliki/Hanbali/Shafi'i (school=0). User changes in settings.
- App goes straight to the prayer times screen

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

### Screens

**1. Prayer Times (main screen)**
- Header: SVG dome motif with app name ("KHUSHU"), "One Ummah Serving Allah", location, and date inside the dome
- Current prayer card: horizontal layout — current prayer name on left, countdown to next prayer on right
- Prayer times list: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha (always 6 rows for all fiqhs)
- Current prayer highlighted in the list
- Current date displayed inside dome
- Location name displayed inside dome

**2. Settings**
- Fiqh (Juristic Method): Maliki/Hanbali/Shafi'i | Hanafi | Ja'fari
- Calculation Method: dropdown of all AlAdhan methods (auto-detected by default)
- Location: GPS auto-detect or manual city search
- Theme follows system light/dark mode automatically (no user toggle)

### Data Flow

1. App requests GPS location silently → coordinates stored in Hive
2. If GPS fails, dialog prompts user to enter city → geocoded to coordinates
3. App auto-detects regional calculation method from coordinates
4. Default fiqh: Maliki/Hanbali/Shafi'i (school=0) → stored in Hive
5. App fetches prayer times from AlAdhan API using method + school + coordinates
6. Prayer times cached in Hive for the day
7. On next app open, cached times displayed immediately
8. Cache cleared and refreshed when location, fiqh, or calculation method changes

## Architecture

### Framework
- **Flutter 3.19+** — single codebase for Android and iOS
- **Dart** — Flutter's language, with adhan-dart library available for future offline calculation

### State Management
- **Riverpod** — manages reactive data flow (madhab selection → prayer time updates propagate everywhere)

### Local Storage
- **Hive** — lightweight, pure-Dart NoSQL database for:
  - User settings (fiqh, calculation method, location, theme, combine prayers)
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
- Follows system theme automatically (no user toggle)

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
- **GPS permission denied or fails:** Falls back to dialog prompting manual city entry. App remains fully functional.

## Out of Scope (Future Roadmap)

1. Adhan alerts with audio
2. Qibla compass
3. Hijri calendar
4. Multi-language support (Arabic, English, Urdu, Turkish, French)
5. Optional in-app donations
6. Offline prayer time calculation (adhan-dart)
7. Dual source mode (adhan-dart + AlAdhan cross-validation)
