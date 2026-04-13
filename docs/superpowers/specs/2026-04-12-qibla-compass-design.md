# Qibla Compass — Design Spec

## Overview

A Qibla compass feature for Khushu that helps users find the direction of the Ka'bah for prayer. Accessible from the main prayer times screen via a Ka'bah icon button, opening a full-screen compass experience.

## Approach

**flutter_qiblah All-In-One** — let the `flutter_qiblah` package handle compass stream, Qibla bearing, and sensor accuracy detection. Use the `adhan` package (already installed) as fallback for devices without a magnetometer.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Package | `flutter_qiblah` | All-in-one: compass stream, bearing, calibration detection |
| No-magnetometer fallback | Show bearing in degrees only | Inclusive — budget phones common in Muslim-majority countries |
| Calibration | Auto-prompt on low accuracy + manual button | Covers both novice and experienced users |
| Orientation | Portrait only | Matches rest of Khushu |
| Lock feature | No | Find direction, close, pray |
| Distance to Ka'bah | No | Keep it minimal |
| Haptic feedback | No | Visual alignment indicator only |
| Icon | 3D isometric Ka'bah outline in circle, 48px | Matches settings gear size, Garden of Peace palette |
| Icon placement | Bottom-left of prayer times screen | Mirrors settings gear on bottom-right |
| Settings button | Do not modify | Existing design is final |

## Architecture & Data Flow

```
┌─────────────────────────────────────────────┐
│              Prayer Times Screen            │
│                                             │
│  ┌──────────┐              ┌──────────────┐ │
│  │ Ka'bah   │              │ Settings     │ │
│  │ Button   │              │ Gear         │ │
│  └────┬─────┘              └──────────────┘ │
│       │ tap                                 │
└───────┼─────────────────────────────────────┘
        ▼
┌─────────────────────────────────────────────┐
│         Full-Screen Qibla Compass           │
│                                             │
│  qiblaProvider (Riverpod)                   │
│    ├─ FlutterQiblah.qiblahStream            │
│    │   → heading, qiblaDirection, offset    │
│    ├─ Calibration status (accuracy check)   │
│    └─ No-magnetometer fallback              │
│         → adhan Qibla.qibla(coords)         │
│         → static bearing display            │
└─────────────────────────────────────────────┘
```

**Flow:**

1. User taps Ka'bah button on prayer times screen
2. GoRouter navigates to `/qibla`
3. `qiblaProvider` checks if magnetometer exists (via `FlutterQiblah.androidDeviceSensorCheck()` on Android; iOS always has a magnetometer)
4. **Has magnetometer:** Streams live compass data — UI rotates compass needle in real-time
5. **No magnetometer:** Calculates static bearing from GPS coords using `adhan` package's `Qibla.qibla(coordinates)`, shows degrees + direction text
6. If sensor accuracy is low, auto-shows calibration overlay (figure-8 animation + instructions)

## File Structure

```
lib/
  core/
    qibla/
      qibla_service.dart        # Wrapper around FlutterQiblah + adhan fallback
  features/
    qibla/
      qibla_screen.dart         # Full-screen compass UI
      qibla_provider.dart       # Riverpod provider for compass state
      widgets/
        compass_widget.dart     # Rotating compass with needle pointing to Qibla
        calibration_overlay.dart # Figure-8 animation + instructions
        static_bearing.dart     # No-magnetometer fallback (degrees + direction)
        qibla_button.dart       # Ka'bah icon button for prayer times screen
```

### Components

- **`qibla_service.dart`** — checks sensor availability, provides compass stream or static bearing. Single source of truth for Qibla data.
- **`qibla_provider.dart`** — Riverpod `StreamProvider` wrapping the service. Exposes `heading`, `qiblaDirection`, `offset`, `sensorAvailable`, `calibrationNeeded`.
- **`compass_widget.dart`** — the main compass visual. Rotating disc with cardinal directions, Ka'bah indicator at Qibla angle. Glows sage green when aligned within 5 degrees.
- **`calibration_overlay.dart`** — semi-transparent overlay with figure-8 animation and instructional text. Shows automatically on low accuracy, dismissible. Also accessible via manual button.
- **`static_bearing.dart`** — fallback UI showing bearing in degrees with direction (e.g., "58.2° NE") and a static arrow.
- **`qibla_button.dart`** — 48px circular Ka'bah icon button, placed bottom-left of prayer times screen.

## Full-Screen Compass UI

**Layout (top to bottom):**

- App bar with back arrow + "Qibla Compass" title
- Large circular compass centered on screen
  - Outer ring with degree markings (0°, 90°, 180°, 270°) and cardinal letters (N, E, S, W)
  - Entire compass rotates with phone heading
  - Ka'bah indicator fixed at the Qibla bearing angle
  - Aligned within 5° → indicator glows sage green
- Bearing readout below compass (e.g., "58.2° NE")
- "Calibrate" text button at bottom, always visible
- Calibration overlay when triggered (auto or manual)

**Colors (Garden of Peace):**

- Background: charcoal (#1E1E1C)
- Compass ring/markings: sage (#A8C5A0) at low opacity
- Ka'bah indicator: sage, brighter when aligned
- Alignment glow: sage green with subtle radial glow
- Bearing text: sage
- Cardinal N: slightly brighter than E/S/W

**Animation:**

- Compass rotation: smooth, low-pass filtered (no jitter)
- Alignment glow: gentle fade in/out crossing the 5° threshold

## Ka'bah Button Icon

3D isometric Ka'bah outline inside a circle. Sage stroke (#A8C5A0) on dark surface (#2A2A27) with subtle border. Features: cube with front/top/right faces, hizam band, and door. 48px diameter to match settings gear button.

SVG reference saved in `.superpowers/brainstorm/39301-1776041086/content/kaabah-button-only.html`.

## Dependencies

| Package | Purpose | Status |
|---------|---------|--------|
| `flutter_qiblah` | Compass stream + Qibla bearing | New — add to pubspec |
| `flutter_compass` | Sensor accuracy for calibration detection | New — add to pubspec (transitive dep of flutter_qiblah, pin explicitly) |
| `adhan` | Qibla.qibla() for no-magnetometer fallback | Already installed |
| `geolocator` | GPS coordinates | Already installed |

**Note:** `flutter_qiblah` does not expose sensor accuracy in its `QiblahDirection` model. We read `FlutterCompass.events` directly for the `accuracy` field to power calibration prompts.

## Android Build Changes

`flutter_qiblah` requires:
- `compileSdk` bumped to 36
- `minSdk` set to 23
- AGP upgraded to 8.9.1

These changes are already staged on this branch.

## Testing

- Unit tests for `qibla_service.dart` (sensor check, bearing calculation fallback)
- Widget tests for compass UI states (loading, compass active, no-magnetometer, calibration overlay)
- Manual test on device with magnetometer (live compass)
- Manual test on emulator (no magnetometer — verify fallback)

## Out of Scope

- Landscape orientation
- Haptic feedback
- Distance to Ka'bah display
- Lock/freeze compass reading
- Map view
