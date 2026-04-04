## Why

The MVP has three UX issues discovered during first device testing: the dome header SVG is rendering upside-down (arc curves downward, minarets point outward like horns), the onboarding screen adds unnecessary friction since fiqh selection and combine-prayers are available in settings, and first-time users are blocked by a screen before they can see prayer times.

## What Changes

- **Fix dome header** — flip the dome arc to curve upward, minarets point up, crescent moon shaped like a "C" with a slight upward tilt on the opening
- **Remove onboarding screen** — app launches directly to prayer times screen
- **Silent GPS on first launch** — auto-detect location in the background on first launch. If GPS fails, show a helpful prompt explaining why location is needed ("We need your location to calculate accurate prayer times for your area") with a way to set it manually
- **Default fiqh** — new users default to Sunni Standard (Maliki, Shafi'i, Hanbali). Changeable in settings
- **Remove onboarding route** — clean up GoRouter to remove `/onboarding` route, set `/prayer-times` as initial route

## Capabilities

### New Capabilities
- `first-launch-location`: Silent GPS detection on first launch with user-friendly fallback prompt when location cannot be determined

### Modified Capabilities
<!-- No existing openspec specs to modify — this is our first spec-tracked change -->

## Impact

- **Files modified:**
  - `lib/features/prayer_times/widgets/dome_header.dart` — fix SVG arc direction, minaret orientation, crescent moon shape
  - `lib/features/prayer_times/prayer_times_screen.dart` — add first-launch location detection with fallback prompt
  - `lib/navigation/app_router.dart` — remove onboarding route, always start at prayer times
  - `lib/core/models/user_settings.dart` — default fiqh already Sunni Standard (no change needed)
- **Files removed:**
  - `lib/features/onboarding/onboarding_screen.dart`
  - `lib/features/onboarding/onboarding_provider.dart`
- **No API or dependency changes**
