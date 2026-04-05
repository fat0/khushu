import 'package:flutter/material.dart';
import '../../../core/models/prayer_times.dart';
import '../../../core/models/rakat_data.dart';
import '../../../core/models/user_settings.dart';
import 'prayer_time_row.dart';

class PrayerTimesList extends StatefulWidget {
  final PrayerTimes prayerTimes;
  final String currentPrayerName;
  final Fiqh fiqh;

  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
    required this.currentPrayerName,
    required this.fiqh,
  });

  @override
  State<PrayerTimesList> createState() => _PrayerTimesListState();
}

class _PrayerTimesListState extends State<PrayerTimesList> {
  String? _expandedPrayer;

  @override
  Widget build(BuildContext context) {
    final entries = widget.prayerTimes.toDisplayList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: entries.map((entry) {
          final rakatInfo = RakatData.getInfo(entry.name, widget.fiqh);
          final isHighlighted = entry.name == widget.currentPrayerName ||
              entry.name.startsWith(widget.currentPrayerName);
          return PrayerTimeRow(
            entry: entry,
            isHighlighted: isHighlighted,
            isExpanded: _expandedPrayer == entry.name,
            rakatInfo: rakatInfo,
            onTap: () {
              setState(() {
                _expandedPrayer =
                    _expandedPrayer == entry.name ? null : entry.name;
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
