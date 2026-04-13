## ADDED Requirements

### Requirement: Offline prayer time calculation as fallback
The system SHALL calculate prayer times locally using adhan-dart when the AlAdhan API is unavailable.

#### Scenario: API unavailable — no internet
- **WHEN** the device has no internet connection and no cached prayer times
- **THEN** prayer times are calculated locally using adhan-dart with the user's coordinates and calculation method

#### Scenario: API timeout
- **WHEN** the AlAdhan API request times out (>10 seconds)
- **THEN** prayer times are calculated locally using adhan-dart

#### Scenario: API returns error
- **WHEN** the AlAdhan API returns a non-200 status code (other than 429)
- **THEN** prayer times are calculated locally using adhan-dart

#### Scenario: API available — normal operation
- **WHEN** the AlAdhan API is reachable
- **THEN** prayer times are fetched from the API as before (no change to current behavior)

### Requirement: Offline calculation matches API parameters
The system SHALL use the same calculation method and school parameters for offline calculation as configured for the API.

#### Scenario: ISNA method offline
- **WHEN** user's calculation method is ISNA and API is unavailable
- **THEN** adhan-dart uses `CalculationMethod.north_america` (ISNA equivalent)

#### Scenario: Dual Asr offline
- **WHEN** user is Sunni and API is unavailable
- **THEN** both standard Asr (`Madhab.shafi`) and Hanafi Asr (`Madhab.hanafi`) are calculated

#### Scenario: Ja'fari method offline
- **WHEN** user's fiqh is Ja'fari and API is unavailable
- **THEN** adhan-dart uses the closest Shia calculation method

### Requirement: API rate limit handling
The system SHALL detect HTTP 429 (Too Many Requests) responses from the AlAdhan API and retry once before falling back to offline calculation.

#### Scenario: Rate limited — retry succeeds
- **WHEN** the AlAdhan API returns HTTP 429
- **THEN** the system waits (using `Retry-After` header if present, otherwise 2 seconds)
- **AND** retries the request once
- **AND** if the retry returns 200, uses the API response normally

#### Scenario: Rate limited — retry fails
- **WHEN** the AlAdhan API returns HTTP 429 and the retry also fails
- **THEN** prayer times are calculated locally using adhan-dart

#### Scenario: Rate limited — Retry-After header present
- **WHEN** the API returns 429 with a `Retry-After` header (e.g., `Retry-After: 5`)
- **THEN** the system waits the specified number of seconds before retrying

#### Scenario: Rate limited — no Retry-After header
- **WHEN** the API returns 429 without a `Retry-After` header
- **THEN** the system waits 2 seconds before retrying

#### Scenario: Rate limit event logged
- **WHEN** a 429 response is received
- **THEN** the event is logged via DebugLog for debugging purposes

### Requirement: Offline indicator
The system SHALL show a subtle "offline" indicator when prayer times were calculated locally.

#### Scenario: Offline indicator visible
- **WHEN** prayer times source is offline (adhan-dart)
- **THEN** a small wifi-off icon with "offline" text appears near the location name

#### Scenario: Offline indicator hidden
- **WHEN** prayer times source is API
- **THEN** no offline indicator is shown

### Requirement: Cache prefers API source
The system SHALL prefer API-sourced cached data over offline-calculated cached data when API becomes available.

#### Scenario: API comes back online
- **WHEN** cached times were from offline calculation and API is now available
- **THEN** fresh times are fetched from API, replacing the offline cache

### Requirement: Automatic connectivity-based refresh
The system SHALL automatically detect network connectivity changes and refresh prayer times accordingly, without requiring the user to reopen the app.

#### Scenario: Connectivity lost while app is open
- **WHEN** the device loses internet connectivity while the app is open
- **THEN** the system switches to offline calculation seamlessly
- **AND** the offline indicator appears

#### Scenario: Connectivity restored while app is open
- **WHEN** the device regains internet connectivity while the app is open
- **THEN** the system automatically refetches from the AlAdhan API
- **AND** the offline indicator disappears

#### Scenario: No user action required
- **WHEN** connectivity changes in either direction
- **THEN** the transition happens automatically without the user closing or reopening the app

### Requirement: Offline times cached normally
The system SHALL cache offline-calculated prayer times the same way as API times.

#### Scenario: Offline times cached
- **WHEN** prayer times are calculated offline
- **THEN** they are cached in Hive with source marked as "offline"
- **AND** subsequent app opens use the cached times until they expire or API is available
