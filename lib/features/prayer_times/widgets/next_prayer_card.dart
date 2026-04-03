import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NextPrayerCard extends StatelessWidget {
  final String prayerName;
  final Duration countdown;

  const NextPrayerCard({
    super.key,
    required this.prayerName,
    required this.countdown,
  });

  String _formatCountdown(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'NEXT PRAYER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: AppColors.sage,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prayerName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCountdown(countdown),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.sage,
            ),
          ),
        ],
      ),
    );
  }
}
