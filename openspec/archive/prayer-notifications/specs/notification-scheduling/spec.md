## ADDED Requirements

### Requirement: Schedule notifications for all daily prayers
The system SHALL schedule exact-time notifications for each prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) based on the current day's prayer times and the user's selected location timezone.

#### Scenario: Notifications scheduled after prayer times load
- **WHEN** prayer times are fetched (from API or cache)
- **THEN** notifications are scheduled for each prayer that hasn't passed yet today

#### Scenario: Notifications use location timezone
- **WHEN** user's location is set to a remote city (e.g., Istanbul while phone is in US)
- **THEN** notifications fire at the correct local time for the selected location

#### Scenario: Past prayers are skipped
- **WHEN** the app loads and some prayers have already passed
- **THEN** only future prayers for today are scheduled

### Requirement: Notifications persist across app restarts
The system SHALL re-schedule notifications when the app is opened, ensuring they are not lost if the app was closed.

#### Scenario: App closed and reopened
- **WHEN** user closes and reopens the app
- **THEN** all pending prayer notifications are still scheduled

### Requirement: Notifications persist across device reboots
The system SHALL register a boot receiver to re-schedule notifications after device restart.

#### Scenario: Device rebooted
- **WHEN** the device is rebooted
- **THEN** prayer notifications are re-scheduled on boot

### Requirement: Notifications re-schedule on settings change
The system SHALL cancel and re-schedule all notifications when prayer times change (location, fiqh, or calculation method change).

#### Scenario: User changes location
- **WHEN** user changes their location in settings
- **THEN** old notifications are cancelled and new ones scheduled for the new location's prayer times

### Requirement: Sunrise has no notification
The system SHALL NOT schedule a notification for Sunrise since it is not a prayer.

#### Scenario: Sunrise excluded
- **WHEN** notifications are scheduled for the day
- **THEN** no notification is created for Sunrise
