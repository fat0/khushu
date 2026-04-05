class PrayerTimeEntry {
  final String name;
  final String time;
  final String? secondaryName;
  final String? secondaryTime;

  const PrayerTimeEntry({
    required this.name,
    required this.time,
    this.secondaryName,
    this.secondaryTime,
  });

  bool get hasDualTime => secondaryTime != null;
}

class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String? asrHanafi;
  final String maghrib;
  final String isha;
  final DateTime date;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    this.asrHanafi,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerTimes.fromAlAdhanJson(Map<String, dynamic> json, DateTime date) {
    return PrayerTimes(
      fajr: json['Fajr'] as String,
      sunrise: json['Sunrise'] as String,
      dhuhr: json['Dhuhr'] as String,
      asr: json['Asr'] as String,
      maghrib: json['Maghrib'] as String,
      isha: json['Isha'] as String,
      date: date,
    );
  }

  PrayerTimes withHanafiAsr(String hanafiAsr) {
    return PrayerTimes(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      asrHanafi: hanafiAsr,
      maghrib: maghrib,
      isha: isha,
      date: date,
    );
  }

  List<PrayerTimeEntry> toDisplayList() {
    return [
      PrayerTimeEntry(name: 'Fajr', time: fajr),
      PrayerTimeEntry(name: 'Sunrise', time: sunrise),
      PrayerTimeEntry(name: 'Dhuhr', time: dhuhr),
      PrayerTimeEntry(
        name: 'Asr',
        time: asr,
        secondaryName: asrHanafi != null ? 'Asr (Hanafi)' : null,
        secondaryTime: asrHanafi,
      ),
      PrayerTimeEntry(name: 'Maghrib', time: maghrib),
      PrayerTimeEntry(name: 'Isha', time: isha),
    ];
  }

  /// Returns the current prayer (the most recent prayer that has started)
  PrayerTimeEntry currentPrayer(DateTime now) {
    final prayers = [
      PrayerTimeEntry(name: 'Fajr', time: fajr),
      PrayerTimeEntry(name: 'Dhuhr', time: dhuhr),
      PrayerTimeEntry(name: 'Asr', time: asr),
      PrayerTimeEntry(name: 'Maghrib', time: maghrib),
      PrayerTimeEntry(name: 'Isha', time: isha),
    ];

    final nowMinutes = now.hour * 60 + now.minute;
    PrayerTimeEntry current = prayers.last; // default to Isha

    for (final entry in prayers) {
      final parts = entry.time.split(':');
      final entryMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (entryMinutes <= nowMinutes) {
        current = entry;
      }
    }

    return current;
  }

  PrayerTimeEntry nextPrayer(DateTime now) {
    final entries = [
      PrayerTimeEntry(name: 'Fajr', time: fajr),
      PrayerTimeEntry(name: 'Sunrise', time: sunrise),
      PrayerTimeEntry(name: 'Dhuhr', time: dhuhr),
      PrayerTimeEntry(name: 'Asr', time: asr),
      PrayerTimeEntry(name: 'Maghrib', time: maghrib),
      PrayerTimeEntry(name: 'Isha', time: isha),
    ];

    final nowMinutes = now.hour * 60 + now.minute;

    for (final entry in entries) {
      final parts = entry.time.split(':');
      final entryMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      if (entryMinutes > nowMinutes) {
        return entry;
      }
    }

    return PrayerTimeEntry(name: 'Fajr', time: fajr);
  }
}
