import 'dart:async';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/qibla/qibla_service.dart';
import '../settings/settings_provider.dart';

class QiblaState {
  final bool isLoading;
  final bool hasMagnetometer;
  final double? qiblaDirection;  // screen-relative Qibla angle (already adjusted)
  final double? compassHeading;  // raw compass heading
  final double? qiblaOffset;    // fixed bearing from North (for display)
  final double? staticBearing;
  final String? compassDirection;
  final bool needsCalibration;

  const QiblaState({
    this.isLoading = true,
    this.hasMagnetometer = true,
    this.qiblaDirection,
    this.compassHeading,
    this.qiblaOffset,
    this.staticBearing,
    this.compassDirection,
    this.needsCalibration = false,
  });

  const QiblaState.loading()
      : isLoading = true,
        hasMagnetometer = true,
        qiblaDirection = null,
        compassHeading = null,
        qiblaOffset = null,
        staticBearing = null,
        compassDirection = null,
        needsCalibration = false;

  const QiblaState.noMagnetometer({
    required double this.staticBearing,
    required String this.compassDirection,
  })  : isLoading = false,
        hasMagnetometer = false,
        qiblaDirection = null,
        compassHeading = null,
        qiblaOffset = null,
        needsCalibration = false;

  /// Aligned when the Qibla arrow points straight up (near 0° on screen).
  bool get isAligned {
    if (qiblaDirection == null) return false;
    final screenAngle = qiblaDirection! % 360;
    return screenAngle <= 5 || screenAngle >= 355;
  }
}

final qiblaProvider =
    StateNotifierProvider.autoDispose<QiblaNotifier, QiblaState>(
  (ref) => QiblaNotifier(ref),
);

class QiblaNotifier extends StateNotifier<QiblaState> {
  final Ref? _ref;
  StreamSubscription<QiblahDirection>? _qiblahSub;
  StreamSubscription<CompassEvent?>? _compassSub;
  bool _manualCalibration = false;

  QiblaNotifier(Ref ref)
      : _ref = ref,
        super(const QiblaState.loading()) {
    _init();
  }

  QiblaNotifier.test() : _ref = null, super(const QiblaState.loading());

  Future<void> _init() async {
    final hasSensor = await QiblaService.hasMagnetometer();

    if (!hasSensor) {
      final settings = _ref!.read(settingsProvider);
      final lat = settings.latitude;
      final lng = settings.longitude;
      if (lat != null && lng != null) {
        final bearing = QiblaService.getStaticBearing(lat, lng);
        final direction = QiblaService.bearingToCompassDirection(bearing);
        state = QiblaState.noMagnetometer(
          staticBearing: bearing,
          compassDirection: direction,
        );
      }
      return;
    }

    _qiblahSub = QiblaService.qiblahStream.listen((event) {
      state = QiblaState(
        isLoading: false,
        hasMagnetometer: true,
        qiblaDirection: event.qiblah,
        compassHeading: event.direction,
        qiblaOffset: event.offset,
        needsCalibration: state.needsCalibration,
      );
    });

    _compassSub = QiblaService.compassEvents.listen((event) {
      if (event == null) return;
      final accuracy = event.accuracy;
      if (accuracy != null && !_manualCalibration) {
        state = QiblaState(
          isLoading: state.isLoading,
          hasMagnetometer: true,
          qiblaDirection: state.qiblaDirection,
          compassHeading: state.compassHeading,
          qiblaOffset: state.qiblaOffset,
          needsCalibration: accuracy < 15,
        );
      }
    });
  }

  void dismissCalibration() {
    _manualCalibration = false;
    state = QiblaState(
      isLoading: state.isLoading,
      hasMagnetometer: state.hasMagnetometer,
      qiblaDirection: state.qiblaDirection,
      compassHeading: state.compassHeading,
      qiblaOffset: state.qiblaOffset,
      needsCalibration: false,
    );
  }

  void showCalibration() {
    _manualCalibration = true;
    state = QiblaState(
      isLoading: state.isLoading,
      hasMagnetometer: state.hasMagnetometer,
      qiblaDirection: state.qiblaDirection,
      compassHeading: state.compassHeading,
      qiblaOffset: state.qiblaOffset,
      needsCalibration: true,
    );
  }

  @override
  void dispose() {
    _qiblahSub?.cancel();
    _compassSub?.cancel();
    QiblaService.dispose();
    super.dispose();
  }
}
