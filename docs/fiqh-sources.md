# Fiqh Data Sources

This document records the authoritative sources behind all prayer time calculations, rakat counts, and juristic rulings used in Khushu.

## Prayer Times — AlAdhan API

**Source:** [AlAdhan Prayer Times API](https://aladhan.com/prayer-times-api)

The app fetches prayer times from the AlAdhan API using two key parameters:

### Calculation Methods (`method`)

| ID | Name | Region | Source |
|----|------|--------|--------|
| 0 | Shia Ithna-Ashari (Qum) | Iran/Shia | Institute of Geophysics, University of Tehran |
| 1 | University of Islamic Sciences, Karachi | Pakistan/India | University of Islamic Sciences, Karachi |
| 2 | ISNA | North America | Islamic Society of North America |
| 3 | Muslim World League (MWL) | Europe/default | Muslim World League |
| 4 | Umm Al-Qura | Saudi Arabia | Umm Al-Qura University, Makkah |
| 5 | Egyptian General Authority | Egypt/Africa | Egyptian General Authority of Survey |
| 7 | Tehran (Univ. of Geophysics) | Iran | Institute of Geophysics, University of Tehran |
| 8 | Gulf Region | Gulf states | — |
| 13 | Turkey (Diyanet) | Turkey | Diyanet İşleri Başkanlığı |

### Asr Calculation (`school`)

| Value | Method | Used by |
|-------|--------|---------|
| 0 | Shadow = 1x object height | Maliki, Hanbali, Shafi'i, Ja'fari |
| 1 | Shadow = 2x object height | Hanafi |

The app auto-detects the regional calculation method based on the user's GPS coordinates (see `lib/core/location/region_detector.dart`). For Sunni users, both school=0 and school=1 are fetched to display dual Asr times.

## Rakat Counts — Sunni

### Sources

- **Hanafi:** *Al-Hidayah* by al-Marghinani; *Radd al-Muhtar* by Ibn Abidin
- **Maliki:** *Al-Mudawwanah* by Sahnun; *Bidayat al-Mujtahid* by Ibn Rushd
- **Shafi'i:** *Al-Umm* by Imam al-Shafi'i; *Minhaj al-Talibin* by al-Nawawi
- **Hanbali:** *Al-Mughni* by Ibn Qudamah; *Zad al-Mustaqni'* by al-Hajjawi
- **Cross-madhab comparison:** *Al-Fiqh 'ala al-Madhahib al-Arba'ah* by al-Jaziri

### Rakat Data (Sunni — all 4 schools combined)

| Prayer | Rakat | Notes |
|--------|-------|-------|
| Fajr | 2 Sunnah, 2 Fard | Unanimous across all 4 schools |
| Dhuhr | 2 Sunnah (4 for Hanafi), 4 Fard, 2 Sunnah | Hanafi has 4 sunnah before instead of 2 |
| Asr | 4 Fard | Unanimous (sunnah ghair mu'akkadah omitted for simplicity) |
| Maghrib | 3 Fard, 2 Sunnah | Unanimous |
| Isha | 4 Fard, 2 Sunnah, 3 Witr | Witr is wajib in Hanafi fiqh, sunnah mu'akkadah in the other 3 |

### Witr Differences

| School | Witr Status | Witr Method |
|--------|-------------|-------------|
| Hanafi | Wajib (obligatory) | 3 rakat continuous, qunut before ruku |
| Maliki | Sunnah mu'akkadah | 1 rakat minimum (after 2 shaf') |
| Shafi'i | Sunnah mu'akkadah | 1, 3, 5, 7, 9, or 11 rakat; if 3, prayed as 2+1 with salam between |
| Hanbali | Sunnah mu'akkadah | 1 rakat minimum; preferred 3 as 2+1 |

**App simplification:** All Sunni schools show "3 Witr" as the common/representative count. The label "Witr" is used for all (not "Wajib" for Hanafi) per user feedback.

## Rakat Counts — Ja'fari (Twelver Shia)

### Sources — Verified

- **Primary:** *Tawdih al-Masa'il* by Ayatollah al-Uzma Sayyid Ali al-Husayni al-Sistani
  - **Ruling 751:** Daily nafilah counts (34 rakat total)
  - **Ruling 754:** Travel exceptions
  - **Issue 772-773:** Isha nafilah (seated, counts as 1)
  - **Issue 776-781:** Nafilah timing rules
  - Website: [sistani.org/english/book/48/2215/](https://www.sistani.org/english/book/48/2215/)
- **Secondary:** *Man La Yahduruhu al-Faqih* by Shaykh al-Saduq
- **Cross-reference:** [al-islam.org](https://www.al-islam.org) — Islamic Laws by Sayyid Ali Hussaini Sistani

### Rakat Data (Ja'fari)

| Prayer | Rakat | Verified Source |
|--------|-------|----------------|
| Fajr | 2 Nafilah, 2 Fard | Ruling 751 |
| Dhuhr | 8 Nafilah, 4 Fard | Ruling 751 |
| Asr | 8 Nafilah, 4 Fard | Ruling 751 |
| Maghrib | 3 Fard, 4 Nafilah | Ruling 751 |
| Isha | 4 Fard, 2 Nafilah | Ruling 751, Issue 772 |

**Ruling 751 (exact quote):** "These number thirty-four rak'ahs (on days other than Friday): eight rak'ahs are the nafilah of zuhr, eight of 'asr, four of maghrib, two of 'isha, eleven of the night, and two of subh."

**Total: 34 daily rakat** = 2 (Fajr) + 8 (Dhuhr) + 8 (Asr) + 4 (Maghrib) + 2 (Isha) + 11 (Salat al-Layl, not shown in app — see below)

### Isha Nafilah — Seated

Per Issue 772: "The Nafilah for Isha prayers should be offered while sitting, and therefore its 2 Rak'ats are counted as one."

### Salat al-Layl (Not in App)

Salat al-Layl is an 11-rakat prayer prayed between midnight and Fajr adhan:
- 8 rakat: Nafilat al-Layl (in 2-rakat units)
- 2 rakat: Shaf'a
- 1 rakat: Witr (with qunut)

This is included in Sistani's 34 daily rakat total but is **not shown in the app** because it is a separate prayer time, not attached to any of the 5 daily prayers. It may be added as a future feature.

### Terminology

| Sunni Term | Ja'fari Term | Meaning |
|-----------|-------------|---------|
| Sunnah / Sunnah mu'akkadah | Nafilah | Recommended prayer |
| Witr | Witr (part of Salat al-Layl) | Odd-numbered prayer |
| — | Mustahabb | Fiqhi category: recommended |

The app uses "Sunnah" for Sunni users and "Nafilah" for Ja'fari users.

## Friday Adjustment (Not Yet Implemented)

On Fridays, Ja'fari fiqh adds 4 extra rakat to the Dhuhr+Asr nafilah block (total becomes 20 instead of 16), making the Friday total 38 rakat. This is not yet implemented in the app.

## Travel Rules (Not Yet Implemented)

- **Ja'fari (Ruling 754):** Travelers cannot perform Dhuhr and Asr nafilah. Isha nafilah may be performed with the intention of raja' (hope of reward).
- **Sunni:** Sunnah prayers are generally omitted while traveling across all 4 schools, except Fajr sunnah and Witr which are maintained.

## Adhan Audio Sources

All adhan recordings are from the Internet Archive, licensed under **Public Domain Mark 1.0**.

| File | Source | URL | Usage |
|------|--------|-----|-------|
| `assets/audio/adhan_standard.ogg` | Dhuhr Adhan, Doha, Qatar (2013-2014) | [archive.org/details/adhan.recordings.from.doha.qatar](https://archive.org/details/adhan.recordings.from.doha.qatar) | All prayers except Fajr |
| `assets/audio/adhan_fajr.ogg` | Fajr Adhan, Doha, Qatar (2013-2014) | [archive.org/details/adhan.recordings.from.doha.qatar](https://archive.org/details/adhan.recordings.from.doha.qatar) | Fajr only (includes "As-salatu khayrun min an-nawm") |

**License:** Public Domain Mark 1.0 — no copyright restrictions, free for commercial use.

**Known issues:**
- Field recordings (ambient mosque sound, not studio quality)
- Adhans include dua at the end (to be trimmed in future update)
- Future: add multiple adhan options (Al Aqsa, Makkah, etc.) pending proper licensing
