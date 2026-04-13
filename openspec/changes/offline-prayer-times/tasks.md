## 1. Add adhan-dart package

- [x] 1.1 Add `adhan` package to pubspec.yaml
- [x] 1.2 Run `flutter pub get` — verify no conflicts
- [x] 1.3 Verify adhan-dart works with a simple test (calculate today's times for a known location, compare with AlAdhan API)

## 2. Prayer time calculator

- [x] 2.1 Create `lib/core/prayer/offline_calculator.dart` — wraps adhan-dart with our parameter mapping
- [x] 2.2 Map AlAdhan method IDs to adhan-dart `CalculationMethod` (ISNA, MWL, Umm Al-Qura, Egyptian, Karachi, Jafari)
- [x] 2.3 Handle unmapped methods — use custom `CalculationParameters` with Fajr/Isha angles
- [x] 2.4 Implement dual Asr calculation (standard + Hanafi) in offline mode
- [x] 2.5 Return `PrayerTimes` model matching API response format

## 3. Data model updates

- [x] 3.1 Add `PrayerTimeSource` enum (api, offline) to models
- [x] 3.2 Add source field to `PrayerTimes` model
- [x] 3.3 Add source to Hive cache (store and load)
- [x] 3.4 Cache validation: prefer API-sourced cache over offline cache

## 4. API rate limit handling

- [x] 4.1 Add Dio interceptor to `aladhan_api.dart` that detects HTTP 429 responses
- [x] 4.2 On 429: read `Retry-After` header (default 2 seconds if absent), wait, retry once
- [x] 4.3 If retry succeeds, return response normally
- [x] 4.4 If retry fails, throw `PrayerTimesException` so fallback kicks in
- [x] 4.5 Log rate limit events via DebugLog

## 5. Provider fallback logic

- [x] 5.1 Update `PrayerTimesNotifier.build()` — add fallback: try API (with rate limit retry) → try adhan-dart → error
- [x] 5.2 Update `PrayerTimesNotifier.refresh()` with same fallback
- [x] 5.3 When API fails, log the error and calculate offline
- [x] 5.4 When API is available and cache is offline-sourced, refetch from API

## 6. UI — offline indicator

- [x] 6.1 Add subtle wifi-off icon + "offline" text near location name in dome header
- [x] 6.2 Only show when prayer times source is offline
- [x] 6.3 Hide when API data is available

## 7. Testing

- [x] 7.1 Unit test: offline calculator returns correct times for ISNA method
- [x] 7.2 Unit test: offline calculator handles dual Asr
- [x] 7.3 Unit test: method ID mapping covers all supported methods
- [x] 7.4 Unit test: fallback logic — API failure triggers offline calculation
- [x] 7.5 Unit test: rate limit detection — 429 triggers retry
- [x] 7.6 Unit test: rate limit retry with Retry-After header
- [x] 7.7 Unit test: cache validation prefers API source over offline
- [x] 7.8 Run all existing tests — verify no regressions
- [x] 7.9 Manual test: enable airplane mode, open app — verify prayer times load with offline indicator

## 8. Auto-refresh on connectivity change

- [x] 8.1 Add `connectivity_plus` package
- [x] 8.2 Add connectivity listener to prayer times provider — refetch from API when connectivity restored
- [x] 8.3 When connectivity lost and current data is API-sourced, recalculate offline
- [x] 8.4 Test: turn off wifi while app is open — verify offline indicator appears
- [x] 8.5 Test: turn on wifi while app is open — verify offline indicator disappears and API data loads
