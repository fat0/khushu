## ADDED Requirements

### Requirement: Rakat data model per fiqh
The system SHALL provide a static data structure mapping each prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) to its rakat breakdown for each of the three fiqh groups (Maliki/Hanbali/Shafi'i, Hanafi, Ja'fari). Each entry SHALL include: count, type label, and position (before/after fard).

#### Scenario: Fajr rakat for Maliki/Hanbali/Shafi'i
- **WHEN** fiqh is Maliki/Hanbali/Shafi'i and prayer is Fajr
- **THEN** rakat breakdown shows: 2 Sunnah (before), 2 Fard

#### Scenario: Fajr rakat for Hanafi
- **WHEN** fiqh is Hanafi and prayer is Fajr
- **THEN** rakat breakdown shows: 2 Sunnah (before), 2 Fard

#### Scenario: Fajr rakat for Ja'fari
- **WHEN** fiqh is Ja'fari and prayer is Fajr
- **THEN** rakat breakdown shows: 2 Nafilah (before), 2 Fard

#### Scenario: Dhuhr rakat for Hanafi
- **WHEN** fiqh is Hanafi and prayer is Dhuhr
- **THEN** rakat breakdown shows: 4 Sunnah (before), 4 Fard, 2 Sunnah (after)

#### Scenario: Dhuhr rakat for Maliki/Hanbali/Shafi'i
- **WHEN** fiqh is Maliki/Hanbali/Shafi'i and prayer is Dhuhr
- **THEN** rakat breakdown shows: 2 Sunnah (before), 4 Fard, 2 Sunnah (after)

#### Scenario: Dhuhr rakat for Ja'fari
- **WHEN** fiqh is Ja'fari and prayer is Dhuhr
- **THEN** rakat breakdown shows: 8 Nafilah (before), 4 Fard

#### Scenario: Asr rakat for Hanafi
- **WHEN** fiqh is Hanafi and prayer is Asr
- **THEN** rakat breakdown shows: 4 Fard

#### Scenario: Asr rakat for Maliki/Hanbali/Shafi'i
- **WHEN** fiqh is Maliki/Hanbali/Shafi'i and prayer is Asr
- **THEN** rakat breakdown shows: 4 Fard

#### Scenario: Asr rakat for Ja'fari
- **WHEN** fiqh is Ja'fari and prayer is Asr
- **THEN** rakat breakdown shows: 8 Nafilah (before), 4 Fard

#### Scenario: Maghrib rakat for Maliki/Hanbali/Shafi'i
- **WHEN** fiqh is Maliki/Hanbali/Shafi'i and prayer is Maghrib
- **THEN** rakat breakdown shows: 3 Fard, 2 Sunnah (after)

#### Scenario: Maghrib rakat for Hanafi
- **WHEN** fiqh is Hanafi and prayer is Maghrib
- **THEN** rakat breakdown shows: 3 Fard, 2 Sunnah (after)

#### Scenario: Maghrib rakat for Ja'fari
- **WHEN** fiqh is Ja'fari and prayer is Maghrib
- **THEN** rakat breakdown shows: 3 Fard, 4 Nafilah (after)

#### Scenario: Isha rakat for Maliki/Hanbali/Shafi'i
- **WHEN** fiqh is Maliki/Hanbali/Shafi'i and prayer is Isha
- **THEN** rakat breakdown shows: 4 Fard, 2 Sunnah (after), Witr: 1-3 Sunnah

#### Scenario: Isha rakat for Hanafi
- **WHEN** fiqh is Hanafi and prayer is Isha
- **THEN** rakat breakdown shows: 4 Fard, 2 Sunnah (after), Witr: 3 Wajib

#### Scenario: Isha rakat for Ja'fari
- **WHEN** fiqh is Ja'fari and prayer is Isha
- **THEN** rakat breakdown shows: 4 Fard, 2 Nafilah (after), Witr: 3 Mustahabb

### Requirement: Sunrise has no rakat data
The system SHALL return a special "no prayer" marker for Sunrise instead of rakat data.

#### Scenario: Sunrise rakat lookup
- **WHEN** prayer is Sunrise for any fiqh
- **THEN** the system returns a marker indicating "Marks the end of Fajr time — no prayer"

### Requirement: Fiqh-appropriate terminology
The system SHALL use "Sunnah" for Maliki/Hanbali/Shafi'i and Hanafi fiqhs, "Nafilah" for Ja'fari fiqh, "Wajib" for Hanafi witr, and "Mustahabb" for Ja'fari witr.

#### Scenario: Sunni terminology
- **WHEN** fiqh is Maliki/Hanbali/Shafi'i or Hanafi
- **THEN** optional prayers are labeled "Sunnah"

#### Scenario: Ja'fari terminology
- **WHEN** fiqh is Ja'fari
- **THEN** optional prayers are labeled "Nafilah"

#### Scenario: Hanafi witr terminology
- **WHEN** fiqh is Hanafi
- **THEN** witr is labeled "Wajib"

#### Scenario: Ja'fari witr terminology
- **WHEN** fiqh is Ja'fari
- **THEN** witr is labeled "Mustahabb"
