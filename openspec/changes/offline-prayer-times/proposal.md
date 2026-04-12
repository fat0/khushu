## Why

Khushu currently requires an internet connection to fetch prayer times from the AlAdhan API. If the user is offline (airplane mode, no signal, rural area, traveling), the app shows cached data or an error. The API also rate limits at ~12 requests/second/IP — while unlikely with normal use, it should be handled gracefully.

Adding offline calculation via `adhan-dart` ensures prayer times are always available, and proper rate limit handling ensures the app degrades gracefully under any API failure condition.

## What Changes

- Add `adhan` (adhan-dart) package for on-device prayer time calculation
- AlAdhan API remains the primary source — adhan-dart is the automatic fallback
- Detect HTTP 429 (rate limit) responses — back off and retry once (2 second delay)
- When API call fails (no internet, timeout, rate limit, error), calculate locally using adhan-dart
- Dual Asr (standard + Hanafi) works identically in offline mode
- Subtle "offline" indicator shown when local calculation is used
- Seamless — user doesn't choose, it just works

## Capabilities

### New Capabilities
- `offline-calculation`: On-device prayer time calculation using adhan-dart as fallback when AlAdhan API is unavailable
- `api-rate-limiting`: Detect rate limit responses, back off, retry, then fall back to offline

### Modified Capabilities
- `prayer-times-fetching`: Add rate limit handling + offline fallback logic

## Impact

- Add package: `adhan` (adhan-dart)
- Modify: `lib/core/api/aladhan_api.dart` — add Dio interceptor for rate limit detection and retry
- Create: `lib/core/prayer/offline_calculator.dart` — wraps adhan-dart
- Modify: `lib/features/prayer_times/prayer_times_provider.dart` — add fallback logic
- Modify: prayer times screen — add subtle offline indicator
- Modify: `lib/core/models/prayer_times.dart` — add source field (api vs offline)
