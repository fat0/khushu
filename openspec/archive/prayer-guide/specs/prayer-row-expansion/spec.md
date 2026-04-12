## ADDED Requirements

### Requirement: Tap prayer row to expand rakat breakdown
The system SHALL expand a prayer row inline when tapped, showing the rakat breakdown for that prayer based on the user's selected fiqh. Tapping again SHALL collapse it.

#### Scenario: Expand Fajr row
- **WHEN** user taps the Fajr prayer row
- **THEN** the row expands below the time to show rakat counts (e.g., "2 Sunnah (before) · 2 Fard")

#### Scenario: Collapse expanded row
- **WHEN** user taps an already expanded prayer row
- **THEN** the row collapses back to showing only the prayer name and time

#### Scenario: Only one row expanded at a time
- **WHEN** user taps a prayer row while another row is already expanded
- **THEN** the previously expanded row collapses and the newly tapped row expands

### Requirement: Expansion content matches user's fiqh
The system SHALL display rakat counts and terminology matching the user's currently selected fiqh from settings.

#### Scenario: Hanafi user views Isha
- **WHEN** user's fiqh is Hanafi and they expand the Isha row
- **THEN** the expansion shows: 4 Fard, 2 Sunnah (after), Witr: 3 Wajib

#### Scenario: Ja'fari user views Dhuhr
- **WHEN** user's fiqh is Ja'fari and they expand the Dhuhr row
- **THEN** the expansion shows: 8 Nafilah (before), 4 Fard

#### Scenario: Fiqh change updates expanded content
- **WHEN** user changes fiqh in settings and returns to prayer times
- **THEN** expanding a prayer row shows rakat data for the new fiqh

### Requirement: Sunrise expansion shows informational note
The system SHALL show "Marks the end of Fajr time — no prayer" when the Sunrise row is expanded, instead of rakat data.

#### Scenario: Expand Sunrise row
- **WHEN** user taps the Sunrise row
- **THEN** the row expands to show "Marks the end of Fajr time — no prayer"

### Requirement: Expansion animation is smooth
The system SHALL animate the expansion and collapse with a smooth transition consistent with the app's calm visual style.

#### Scenario: Expand animation
- **WHEN** user taps a prayer row to expand
- **THEN** the rakat content slides open smoothly (no jarring jump)

#### Scenario: Collapse animation
- **WHEN** user taps to collapse
- **THEN** the content slides closed smoothly
