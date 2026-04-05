# Khushu خشوع

**One Ummah Serving Allah**

A learner-friendly Islamic prayer app with a clean, simple interface to help you wherever you are in your salat learning journey.

## Features

- **Accurate prayer times** for both Sunni and Shia fiqhs via the [AlAdhan API](https://aladhan.com)
- **Dual Asr times** — shows both standard (Maliki, Hanbali, Shafi'i) and Hanafi calculations
- **Prayer guide** — tap any prayer to see rakat breakdown (fard, sunnah/nafilah, witr) for your fiqh
- **Fiqh-aware terminology** — "Sunnah" for Sunni, "Nafilah" for Ja'fari
- **Auto-detect location** — GPS with manual city fallback
- **Regional calculation methods** — auto-selects ISNA, MWL, Umm Al-Qura, etc. based on your location
- **Light & dark mode** — follows your system theme
- **Calm, minimal design** — Garden of Peace color palette

## Supported Fiqhs

| Fiqh | Prayer Times | Rakat Guide |
|------|-------------|-------------|
| Sunni (Maliki, Hanafi, Hanbali, Shafi'i) | Dual Asr times | Sunnah + Fard + Witr |
| Shia (Ja'fari) | Qum calculation | Nafilah + Fard |

Ja'fari rakat data verified against Ayatollah Sistani's *Tawdih al-Masa'il* (Ruling 751). See [docs/fiqh-sources.md](docs/fiqh-sources.md) for all sources.

## Tech

- **Flutter** (Dart) — cross-platform Android & iOS
- **Riverpod** — state management
- **Hive** — local caching (prayer times cached daily)
- **AlAdhan API** — prayer time calculations
- **FVM** — Flutter version management

## Development

```bash
# Install FVM if you don't have it
dart pub global activate fvm

# Install Flutter version pinned to this project
fvm install

# Get dependencies
fvm flutter pub get

# Run on connected device
fvm flutter run

# Run tests
fvm flutter test
```

## Roadmap

1. **Prayer guide** — tap to see rakat counts per fiqh *(done)*
2. Hijri calendar
3. Adhan alerts with audio
4. Offline prayer calculation (adhan-dart)
5. Qibla compass
6. Multi-language support
7. App Store & Play Store release

## License

Open source. Free. Ad-free. For the Ummah.
