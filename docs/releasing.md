# Releasing Khushu

## How to Release a New Version

### 1. Update the version

In `pubspec.yaml`, bump the version:

```yaml
version: 1.1.0+2
```

- **First number** (major): breaking changes
- **Second number** (minor): new features
- **Third number** (patch): bug fixes
- **+N** (build number): must increment every release — Play Store requires this to go up

### 2. Update the changelog

Add a new section at the top of `CHANGELOG.md`:

```markdown
## [1.1.0] — 2026-05-01

### Added
- New feature description

### Fixed
- Bug fix description
```

### 3. Commit and merge to main

Create a PR with the version bump and changelog update. Merge to main.

### 4. Automated build

When the version in `pubspec.yaml` changes on main, GitHub Actions automatically:
- Runs all tests
- Builds a signed AAB (Android App Bundle)
- Creates a GitHub Release with the AAB attached

### 5. Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Select Khushu
3. Go to **Production** (or **Internal testing** for beta)
4. Click **Create new release**
5. Download the AAB from the GitHub Release and upload it
6. Add release notes (copy from CHANGELOG.md)
7. Click **Review release** → **Start rollout**

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
