## 1. Rakat Data Model

- [x] 1.1 Create `lib/core/models/rakat_data.dart` with static const data mapping each prayer × fiqh to rakat breakdown (count, type label, position). Include Sunrise special case.
- [x] 1.2 Write unit tests for rakat data — verify correct counts for all 3 fiqhs × 6 prayers (Fajr, Dhuhr, Asr, Maghrib, Isha, Sunrise)
- [x] 1.3 Verify fiqh-specific terminology: "Sunnah" for Sunni, "Nafilah" for Ja'fari, "Wajib" for Hanafi witr, "Mustahabb" for Ja'fari witr

## 2. Prayer Row Expansion UI

- [x] 2.1 Update `prayer_time_row.dart` to accept rakat data and support tap-to-expand with smooth animation
- [x] 2.2 Design the expanded section layout: compact inline display of rakat items (e.g., "2 Sunnah (before) · 4 Fard · 2 Sunnah (after)")
- [x] 2.3 Handle Sunrise special case: show "Marks the end of Fajr time — no prayer" instead of rakat data
- [x] 2.4 Ensure only one row can be expanded at a time (collapse previous when new one tapped)

## 3. Integration

- [x] 3.1 Update `prayer_times_list.dart` to pass user's current fiqh and rakat data to each prayer row
- [x] 3.2 Update `prayer_times_screen.dart` to read fiqh from settings provider and pass to list
- [x] 3.3 Verify expansion works correctly with current prayer highlighting (expanded row should still show highlight)

## 4. Testing & Verification

- [x] 4.1 Run all existing tests — ensure no regressions
- [ ] 4.2 Deploy to phone and verify: tap each prayer row, check rakat counts match spec for default fiqh
- [ ] 4.3 Change fiqh in settings, return to prayer times, verify rakat data updates
- [ ] 4.4 Verify Sunrise shows informational note
