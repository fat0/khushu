## 1. App ID Migration

- [x] 1.1 Change `applicationId` in `android/app/build.gradle` from `com.khushu.khushu` to `dev.khushu`
- [x] 1.2 Update Android namespace/package references if needed
- [x] 1.3 Uninstall old app from test device, build and install with new ID to verify

## 2. Release Signing (GitHub Actions)

- [x] 2.1 Generate a release keystore (.jks) using keytool — stored at ~/khushu-release.jks (back up securely)
- [x] 2.2 Base64-encode the keystore and add as GitHub Secret `KEYSTORE_BASE64`
- [x] 2.3 Add GitHub Secrets: `KEYSTORE_PASSWORD`, `PLAY_STORE_SERVICE_ACCOUNT_JSON`
- [x] 2.4 Configure `android/app/build.gradle` with signingConfigs that read from environment variables
- [x] 2.5 Create `.github/workflows/release.yml` — builds signed AAB on tag push, uploads as artifact
- [ ] 2.6 Test by pushing a tag: `git tag v1.0.0 && git push --tags` — verify AAB is produced

## 3. Privacy Policy

- [x] 3.1 Create `docs/privacy-policy.html` — simple page stating no data collection, local storage only, AlAdhan API usage
- [ ] 3.2 Enable GitHub Pages on the repo (Settings → Pages → Source: Deploy from branch, main, /docs)
- [ ] 3.3 Verify privacy policy is accessible at https://fat0.github.io/khushu/privacy-policy.html

## 4. Store Listing Assets

- [x] 4.1 Write store listing copy: title, short description, full description
- [x] 4.2 Prepare phone screenshots (light + dark mode) — crop to remove status bar if needed
- [x] 4.3 Create feature graphic (1024x500) — dome icon on deep green background
- [x] 4.4 Save all assets and copy to `docs/store-listing/`

## 5. Play Store Upload

- [ ] 5.1 Create app in Google Play Console with app ID `dev.khushu`
- [ ] 5.2 Fill out content rating questionnaire
- [ ] 5.3 Fill out data safety form (no data collected)
- [ ] 5.4 Upload signed AAB to internal testing track
- [ ] 5.5 Add store listing (title, description, screenshots, feature graphic, privacy policy URL)
- [ ] 5.6 Submit for review
