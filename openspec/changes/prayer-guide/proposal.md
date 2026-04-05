## Why

New Muslims, children, and those learning to pray need guidance on how many rakat to perform for each prayer and what type (fard, sunnah, witr). This varies by fiqh, and no single concise reference exists in-app. Adding this makes Khushu not just a prayer times app but a learning tool for the Ummah.

## What Changes

- Tapping any prayer row in the prayer times list expands it inline to show a rakat breakdown
- Rakat data is fiqh-aware: shows the correct counts and terminology for the user's selected fiqh (Maliki/Hanbali/Shafi'i, Hanafi, or Ja'fari)
- Sunni fiqhs show "sunnah" terminology; Ja'fari shows "nafilah"
- Witr is labeled "wajib" for Hanafi, "sunnah" for other Sunni schools, "mustahabb" for Ja'fari
- Sunrise row expands with a note: "Marks the end of Fajr time — no prayer"
- Rakat data is hardcoded (static fiqh data, no API needed)

## Capabilities

### New Capabilities
- `rakat-data`: Static data model mapping each prayer × fiqh to rakat counts (fard, sunnah/nafilah, witr) with fiqh-specific terminology
- `prayer-row-expansion`: Tap-to-expand UI on prayer time rows showing rakat breakdown inline

### Modified Capabilities

## Impact

- `lib/features/prayer_times/widgets/prayer_time_row.dart` — add expandable section
- `lib/features/prayer_times/widgets/prayer_times_list.dart` — pass fiqh to rows
- New file for rakat data model
- No new dependencies, no API changes, no breaking changes
