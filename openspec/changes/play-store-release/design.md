## Context

Khushu is a working Flutter Android app with all MVP features complete. It needs to be packaged and submitted to the Google Play Store. The developer has a new Google Play Console account (identity verification pending).

Current state:
- App ID: `com.khushu.khushu` → needs to change to `dev.khushu`
- No signing key exists — debug builds only
- No privacy policy
- No store listing assets

## Goals / Non-Goals

**Goals:**
- Change app ID to `dev.khushu`
- Generate a release signing key and configure Gradle
- Build a signed AAB for Play Store upload
- Create a privacy policy hosted on GitHub Pages
- Prepare store listing copy and screenshot assets

**Non-Goals:**
- iOS App Store (separate future change)
- In-app purchase or monetization setup
- Analytics or crash reporting integration
- Automated CI/CD publishing pipeline

## Decisions

**1. App ID: `dev.khushu`**

Changing from `com.khushu.khushu`. This requires updating `applicationId` in `build.gradle`. Since the app isn't published yet, there's no migration concern — fresh install on all devices.

**2. Signing key: keystore file, referenced via key.properties**

Standard Flutter approach: generate a `.jks` keystore, reference it from `android/key.properties` (gitignored), and configure `build.gradle` to read from it. The keystore file lives outside the repo.

**3. Privacy policy: GitHub Pages from /docs**

Host `docs/privacy-policy.html` via GitHub Pages. Enable Pages on the repo pointing to `/docs` on `main` branch. URL: `https://fat0.github.io/khushu/privacy-policy.html`. The policy is simple — Khushu collects no personal data, stores location locally on device only, makes API calls to AlAdhan for prayer times.

**4. Store listing: minimal and honest**

- Title: Khushu — Islamic Prayer Times
- Short description: Prayer times for Sunni and Shia fiqhs. One Ummah Serving Allah.
- Screenshots: pull from phone (light + dark mode)
- Feature graphic: dome icon on deep green background (1024x500)
- Category: Lifestyle or Education

## Risks / Trade-offs

- **[Signing key loss]** If the keystore is lost, the app cannot be updated on the Play Store. → Mitigation: back up the keystore to a secure location (not the repo). Document where it's stored.
- **[Identity verification delay]** Google may take 1-3 business days. → Mitigation: prepare everything else while waiting.
- **[App ID change]** Users with the debug build (`com.khushu.khushu`) will need to uninstall and reinstall. → Acceptable since the app isn't published yet.
