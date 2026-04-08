# Releasing Khushu

## How to Release a New Version

### 1. Update VERSION and CHANGELOG.md

Update both files in the same PR:

**VERSION** — set to the new version number:
```
1.1.0
```

**CHANGELOG.md** — add a new section at the top with the same version:
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

A PR check validates that VERSION and CHANGELOG.md versions match. Do **not** edit `pubspec.yaml` — GHA syncs it automatically.

### 2. Merge to main

Create a PR with both file changes. Can be bundled with a feature/fix PR or done separately. Merge to main.

### 3. Automated build and deploy

When VERSION changes on main, GitHub Actions automatically:
- Checks that the version isn't already released
- Syncs version to pubspec.yaml
- Builds a signed AAB
- Creates a GitHub Release with the AAB attached
- Deploys to Play Store internal testing via Fastlane

### 4. Promote to production

After verifying on internal testing:
1. Go to [Google Play Console](https://play.google.com/console)
2. Select Khushu → **Internal testing**
3. Click **Promote release** → **Production**
4. Review and roll out

## If a release fails

Just fix the issue and merge to main. The release workflow checks VERSION against the latest GitHub Release — if the version hasn't been successfully released, it retries automatically.

## First-Time Setup (already done)

- [x] Google Play Developer account ($25)
- [x] App signing keystore (backed up securely)
- [x] Keystore password stored in GitHub Secrets
- [x] Release workflow in `.github/workflows/release.yml`
- [x] Privacy policy at GitHub Pages
- [x] Store listing assets in `docs/store-listing/`

## Important Files

| File | Purpose |
|------|---------|
| `VERSION` | Version number (triggers release build) |
| `CHANGELOG.md` | Version history (must match VERSION) |
| `pubspec.yaml` | Auto-synced by GHA — do not edit version manually |
| `.github/workflows/release.yml` | Automated release build + deploy |
| `.github/workflows/test.yml` | CI tests on every PR |
| `.github/workflows/version-check.yml` | Validates VERSION ↔ CHANGELOG sync on PRs |
| `docs/store-listing/listing.md` | Play Store copy |
| `docs/privacy-policy.html` | Privacy policy (GitHub Pages) |
| `~/khushu-release.jks` | Signing key (BACK THIS UP — never commit) |
