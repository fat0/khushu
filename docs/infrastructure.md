# Khushu Infrastructure & Accounts

## Accounts

| Account | Purpose | URL | Owner |
|---------|---------|-----|-------|
| Google Play Console | App publishing | https://play.google.com/console | Separate Google account for Khushu |
| GitHub | Source code, CI/CD, GitHub Pages | https://github.com/fat0/khushu | Project owner |
| Google Cloud (pending) | Service account for automated Play Store deployment | https://console.cloud.google.com | Same as Play Console account |

## GitHub Tokens

**Separate tokens** are used for git and gh CLI. Never merge them.

| Token | Type | Storage | Scope |
|-------|------|---------|-------|
| Git push token | Fine-grained PAT | macOS Keychain | See token settings on GitHub |
| gh CLI token | Fine-grained PAT | macOS Keychain (via gh) | See token settings on GitHub |

**Important:** When editing token permissions on GitHub, the repo scope can silently reset to "All repositories" — always double-check after saving.

## GitHub Secrets (Repository)

https://github.com/fat0/khushu/settings/secrets/actions

| Secret | Purpose | How it was created |
|--------|---------|-------------------|
| `KEYSTORE_BASE64` | Base64-encoded release signing keystore | `base64 -i ~/khushu-release.jks \| pbcopy` |
| `KEYSTORE_PASSWORD` | Password for the keystore (used for both store and key) | Set during `keytool -genkey` |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Cloud service account key for automated Play Store deployment | Downloaded from Google Cloud Console |

## Signing Key

| Item | Location | Notes |
|------|----------|-------|
| Keystore file | `~/khushu-release.jks` | **BACK THIS UP** — if lost, cannot update app on Play Store |
| Key alias | `khushu` | Hardcoded in `android/app/build.gradle` |
| Certificate | Set during keytool generation | Other fields left as Unknown (not visible to users) |
| Validity | 10,000 days (~27 years) | |

**Backup the keystore** to a secure cloud location (iCloud Drive, Google Drive, etc.) and store the password in a password manager.

## GitHub Actions Workflows

| Workflow | File | Trigger | What it does |
|----------|------|---------|-------------|
| Tests | `.github/workflows/test.yml` | PRs to main (skips docs/GHA-only changes) | Runs `flutter analyze` + `flutter test` |
| Release | `.github/workflows/release.yml` | VERSION change on main | Builds signed AAB → GitHub Release → Fastlane deploy |
| Security | `.github/workflows/security.yml` | PRs + push to main | Gitleaks (secrets) + Trivy (vulnerabilities) |
| CodeQL | `.github/workflows/codeql.yml` | Push to main + weekly Monday | Java/Kotlin code security analysis |
| Dependabot Auto-merge | `.github/workflows/dependabot-auto-merge.yml` | Dependabot PRs | Auto-merges safe updates (see below) |
| Version Check | `.github/workflows/version-check.yml` | PRs changing VERSION or CHANGELOG | Validates VERSION ↔ CHANGELOG sync |

### Dependabot Auto-merge Policy

| PR type | Tests run | Auto-merge? |
|---------|-----------|-------------|
| GHA version bumps | Security scans only | Yes — all versions |
| Pub dependency patches (x.y.Z) | Flutter tests + security | Yes — if all pass |
| Pub dependency minor/major (x.Y.0 / X.0.0) | Flutter tests + security | No — manual review required |

### Dependabot Configuration

File: `.github/dependabot.yml`
- Scans `pub` (Flutter packages) weekly
- Scans `github-actions` (workflow actions) weekly
- Opens up to 5 PRs per ecosystem

## GitHub Pages

| Setting | Value |
|---------|-------|
| Source | Deploy from branch: `main`, folder: `/docs` |
| Privacy policy URL | https://fat0.github.io/khushu/privacy-policy.html |

## App IDs

| Environment | App ID |
|------------|--------|
| Release | `dev.khushu` |
| Debug | `dev.khushu` (same — no debug suffix configured) |

## Third-Party Services

| Service | Purpose | Auth required? | Cost |
|---------|---------|---------------|------|
| [AlAdhan API](https://aladhan.com) | Prayer time calculations | No (public API) | Free |
| [GitHub Actions](https://github.com/features/actions) | CI/CD | Via repo (GITHUB_TOKEN) | Free for public repos |
| [GitHub Pages](https://pages.github.com) | Privacy policy hosting | Via repo | Free for public repos |
| [Google Play Console](https://play.google.com/console) | App distribution | Google account | $25 one-time |
| [Fastlane](https://fastlane.tools) | (Pending) Automated Play Store upload | Service account JSON | Free (open source) |
