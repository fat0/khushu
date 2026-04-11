## MODIFIED Requirements

### Requirement: Adhan plays at prayer time even when screen is locked
The system SHALL play adhan audio at the scheduled prayer time using a foreground service that persists when the screen is locked and the app is killed.

#### Scenario: Screen locked, adhan fires
- **WHEN** the scheduled prayer time arrives and the screen is locked
- **THEN** the adhan audio plays through the speaker

#### Scenario: App killed, adhan fires
- **WHEN** the app has been swiped away/killed and the scheduled prayer time arrives
- **THEN** the adhan audio still plays (foreground service persists)

### Requirement: Stop button works from lock screen
The system SHALL show a "Stop Adhan" button on the notification that stops playback without requiring the user to unlock their phone.

#### Scenario: Stop from lock screen
- **WHEN** adhan is playing and user taps "Stop Adhan" on the lock screen notification
- **THEN** the adhan stops immediately

#### Scenario: Stop from unlocked screen
- **WHEN** adhan is playing and user taps "Stop Adhan" on the notification
- **THEN** the adhan stops immediately

### Requirement: Sound notification for non-adhan prayers
The system SHALL show a standard Android notification with system sound for prayers set to "Sound" type.

#### Scenario: Sound notification
- **WHEN** a prayer set to "Sound" reaches its scheduled time
- **THEN** a standard notification appears with the default system notification sound

### Requirement: Test button fires notification immediately
The system SHALL provide a test button that fires a notification immediately for testing purposes.

#### Scenario: Test adhan
- **WHEN** user taps "Test Notification Now" with a prayer set to Adhan
- **THEN** the adhan plays immediately with the stop notification

#### Scenario: Test sound
- **WHEN** user taps "Test Notification Now" with all prayers set to Sound
- **THEN** a system notification sound plays immediately

### Requirement: Adhan auto-stops when finished
The system SHALL automatically stop the adhan and dismiss the notification when the audio file finishes playing.

#### Scenario: Adhan completes naturally
- **WHEN** the adhan audio reaches the end
- **THEN** playback stops and the notification is dismissed

### Requirement: Test buttons for development
The system SHALL provide test buttons in the notification settings page that allow testing notifications without waiting for actual prayer times.

#### Scenario: Test now (3 seconds)
- **WHEN** user taps "Test Notification Now"
- **THEN** an adhan alarm fires in 3 seconds with full notification + audio

#### Scenario: Test in 30 seconds
- **WHEN** user taps "Test in 30s"
- **THEN** an alarm is scheduled for 30 seconds from now, giving user time to lock screen

#### Scenario: Test sound only
- **WHEN** user taps "Test Sound"
- **THEN** a standard system notification sound plays immediately

### Requirement: Debug info visible during development
The system SHALL show debug information on the notification settings page including next scheduled alarm time and alarm package status.

#### Scenario: Debug overlay shows scheduled alarms
- **WHEN** user views the notification settings page
- **THEN** they can see which alarms are currently scheduled and when
