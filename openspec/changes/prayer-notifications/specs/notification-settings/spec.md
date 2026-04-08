## ADDED Requirements

### Requirement: Per-prayer notification type setting
The system SHALL allow users to configure notification type independently for each prayer (Fajr, Dhuhr, Asr, Maghrib, Isha).

#### Scenario: Different types per prayer
- **WHEN** user sets Fajr to adhan and Dhuhr to vibrate
- **THEN** Fajr fires with adhan audio and Dhuhr fires with vibration only

#### Scenario: Default notification type
- **WHEN** app is first installed
- **THEN** all prayers default to "sound" notification type

### Requirement: Notification type options
The system SHALL offer these notification types: off, silent, vibrate, sound (system default or gentle tone), adhan.

#### Scenario: Off disables notification
- **WHEN** user sets a prayer to "off"
- **THEN** no notification fires for that prayer

#### Scenario: Silent shows notification without sound or vibration
- **WHEN** user sets a prayer to "silent"
- **THEN** a notification appears in the notification shade but makes no sound or vibration

#### Scenario: Vibrate only
- **WHEN** user sets a prayer to "vibrate"
- **THEN** phone vibrates but no sound plays

#### Scenario: Sound plays notification tone
- **WHEN** user sets a prayer to "sound"
- **THEN** the selected tone plays (system default or gentle tone)

#### Scenario: Adhan plays full adhan recording
- **WHEN** user sets a prayer to "adhan"
- **THEN** the full adhan audio plays (Fajr-specific for Fajr, standard for others)

### Requirement: Notification settings in settings screen
The system SHALL display notification settings in the existing Settings screen under a "Notifications" section.

#### Scenario: Settings UI shows all prayers
- **WHEN** user opens Settings
- **THEN** a Notifications section shows each prayer with its current notification type

#### Scenario: Tapping a prayer opens type picker
- **WHEN** user taps a prayer in the Notifications section
- **THEN** a picker shows the available notification types (off, silent, vibrate, sound, adhan)

### Requirement: Request notification permission on Android 13+
The system SHALL request POST_NOTIFICATIONS permission when the user first enables a notification.

#### Scenario: Permission requested
- **WHEN** user enables notifications for the first time on Android 13+
- **THEN** the system permission dialog appears

#### Scenario: Permission denied
- **WHEN** user denies notification permission
- **THEN** notifications are set to "off" and a message explains how to enable in system settings
