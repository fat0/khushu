import 'package:flutter/material.dart';
import '../../../core/models/prayer_times.dart';
import 'prayer_time_row.dart';

class PrayerTimesList extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final String currentPrayerName;

  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
    required this.currentPrayerName,
  });

  @override
  Widget build(BuildContext context) {
    final entries = prayerTimes.toDisplayList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: entries.map((entry) {
          return PrayerTimeRow(
            name: entry.name,
            time: entry.time,
            isHighlighted: entry.name == currentPrayerName,
          );
        }).toList(),
      ),
    );
  }
}
