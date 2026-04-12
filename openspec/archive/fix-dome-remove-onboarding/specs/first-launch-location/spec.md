## ADDED Requirements

### Requirement: App launches directly to prayer times
The app SHALL skip the onboarding screen and launch directly to the prayer times screen for all users, including first-time users.

#### Scenario: First-time user opens app
- **WHEN** a user opens the app for the first time
- **THEN** the prayer times screen is displayed (not an onboarding screen)

#### Scenario: Returning user opens app
- **WHEN** a user who has previously used the app opens it
- **THEN** the prayer times screen is displayed with their saved location and fiqh

### Requirement: Default fiqh for new users
The app SHALL default to Sunni Standard (Maliki, Shafi'i, Hanbali) fiqh for new users who have not selected a fiqh.

#### Scenario: New user sees prayer times
- **WHEN** a first-time user reaches the prayer times screen
- **THEN** prayer times are calculated using Sunni Standard (school=0) with the auto-detected regional method

### Requirement: Silent GPS detection on first launch
The app SHALL attempt GPS location detection silently in the background on first launch without blocking the UI.

#### Scenario: GPS succeeds
- **WHEN** the app launches for the first time and GPS returns a position
- **THEN** the location is saved, prayer times are fetched, and the city name is displayed in the header

#### Scenario: GPS fails
- **WHEN** the app launches for the first time and GPS fails or times out
- **THEN** a dialog is displayed explaining why location is needed and providing a city search field

### Requirement: Location fallback dialog
When GPS fails, the app SHALL display a dialog with a helpful message explaining why location is needed and a city search input.

#### Scenario: Dialog content
- **WHEN** the location fallback dialog is shown
- **THEN** it displays a message like "We need your location to calculate accurate prayer times for your area" and a city search field

#### Scenario: User enters city in dialog
- **WHEN** the user types a city name and submits
- **THEN** the city is geocoded, location is saved, the dialog closes, and prayer times load

#### Scenario: Dialog is not dismissable without location
- **WHEN** the user tries to dismiss the dialog without entering a location
- **THEN** the dialog remains visible

### Requirement: Dome header renders correctly
The dome header SVG SHALL render with the arc curving upward (like a real mosque dome), minarets pointing upward, and the crescent moon shaped like the letter "C" with a slight upward tilt on the opening.

#### Scenario: Dome arc direction
- **WHEN** the prayer times screen is displayed
- **THEN** the dome arc curves upward from left to right, forming a half-circle dome shape

#### Scenario: Minaret orientation
- **WHEN** the prayer times screen is displayed
- **THEN** the minarets are vertical lines pointing upward with pointed tops

#### Scenario: Crescent moon shape
- **WHEN** the prayer times screen is displayed
- **THEN** the crescent moon is shaped like the letter "C" (opening facing right) with a slight upward tilt
