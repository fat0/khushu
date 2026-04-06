## Why

Khushu is ready for users. The app runs on Android with all core features working — prayer times, rakat guide, timezone support, dual Asr. Getting it on the Google Play Store makes it accessible to the Ummah.

## What Changes

- Change app ID from `com.khushu.khushu` to `dev.khushu`
- Create app signing key for release builds
- Configure release build settings (minification, signing)
- Create privacy policy page hosted on GitHub Pages
- Prepare Play Store listing assets (screenshots, description, feature graphic)
- Build signed AAB (Android App Bundle) for Play Store upload

## Capabilities

### New Capabilities
- `release-signing`: App signing key generation and Gradle release config
- `store-listing`: Play Store metadata — title, description, screenshots, feature graphic, privacy policy
- `app-id-migration`: Change app ID from com.khushu.khushu to dev.khushu

### Modified Capabilities

## Impact

- `android/app/build.gradle` — app ID, signing config, minification
- `android/app/src/main/AndroidManifest.xml` — may need updates for new app ID
- New `android/key.properties` (gitignored) — signing key reference
- New `docs/privacy-policy.html` — hosted via GitHub Pages
- New `docs/store-listing.md` — Play Store copy and asset checklist
