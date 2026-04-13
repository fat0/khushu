# Khushu Roadmap

## Shipped

### v1.0.0 — April 2026
- Prayer times for Sunni and Shia fiqhs (AlAdhan API)
- Dual Asr times (standard + Hanafi)
- Prayer guide — tap any prayer to see rakat breakdown
- GPS auto-detect with city search fallback
- Regional calculation method auto-detection
- Garden of Peace color palette (light + dark mode)
- Dome header with SVG mosque silhouette
- App icon — dome + crescent on deep green

### v1.1.0 — April 2026
- Adhan notifications (alarm package, foreground service)
- Per-prayer notification settings: Off / Sound / Adhan
- Fajr-specific adhan
- Adhan fires with app closed and screen locked
- Timezone-aware clock and scheduling
- IANA timezone alias handling
- Location-aware cache validation
- Notification permission flow (prompt on enable)
- Play Store closed testing setup
- CI/CD: GitHub Actions tests, release workflow, Fastlane
- Security: Dependabot, gitleaks, Trivy, CodeQL

### v1.2.0 — April 2026
- Qibla compass with live magnetometer bearing (flutter_qiblah)
- Dual-arrow compass: red north needle + sage green Qibla arrow with 3D Ka'bah at center
- Ka'bah icon button on prayer times screen
- Calibration overlay with figure-8 illustration
- Static bearing fallback for devices without magnetometer
- Offline prayer time calculation via adhan-dart (API → offline → error fallback)
- Android SDK bumps (compileSdk 36, minSdk 23, AGP 8.9.1)

## In Progress
- Play Store: 12 testers needed for 14 days → production access
- Fastlane auto-deploy to Play Store (blocked by draft app status)

## Next Up
1. Hijri calendar — Islamic date display
2. Adhan audio improvements — trim dua from recordings, add Al Aqsa/Makkah options (licensing needed), user selection
3. AlAdhan API rate limiting — handle gracefully ([rate limit info](https://community.islamic.network/knowledgebase/2-is-there-a-rate-limit-on-the-apis))
4. Multi-language support (Arabic, English, Urdu, Turkish, French)
5. In-app donations
6. Dual source mode (adhan-dart + AlAdhan cross-validation)

## Design Decisions
- **Framework:** Flutter (Dart) — cross-platform Android & iOS
- **Color palette:** Garden of Peace — sage, sand, cream, deep green, charcoal
- **Mission:** One Ummah Serving Allah
- **Notifications:** `alarm` package for adhan (foreground service), `flutter_local_notifications` for sound
- **Prayer times:** AlAdhan API, auto-detected regional method
- **Versioning:** VERSION file is source of truth, CHANGELOG.md must match
