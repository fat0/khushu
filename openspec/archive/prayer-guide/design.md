## Context

Khushu currently shows prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) in a list with the current prayer highlighted. Users can select their fiqh in settings (Maliki/Hanbali/Shafi'i, Hanafi, or Ja'fari) which affects prayer time calculation. There is no guidance on how to actually perform each prayer — how many rakat, which are fard vs sunnah, etc.

The rakat data is classical Islamic jurisprudence that has been stable for centuries. It does not change and does not need an API — it should be hardcoded as a local data structure.

## Goals / Non-Goals

**Goals:**
- Tap any prayer row to expand and see rakat breakdown inline
- Show fiqh-appropriate counts and terminology (sunnah vs nafilah, wajib vs sunnah for witr)
- Sunrise row expands with an informational note instead of rakat data
- Keep the UI minimal and calm — consistent with the app's visual style

**Non-Goals:**
- Step-by-step prayer instructions (how to perform each rakat) — future feature
- Audio/visual prayer guide — future feature
- Splitting the Maliki/Hanbali/Shafi'i fiqh group into separate options — these share the same fard counts and we use mainstream Shafi'i/Hanbali sunnah counts as representative

## Decisions

**1. Data structure: Dart map keyed by (fiqh, prayer)**

Each entry contains a list of rakat items with: count, type label (fard/sunnah/nafilah/wajib), and position (before/after fard). This is a static const map — no database, no API.

*Alternative considered:* JSON asset file. Rejected because the data is small (~30 entries), type-safe Dart is simpler, and there's no need for runtime loading.

**2. UI: ExpansionTile-style inline expand on the existing prayer row**

Tapping a prayer row smoothly expands it to show a compact rakat summary below the time. Tapping again collapses it. Only one row can be expanded at a time.

*Alternative considered:* Bottom sheet or dialog. Rejected because inline expansion is faster, doesn't obscure other prayer times, and feels more natural for quick reference.

**3. Terminology adapts per fiqh**

- Maliki/Hanbali/Shafi'i and Hanafi: "Fard", "Sunnah", "Witr"
- Hanafi witr specifically labeled "Wajib" (not "Sunnah")
- Ja'fari: "Fard", "Nafilah", "Mustahabb"

**4. Sunrise is a special case**

Sunrise has no rakat data. It expands with a single line: "Marks the end of Fajr time — no prayer." Same expand/collapse behavior as other rows.

## Risks / Trade-offs

- **[Scholarly accuracy]** Sunnah counts have minor variations within each madhab. We use the mainstream (mashhur) position. → Mitigation: document sources in code comments; future feature could show minority opinions.
- **[Maliki flexibility]** The Maliki school is less prescriptive about exact sunnah counts than other schools. We group Maliki with Shafi'i/Hanbali and show specific numbers. → Mitigation: acceptable for MVP; a future "Maliki note" could be added.
