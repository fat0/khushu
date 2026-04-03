# Khushu Roadmap

## MVP
- Prayer times for all 6 madhabs (Hanafi, Maliki, Shafi'i, Hanbali, Jafari, Zaidi)
  - GPS auto-detect + manual city search for location
  - API-only prayer times (AlAdhan API) with daily caching
  - Main screen: current/next prayer with countdown, all prayer times for the day, current date, location name
  - Jafari: 3 combined time windows (Dhuhr+Asr, Maghrib+Isha)
  - Zaidi: user choice between combined or separate display
  - Onboarding: single screen with mission statement + madhab selection
  - Light and dark mode

## Design Decisions
- **Framework:** Flutter (Dart) — cross-platform, adhan-dart library available
- **Color palette:** "Garden of Peace" — sage green (#A8C5A0), sand (#D4C9A8), cream (#F5F1EA), deep green (#3D5A3A), charcoal (#2C2C2C)
- **Visual style:** Calm, peaceful, wellness-inspired — minimal and uncluttered
- **Typography:** Light weight, generous spacing
- **Header motif:** Line art half-circle dome + tilted crescent moon (open right) + two simple minarets (parallel lines, pointed tops, open bottom) — all in single-weight outline style
- **Mission statement:** "One Ummah Serving Allah"
- **Onboarding:** Single screen — mission statement at top, flat list of 6 madhabs below

## Future Features
1. Adhan alerts with audio playback per prayer
2. Qibla compass
3. Hijri calendar
4. Multi-language support (Arabic, English, Urdu, Turkish, French)
5. Optional in-app donations
6. Offline prayer time calculation (on-device via adhan-dart)
7. Dual source mode — adhan-dart for offline + AlAdhan API for cross-validation
