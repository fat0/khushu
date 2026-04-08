# Changelog

All notable changes to Khushu will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Semantic Versioning](https://semver.org/).

## [1.0.3] — 2026-04-07

### Fixed
- Grant write permissions for GitHub Release creation
- Skip tests on docs-only PRs

## [1.0.2] — 2026-04-07

### Fixed
- Simplified signing to use single KEYSTORE_PASSWORD

## [1.0.1] — 2026-04-07

### Changed
- Remove duplicate test run from release workflow
- Automated Play Store deployment via Fastlane

## [1.0.0] — 2026-04-06

### Added
- Accurate prayer times for Sunni and Shia (Ja'fari) fiqhs via AlAdhan API
- Dual Asr times — standard (Maliki, Hanbali, Shafi'i) and Hanafi
- Prayer guide — tap any prayer to see rakat breakdown (fard, sunnah/nafilah, witr)
- Fiqh-aware terminology — Sunnah for Sunni, Nafilah for Ja'fari
- Ja'fari rakat data verified against Sistani's Tawdih al-Masa'il (Ruling 751)
- GPS auto-detect location with manual city search fallback
- Regional calculation method auto-detection (ISNA, MWL, Umm Al-Qura, etc.)
- Timezone-aware clock showing selected location's local time
- Sunrise row shows "Marks the end of Fajr time — no prayer"
- No active prayer shown between Sunrise and Dhuhr
- Dome header with SVG mosque silhouette
- Garden of Peace color palette (light + dark mode, follows system)
- App icon — dome + crescent on deep green
- Privacy policy page
- GitHub Actions CI (tests on every PR) and release workflow (signed AAB on version bump)
- App ID: dev.khushu
