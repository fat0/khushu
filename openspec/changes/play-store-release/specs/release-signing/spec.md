## ADDED Requirements

### Requirement: Generate release signing key
The system SHALL have a Java keystore (.jks) file for signing release builds, stored outside the repository.

#### Scenario: Keystore generation
- **WHEN** developer runs the keytool command
- **THEN** a .jks keystore file is created at a secure location outside the repo

### Requirement: Gradle reads signing config from key.properties
The system SHALL read signing key credentials from `android/key.properties` which is gitignored.

#### Scenario: Release build uses signing config
- **WHEN** `flutter build appbundle --release` is run
- **THEN** the AAB is signed with the release key from key.properties

#### Scenario: key.properties is not committed
- **WHEN** checking git status
- **THEN** `android/key.properties` is excluded by .gitignore

### Requirement: Build produces signed AAB
The system SHALL produce a signed Android App Bundle (.aab) suitable for Play Store upload.

#### Scenario: Successful AAB build
- **WHEN** `flutter build appbundle --release` completes
- **THEN** a signed .aab file exists at `build/app/outputs/bundle/release/app-release.aab`
