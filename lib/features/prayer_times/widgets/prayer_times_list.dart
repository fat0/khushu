import 'package:flutter/material.dart';
import '../../../core/models/prayer_times.dart';
import 'prayer_time_row.dart';

class PrayerTimesList extends StatelessWidget {
  final PrayerTimes prayerTimes;
  final bool combinePrayers;
  final String nextPrayerName;

  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
    required this.combinePrayers,
    required this.nextPrayerName,
  });

  @override
  Widget build(BuildContext context) {
    final entries = prayerTimes.toDisplayList(combine: combinePrayers);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: entries.map((entry) {
          return PrayerTimeRow(
            name: entry.name,
            time: entry.time,
            isHighlighted: entry.name == nextPrayerName ||
                (entry.isCombined && entry.name.contains(nextPrayerName)),
          );
        }).toList(),
      ),
    );
  }
}
