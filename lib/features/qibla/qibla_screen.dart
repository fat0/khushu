import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'qibla_provider.dart';
import 'widgets/calibration_overlay.dart';
import 'widgets/compass_widget.dart';
import 'widgets/static_bearing.dart';

class _CrosshairPainter extends CustomPainter {
  final bool isDark;
  const _CrosshairPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.sage : AppColors.deepGreen)
          .withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CrosshairPainter old) => old.isDark != isDark;
}

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(qiblaProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final normalizedBearing = state.qiblaOffset != null
        ? (state.qiblaOffset! % 360).toStringAsFixed(1)
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Qibla Compass', style: theme.textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Full-screen crosshair lines (fixed, not rotating)
          Positioned.fill(
            child: CustomPaint(
              painter: _CrosshairPainter(isDark: isDark),
            ),
          ),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (!state.hasMagnetometer)
            StaticBearing(
              bearing: state.staticBearing!,
              compassDirection: state.compassDirection!,
            )
          else
            Column(
              children: [
                const Spacer(),
                CompassWidget(
                  qiblaDirection: state.qiblaDirection ?? 0,
                  compassHeading: state.compassHeading ?? 0,
                  qiblaOffset: state.qiblaOffset ?? 0,
                  isAligned: state.isAligned,
                ),
                const Spacer(),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextButton(
                      onPressed: () =>
                          ref.read(qiblaProvider.notifier).showCalibration(),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                      ),
                      child: const Text('Calibrate'),
                    ),
                  ),
                ),
              ],
            ),
          if (state.needsCalibration)
            CalibrationOverlay(
              onDismiss: () =>
                  ref.read(qiblaProvider.notifier).dismissCalibration(),
            ),
        ],
      ),
    );
  }
}
