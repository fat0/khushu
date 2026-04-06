# Releasing Khushu

## How to Release a New Version

### 1. Update the changelog (single source of truth)

Add a new section at the top of `CHANGELOG.md` with the new version number:

```markdown
## [1.1.0] — 2026-05-01

### Added
- New feature description

### Fixed
- Bug fix description
```

Version format: **major.minor.patch** ([semver](https://semver.org/))
- **Major:** breaking changes
- **Minor:** new features
- **Patch:** bug fixes

Do **not** edit `pubspec.yaml` version — GHA syncs it automatically from CHANGELOG.md.

### 2. Commit and merge to main

Create a PR with the changelog update. Merge to main.

### 3. Automated build

When the version in `CHANGELOG.md` changes on main, GitHub Actions automatically:
- Runs all tests
- Builds a signed AAB (Android App Bundle)
- Creates a GitHub Release with the AAB attached

### 5. Deploy to Play Store

Once Fastlane is set up (pending Google identity verification), the release workflow will automatically upload the AAB to the Play Store.

Until then, manually upload:
1. Go to [Google Play Console](https://play.google.com/console)
2. Select Khushu → **Production** (or **Internal testing**)
3. Click **Create new release**
4. Download the AAB from the GitHub Release and upload it
5. Add release notes (copy from CHANGELOG.md)
6. Click **Review release** → **Start rollout**

## First-Time Setup (already done)

- [x] Google Play Developer account ($25)
- [x] App signing keystore (backed up securely)
- [x] Keystore + passwords stored in GitHub Secrets
- [x] Release workflow in `.github/workflows/release.yml`
- [x] Privacy policy at GitHub Pages
- [x] Store listing assets in `docs/store-listing/`

## Important Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | App version (triggers release build) |
| `CHANGELOG.md` | Version history |
| `.github/workflows/release.yml` | Automated release build |
| `.github/workflows/test.yml` | CI tests on every PR |
| `docs/store-listing/listing.md` | Play Store copy |
| `docs/privacy-policy.html` | Privacy policy (GitHub Pages) |
| `~/khushu-release.jks` | Signing key (BACK THIS UP — never commit) |
