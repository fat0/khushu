## ADDED Requirements

### Requirement: Privacy policy page
The system SHALL have a privacy policy hosted on GitHub Pages accessible via a public URL.

#### Scenario: Privacy policy is accessible
- **WHEN** visiting https://fat0.github.io/khushu/privacy-policy.html
- **THEN** a privacy policy page loads explaining data collection practices

#### Scenario: Privacy policy content is accurate
- **WHEN** reading the privacy policy
- **THEN** it states: no personal data collected, location stored locally on device only, API calls to AlAdhan for prayer times, no ads, no analytics

### Requirement: Store listing metadata
The system SHALL have all required Play Store listing fields documented.

#### Scenario: Required fields are prepared
- **WHEN** creating the Play Store listing
- **THEN** the following are ready: app title, short description (80 chars max), full description (4000 chars max), category, content rating

### Requirement: Store listing graphics
The system SHALL have the required graphic assets for Play Store listing.

#### Scenario: Screenshots are prepared
- **WHEN** uploading to Play Store
- **THEN** at least 2 phone screenshots are available (light and dark mode)

#### Scenario: Feature graphic is prepared
- **WHEN** uploading to Play Store
- **THEN** a 1024x500 feature graphic is available
