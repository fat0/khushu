import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/qibla/qibla_service.dart';
import '../settings/settings_provider.dart';

class QiblaState {
  final bool isLoading;
  final bool hasMagnetometer;
  final double? qiblaDirection;
  final double? compassHeading;
  final double? staticBearing;
  final String? compassDirection;
  final bool needsCalibration;

  const QiblaState({
    this.isLoading = true,
    this.hasMagnetometer = true,
    this.qiblaDirection,
    this.compassHeading,
    this.staticBearing,
    this.compassDirection,
    this.needsCalibration = false,
  });

  const QiblaState.loading()
      : isLoading = true,
        hasMagnetometer = true,
        qiblaDirection = null,
        compassHeading = null,
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
        needsCalibration = false;

  bool get isAligned {
    if (qiblaDirection == null || compassHeading == null) return false;
    final diff = (qiblaDirection! - compassHeading!).abs() % 360;
    return diff <= 5 || diff >= 355;
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
        needsCalibration: state.needsCalibration,
      );
    });

    _compassSub = QiblaService.compassEvents.listen((event) {
      if (event == null) return;
      final accuracy = event.accuracy;
      if (accuracy != null) {
        state = QiblaState(
          isLoading: state.isLoading,
          hasMagnetometer: true,
          qiblaDirection: state.qiblaDirection,
          compassHeading: state.compassHeading,
          needsCalibration: accuracy < 15,
        );
      }
    });
  }

  void dismissCalibration() {
    state = QiblaState(
      isLoading: state.isLoading,
      hasMagnetometer: state.hasMagnetometer,
      qiblaDirection: state.qiblaDirection,
      compassHeading: state.compassHeading,
      needsCalibration: false,
    );
  }

  void showCalibration() {
    state = QiblaState(
      isLoading: state.isLoading,
      hasMagnetometer: state.hasMagnetometer,
      qiblaDirection: state.qiblaDirection,
      compassHeading: state.compassHeading,
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
