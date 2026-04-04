## Context

The Khushu MVP is running on device for the first time. Three issues were found during testing:
1. The dome CustomPaint SVG has its arc direction inverted — `arcToPoint` uses `clockwise: false` which draws downward instead of upward
2. The onboarding screen adds friction — fiqh selection and combine-prayers are already in settings, so there's no reason to block users before showing prayer times
3. First-time users need a location, but the current GPS flow has been unreliable

## Goals / Non-Goals

**Goals:**
- Fix dome arc to render correctly (upward curve, minarets pointing up, C-shaped crescent with upward tilt)
- Remove onboarding screen and go straight to prayer times
- Silently detect GPS location on first launch with a user-friendly fallback
- Default to Sunni Standard (Maliki, Shafi'i, Hanbali) fiqh for new users

**Non-Goals:**
- Redesigning the prayer times screen layout
- Changing the settings screen
- Adding new features

## Decisions

### 1. Remove onboarding entirely, not just skip it

**Choice**: Delete onboarding screen files and route, not just hide them.

**Rationale**: Dead code adds confusion. Fiqh selection lives in settings. Location is handled by the prayer times screen on first launch.

### 2. Location prompt as a dialog overlay, not a separate screen

**Choice**: When GPS fails on first launch, show a dialog on the prayer times screen with a city search field and a message explaining why location is needed.

**Rationale**: Keeps the user on the main screen. They can see the app structure while entering their city. Less disorienting than a blank screen.

### 3. Fix dome via arc direction, not redraw

**Choice**: Change the `arcToPoint` clockwise parameter and adjust minaret line coordinates. Keep the same CustomPaint approach.

**Rationale**: The SVG structure is correct — just the arc direction and coordinate offsets are wrong. Minimal change, minimal risk.

## Risks / Trade-offs

- **[No fiqh selection on first launch]** → New users get Sunni Standard by default. If they follow Hanafi or Jafari, they need to go to settings to change. Acceptable for MVP since most users won't notice until Asr time differs.
- **[GPS still unreliable]** → Mitigated by the fallback dialog with city search. The dialog is not dismissable without setting a location, so users can't get stuck.
