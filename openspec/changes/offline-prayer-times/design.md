## Context

Khushu fetches prayer times from the AlAdhan API daily and caches them in Hive. If the cache is empty and the API is unreachable, the user sees an error. The `adhan` package (adhan-dart) can calculate prayer times locally using the same astronomical algorithms (Jean Meeus) with identical parameters (coordinates, calculation method, school).

When tested, adhan-dart and AlAdhan API matched within 0-1 minutes for ISNA method.

## Goals / Non-Goals

**Goals:**
- Prayer times always available, even without internet
- AlAdhan API remains primary — adhan-dart is automatic fallback
- Dual Asr works in offline mode
- Subtle "offline" indicator when local calculation is used
- User doesn't have to configure anything — seamless fallback

**Non-Goals:**
- Replacing AlAdhan API entirely
- User choosing between online/offline modes
- Cross-validation (showing both sources side by side)
- Offline Hijri calendar (future feature)

## Decisions

**0. API rate limit handling**

Add a Dio interceptor that detects HTTP 429 responses. On 429:
1. Wait 2 seconds
2. Retry once
3. If retry fails (429 again or any error) → fall back to adhan-dart

This is lightweight — no complex retry queues. One retry is enough since our usage is 1-2 calls/day. The interceptor also handles `Retry-After` header if the API provides one.

**1. Fallback architecture**

The prayer times provider currently does: try cache → try API → error.

New flow: try cache → try API → **try adhan-dart** → error.

If adhan-dart succeeds, the result is cached normally so subsequent loads use the cache. The only difference is the source field marking it as "offline".

**2. adhan-dart calculation parameters**

Map existing AlAdhan API parameters to adhan-dart equivalents:

| AlAdhan parameter | adhan-dart equivalent |
|---|---|
| method=2 (ISNA) | `CalculationMethod.north_america` |
| method=3 (MWL) | `CalculationMethod.muslim_world_league` |
| method=4 (Umm Al-Qura) | `CalculationMethod.umm_al_qura` |
| method=5 (Egyptian) | `CalculationMethod.egyptian` |
| method=1 (Karachi) | `CalculationMethod.karachi` |
| method=0 (Jafari/Qum) | `CalculationMethod.tehran` (closest) |
| school=0 (Standard) | `Madhab.shafi` |
| school=1 (Hanafi) | `Madhab.hanafi` |

**3. PrayerTimes model — add source field**

Add an enum `PrayerTimeSource { api, offline }` to `PrayerTimes` model. Default is `api`. When adhan-dart is used, set to `offline`. The UI checks this to show the indicator.

**4. Offline indicator UI**

A small wifi-off icon with "offline" text next to the location name in the dome header. Only visible when source is `offline`. Disappears when API data is available.

**5. adhan-dart for dual Asr**

Calculate Asr twice — once with `Madhab.shafi` (standard) and once with `Madhab.hanafi`. Same as the current API approach but local.

## Risks / Trade-offs

- **[Method mapping]** Not all AlAdhan methods have exact adhan-dart equivalents. Some regional methods (Gulf, Turkey, SE Asia) may need custom angle parameters. → Mitigation: use `CalculationParameters` with custom Fajr/Isha angles for unmapped methods.
- **[1-minute variance]** adhan-dart may differ from AlAdhan by up to 1 minute due to different solar position algorithms. → Acceptable — within scholarly variation.
- **[Cache interaction]** Offline-calculated times get cached. If API comes back online, the cache still serves offline times until next day or location change. → Add source to cache validation — prefer API-sourced cache over offline cache when API is available.
