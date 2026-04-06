## ADDED Requirements

### Requirement: App ID is dev.khushu
The system SHALL use `dev.khushu` as the Android application ID.

#### Scenario: build.gradle has correct app ID
- **WHEN** reading android/app/build.gradle
- **THEN** applicationId is "dev.khushu"

#### Scenario: App installs with new ID
- **WHEN** installing the release build on a device
- **THEN** the app appears as dev.khushu in system settings
