# Khushu Roadmap

## MVP (Implemented)
- Prayer times for Sunni (Maliki/Hanbali/Shafi'i + Hanafi) and Shia (Ja'fari) fiqh schools
  - GPS auto-detect location on first launch with dialog fallback if GPS fails
  - Auto-detect regional calculation method from user's location
  - API-only prayer times (AlAdhan API) with daily caching
  - Main screen: dome header (SVG), current prayer with countdown to next, all prayer times for the day, current date, location name
  - Current prayer highlighted in the prayer list
  - Settings: fiqh (juristic method), calculation method override, location
  - Theme follows system light/dark mode automatically
  - Debug logging (auto on in debug builds, off in release)

## Design Decisions
- **Framework:** Flutter (Dart) — cross-platform, adhan-dart library available
- **Color palette:** "Garden of Peace" — sage green (#A8C5A0), sand (#D4C9A8), cream (#F5F1EA), deep green (#3D5A3A), charcoal (#2C2C2C)
- **Visual style:** Calm, peaceful, wellness-inspired — minimal and uncluttered
- **Typography:** Light weight, generous spacing
- **Header motif:** Line art half-circle dome + tilted crescent moon (open right) + two simple minarets (parallel lines, pointed tops, open bottom) — all in single-weight outline style
- **Mission statement:** "One Ummah Serving Allah"
- **First launch:** No onboarding — GPS auto-detects location silently, dialog fallback if it fails. Default fiqh: Maliki/Hanbali/Shafi'i. User changes fiqh in settings.
- **API approach:** AlAdhan API with two key params — `method` (auto-detected by region) and `school` (0=standard, 1=Hanafi)
- **Dome header:** SVG asset (reference image), text positioned at 65% from top, SVG scaled 1.5x width with bottom 25% cropped

## Future Features
1. Prayer guide — tap any prayer row to see rakat breakdown (fard, sunnah/nafilah, witr) per user's fiqh. Helps reverts, kids, and learners. Sunrise shows "Marks the end of Fajr time — no prayer."
2. Hijri calendar
3. Adhan alerts with audio playback per prayer
4. Offline prayer time calculation (on-device via adhan-dart)
5. Qibla compass
6. Multi-language support (Arabic, English, Urdu, Turkish, French)
7. Optional in-app donations
8. Dual source mode — adhan-dart for offline + AlAdhan API for cross-validation
