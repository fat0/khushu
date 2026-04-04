## 1. Fix Dome Header

- [x] 1.1 Fix dome arc direction in `dome_header.dart` — change `arcToPoint` to curve upward instead of downward
- [x] 1.2 Fix minaret orientation — vertical lines pointing up with pointed tops
- [x] 1.3 Fix crescent moon — shape like letter "C" (opening right) with slight upward tilt
- [x] 1.4 Deploy to device and verify dome renders correctly via screenshot

## 2. Remove Onboarding

- [x] 2.1 Remove `/onboarding` route from `app_router.dart`, set `/prayer-times` as initial route for all users
- [x] 2.2 Delete `lib/features/onboarding/onboarding_screen.dart`
- [x] 2.3 Delete `lib/features/onboarding/onboarding_provider.dart`
- [x] 2.4 Remove `onboardingComplete` check from router — always go to prayer times

## 3. First-Launch Location

- [x] 3.1 Add first-launch check to `prayer_times_screen.dart` — if no location saved, attempt silent GPS
- [x] 3.2 Create location fallback dialog widget with message "We need your location to calculate accurate prayer times for your area" and city search field
- [x] 3.3 Show fallback dialog if GPS fails — dialog must not be dismissable without setting a location
- [x] 3.4 On successful location (GPS or city search), fetch prayer times and update screen

## 4. Verify

- [x] 4.1 Run `fvm flutter test` — all tests pass
- [x] 4.2 Run `fvm flutter analyze` — no errors
- [ ] 4.3 Deploy to device and verify: dome correct, no onboarding, location detection works, prayer times display
