## ADDED Requirements

### Requirement: Bundle adhan audio assets
The system SHALL include adhan audio files from the Internet Archive Doha recordings (Public Domain) as app assets.

#### Scenario: Standard adhan available
- **WHEN** user selects adhan notification type for any prayer except Fajr
- **THEN** the standard Doha adhan recording plays

#### Scenario: Fajr-specific adhan available
- **WHEN** user selects adhan notification type for Fajr
- **THEN** the Fajr-specific adhan plays (includes "As-salatu khayrun min an-nawm")

### Requirement: Adhan plays in background
The system SHALL play adhan audio even when the app is in the background or the screen is locked.

#### Scenario: Screen locked during adhan
- **WHEN** adhan notification fires while phone screen is locked
- **THEN** adhan audio plays through the speaker

#### Scenario: Adhan respects phone volume
- **WHEN** phone is set to silent or vibrate mode
- **THEN** adhan does NOT play audio (respects system volume)

### Requirement: Custom gentle notification tone
The system SHALL include a custom gentle notification tone as an alternative to the system default sound.

#### Scenario: Gentle tone selected
- **WHEN** user selects "sound" notification type
- **THEN** user can choose between system default or a custom gentle tone
