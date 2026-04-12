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

## In Progress
- Play Store: 12 testers needed for 14 days → production access
- Fastlane auto-deploy to Play Store (blocked by draft app status)

## Next Up
1. Hijri calendar — Islamic date display
2. Better adhan audio — Al Aqsa, Makkah options (licensing needed)
3. Trim dua from current adhan recordings
4. Offline prayer calculation (adhan-dart)
5. Qibla compass
6. Multi-language support (Arabic, English, Urdu, Turkish, French)
7. In-app donations

## Design Decisions
- **Framework:** Flutter (Dart) — cross-platform Android & iOS
- **Color palette:** Garden of Peace — sage, sand, cream, deep green, charcoal
- **Mission:** One Ummah Serving Allah
- **Notifications:** `alarm` package for adhan (foreground service), `flutter_local_notifications` for sound
- **Prayer times:** AlAdhan API, auto-detected regional method
- **Versioning:** VERSION file is source of truth, CHANGELOG.md must match
