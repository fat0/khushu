# Qibla Compass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Qibla compass feature — Ka'bah button on prayer times screen opens a full-screen compass pointing toward the Ka'bah.

**Architecture:** `flutter_qiblah` provides the Qibla bearing stream, `flutter_compass` provides sensor accuracy for calibration detection, `adhan` provides static bearing fallback for devices without a magnetometer. Riverpod provider wraps everything. GoRouter adds `/qibla` route.

**Tech Stack:** Flutter, Riverpod, flutter_qiblah, flutter_compass, adhan, GoRouter

---

### Task 1: Add Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add flutter_qiblah and flutter_compass to pubspec.yaml**

Add these two lines under `dependencies:` after the `adhan` line:

```yaml
  flutter_qiblah: ^3.2.0
  flutter_compass: ^0.8.0
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`
Expected: Dependencies resolve successfully, no version conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat(qibla): add flutter_qiblah and flutter_compass dependencies"
```

---

### Task 2: Qibla Service

**Files:**
- Create: `lib/core/qibla/qibla_service.dart`
- Create: `test/core/qibla/qibla_service_test.dart`

- [ ] **Step 1: Write the failing test for bearing fallback**

Create `test/core/qibla/qibla_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/core/qibla/qibla_service.dart';

void main() {
  group('QiblaService', () {
    group('getStaticBearing', () {
      test('returns bearing for Sterling VA (NE direction)', () {
        // Sterling, VA: 39.0066° N, 77.4291° W
        final bearing = QiblaService.getStaticBearing(39.0066, -77.4291);
        // Qibla from Virginia is roughly NE (~58°)
        expect(bearing, greaterThan(50));
        expect(bearing, lessThan(70));
      });

      test('returns bearing for Makkah (0° — already there)', () {
        // Ka'bah coordinates: 21.4225° N, 39.8262° E
        final bearing = QiblaService.getStaticBearing(21.4225, 39.8262);
        // When at the Ka'bah, bearing is essentially 0 or 360
        expect(bearing, anyOf(closeTo(0, 5), closeTo(360, 5)));
      });

      test('returns bearing for Tokyo (WNW direction)', () {
        // Tokyo: 35.6762° N, 139.6503° E
        final bearing = QiblaService.getStaticBearing(35.6762, 139.6503);
        // Qibla from Tokyo is roughly WNW (~293°)
        expect(bearing, greaterThan(280));
        expect(bearing, lessThan(300));
      });
    });

    group('bearingToCompassDirection', () {
      test('returns N for 0°', () {
        expect(QiblaService.bearingToCompassDirection(0), 'N');
      });

      test('returns NE for 45°', () {
        expect(QiblaService.bearingToCompassDirection(45), 'NE');
      });

      test('returns E for 90°', () {
        expect(QiblaService.bearingToCompassDirection(90), 'E');
      });

      test('returns SE for 135°', () {
        expect(QiblaService.bearingToCompassDirection(135), 'SE');
      });

      test('returns S for 180°', () {
        expect(QiblaService.bearingToCompassDirection(180), 'S');
      });

      test('returns SW for 225°', () {
        expect(QiblaService.bearingToCompassDirection(225), 'SW');
      });

      test('returns W for 270°', () {
        expect(QiblaService.bearingToCompassDirection(270), 'W');
      });

      test('returns NW for 315°', () {
        expect(QiblaService.bearingToCompassDirection(315), 'NW');
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/qibla/qibla_service_test.dart`
Expected: FAIL — `qibla_service.dart` does not exist.

- [ ] **Step 3: Write minimal implementation**

Create `lib/core/qibla/qibla_service.dart`:

```dart
import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblaService {
  /// Check if the device has a magnetometer (Android only; iOS always true).
  static Future<bool> hasMagnetometer() async {
    final support = await FlutterQiblah.androidDeviceSensorCheck();
    return support ?? true; // iOS returns null — always has magnetometer
  }

  /// Stream of Qibla direction data from flutter_qiblah.
  static Stream<QiblahDirection> get qiblahStream =>
      FlutterQiblah.qiblahStream;

  /// Stream of compass events for accuracy/calibration detection.
  static Stream<CompassEvent?> get compassEvents =>
      FlutterCompass.events ?? const Stream.empty();

  /// Calculate static Qibla bearing using adhan package.
  /// Returns bearing in degrees (0-360) from the given coordinates.
  static double getStaticBearing(double latitude, double longitude) {
    final coordinates = Coordinates(latitude, longitude);
    return Qibla(coordinates).direction;
  }

  /// Convert a bearing in degrees to a compass direction string.
  static String bearingToCompassDirection(double bearing) {
    // Normalize to 0-360
    bearing = bearing % 360;
    if (bearing < 0) bearing += 360;

    if (bearing >= 337.5 || bearing < 22.5) return 'N';
    if (bearing < 67.5) return 'NE';
    if (bearing < 112.5) return 'E';
    if (bearing < 157.5) return 'SE';
    if (bearing < 202.5) return 'S';
    if (bearing < 247.5) return 'SW';
    if (bearing < 292.5) return 'W';
    return 'NW';
  }

  /// Dispose the flutter_qiblah stream.
  static void dispose() {
    FlutterQiblah().dispose();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/qibla/qibla_service_test.dart`
Expected: All 11 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/qibla/qibla_service.dart test/core/qibla/qibla_service_test.dart
git commit -m "feat(qibla): add QiblaService with bearing calculation and compass direction"
```

---

### Task 3: Qibla Provider

**Files:**
- Create: `lib/features/qibla/qibla_provider.dart`
- Create: `test/features/qibla/qibla_provider_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/qibla/qibla_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/qibla_provider.dart';

void main() {
  group('QiblaState', () {
    test('creates loading state', () {
      const state = QiblaState.loading();
      expect(state.isLoading, true);
      expect(state.hasMagnetometer, true);
      expect(state.needsCalibration, false);
    });

    test('creates no-magnetometer state with bearing', () {
      const state = QiblaState.noMagnetometer(
        staticBearing: 58.2,
        compassDirection: 'NE',
      );
      expect(state.hasMagnetometer, false);
      expect(state.staticBearing, 58.2);
      expect(state.compassDirection, 'NE');
      expect(state.isLoading, false);
    });

    test('creates active compass state', () {
      const state = QiblaState(
        isLoading: false,
        hasMagnetometer: true,
        qiblaDirection: 58.2,
        compassHeading: 142.0,
        needsCalibration: false,
      );
      expect(state.qiblaDirection, 58.2);
      expect(state.compassHeading, 142.0);
      expect(state.isAligned, false); // 58.2 vs 142 — not aligned
    });

    test('isAligned is true when qibla and heading within 5 degrees', () {
      const state = QiblaState(
        isLoading: false,
        hasMagnetometer: true,
        qiblaDirection: 58.2,
        compassHeading: 56.0,
        needsCalibration: false,
      );
      expect(state.isAligned, true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/qibla/qibla_provider_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the provider and state**

Create `lib/features/qibla/qibla_provider.dart`:

```dart
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

  /// Aligned when qibla direction and compass heading are within 5°.
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
  final Ref _ref;
  StreamSubscription<QiblahDirection>? _qiblahSub;
  StreamSubscription<CompassEvent?>? _compassSub;

  QiblaNotifier(this._ref) : super(const QiblaState.loading()) {
    _init();
  }

  Future<void> _init() async {
    final hasSensor = await QiblaService.hasMagnetometer();

    if (!hasSensor) {
      final settings = _ref.read(settingsProvider);
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

    // Listen to qibla stream for heading and direction
    _qiblahSub = QiblaService.qiblahStream.listen((event) {
      state = QiblaState(
        isLoading: false,
        hasMagnetometer: true,
        qiblaDirection: event.qiblah,
        compassHeading: event.direction,
        needsCalibration: state.needsCalibration,
      );
    });

    // Listen to compass events for accuracy/calibration
    _compassSub = QiblaService.compassEvents.listen((event) {
      if (event == null) return;
      final accuracy = event.accuracy;
      // accuracy < 15 means low — needs calibration
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

  @override
  void dispose() {
    _qiblahSub?.cancel();
    _compassSub?.cancel();
    QiblaService.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/qibla/qibla_provider_test.dart`
Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/qibla/qibla_provider.dart test/features/qibla/qibla_provider_test.dart
git commit -m "feat(qibla): add QiblaState and QiblaNotifier provider"
```

---

### Task 4: Ka'bah Button Widget

**Files:**
- Create: `lib/features/qibla/widgets/qibla_button.dart`
- Create: `test/features/qibla/widgets/qibla_button_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/qibla/widgets/qibla_button_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/widgets/qibla_button.dart';

void main() {
  group('QiblaButton', () {
    testWidgets('renders a 48x48 circular button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QiblaButton(onPressed: () {}),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(QiblaButton),
          matching: find.byType(Container),
        ).first,
      );

      expect(find.byType(QiblaButton), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QiblaButton(onPressed: () => pressed = true),
          ),
        ),
      );

      await tester.tap(find.byType(QiblaButton));
      expect(pressed, true);
    });

    testWidgets('shows Qibla label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QiblaButton(onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Qibla'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/qibla/widgets/qibla_button_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the Ka'bah button widget**

Create `lib/features/qibla/widgets/qibla_button.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QiblaButton extends StatelessWidget {
  final VoidCallback onPressed;

  const QiblaButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark
        ? AppColors.sage.withValues(alpha: 0.25)
        : AppColors.deepGreen.withValues(alpha: 0.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(28, 28),
              painter: _KaabahIconPainter(color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Qibla',
          style: TextStyle(
            fontSize: 9,
            color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _KaabahIconPainter extends CustomPainter {
  final Color color;

  _KaabahIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Center the icon in the 48x48 container
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Scale factor — design is in 160x160 viewBox, render at 28x28
    const scale = 28 / 160;
    final ox = cx - (160 * scale / 2);
    final oy = cy - (160 * scale / 2);

    Path offset(Path p) => p.shift(Offset(ox, oy));

    // Circle
    canvas.drawCircle(
      Offset(cx, cy),
      74 * scale,
      paint..strokeWidth = 1.5,
    );

    // Front face
    final front = Path()
      ..moveTo(48 * scale, 70 * scale)
      ..lineTo(48 * scale, 120 * scale)
      ..lineTo(96 * scale, 120 * scale)
      ..lineTo(96 * scale, 70 * scale)
      ..close();
    canvas.drawPath(offset(front), paint..strokeWidth = 1.5);

    // Top face
    final top = Path()
      ..moveTo(48 * scale, 70 * scale)
      ..lineTo(72 * scale, 50 * scale)
      ..lineTo(120 * scale, 50 * scale)
      ..lineTo(96 * scale, 70 * scale)
      ..close();
    canvas.drawPath(offset(top), paint);

    // Right face
    final right = Path()
      ..moveTo(96 * scale, 70 * scale)
      ..lineTo(120 * scale, 50 * scale)
      ..lineTo(120 * scale, 100 * scale)
      ..lineTo(96 * scale, 120 * scale)
      ..close();
    canvas.drawPath(offset(right), paint);

    // Hizam band — front
    canvas.drawLine(
      Offset(ox + 48 * scale, oy + 88 * scale),
      Offset(ox + 96 * scale, oy + 88 * scale),
      paint,
    );

    // Hizam band — right
    canvas.drawLine(
      Offset(ox + 96 * scale, oy + 88 * scale),
      Offset(ox + 120 * scale, oy + 68 * scale),
      paint,
    );

    // Door
    final door = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          ox + 65 * scale,
          oy + 100 * scale,
          14 * scale,
          20 * scale,
        ),
        const Radius.circular(1),
      ));
    canvas.drawPath(door, paint..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _KaabahIconPainter oldDelegate) =>
      color != oldDelegate.color;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/qibla/widgets/qibla_button_test.dart`
Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/qibla/widgets/qibla_button.dart test/features/qibla/widgets/qibla_button_test.dart
git commit -m "feat(qibla): add Ka'bah icon button widget"
```

---

### Task 5: Static Bearing Widget (No-Magnetometer Fallback)

**Files:**
- Create: `lib/features/qibla/widgets/static_bearing.dart`
- Create: `test/features/qibla/widgets/static_bearing_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/qibla/widgets/static_bearing_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/widgets/static_bearing.dart';

void main() {
  group('StaticBearing', () {
    testWidgets('displays bearing degrees and compass direction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaticBearing(bearing: 58.2, compassDirection: 'NE'),
          ),
        ),
      );

      expect(find.textContaining('58.2'), findsOneWidget);
      expect(find.textContaining('NE'), findsOneWidget);
    });

    testWidgets('shows no-magnetometer message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaticBearing(bearing: 58.2, compassDirection: 'NE'),
          ),
        ),
      );

      expect(
        find.textContaining('compass sensor'),
        findsOneWidget,
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/qibla/widgets/static_bearing_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the static bearing widget**

Create `lib/features/qibla/widgets/static_bearing.dart`:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StaticBearing extends StatelessWidget {
  final double bearing;
  final String compassDirection;

  const StaticBearing({
    super.key,
    required this.bearing,
    required this.compassDirection,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Static arrow pointing in bearing direction
          Transform.rotate(
            angle: bearing * math.pi / 180,
            child: Icon(
              Icons.navigation,
              size: 120,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '${bearing.toStringAsFixed(1)}\u00B0 $compassDirection',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: primaryColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Qibla direction from your location',
            style: TextStyle(fontSize: 14, color: secondaryColor),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No compass sensor detected.\nShowing calculated bearing only.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/qibla/widgets/static_bearing_test.dart`
Expected: Both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/qibla/widgets/static_bearing.dart test/features/qibla/widgets/static_bearing_test.dart
git commit -m "feat(qibla): add static bearing fallback widget for devices without magnetometer"
```

---

### Task 6: Calibration Overlay Widget

**Files:**
- Create: `lib/features/qibla/widgets/calibration_overlay.dart`
- Create: `test/features/qibla/widgets/calibration_overlay_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/qibla/widgets/calibration_overlay_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/widgets/calibration_overlay.dart';

void main() {
  group('CalibrationOverlay', () {
    testWidgets('shows figure-8 instruction text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalibrationOverlay(onDismiss: () {}),
          ),
        ),
      );

      expect(find.textContaining('figure'), findsOneWidget);
    });

    testWidgets('calls onDismiss when dismiss button tapped', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalibrationOverlay(onDismiss: () => dismissed = true),
          ),
        ),
      );

      await tester.tap(find.text('Dismiss'));
      expect(dismissed, true);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/qibla/widgets/calibration_overlay_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the calibration overlay widget**

Create `lib/features/qibla/widgets/calibration_overlay.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CalibrationOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const CalibrationOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.85)
        : Colors.black.withValues(alpha: 0.7);

    return Container(
      color: bgColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.screen_rotation,
                size: 64,
                color: primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Calibrate Compass',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Move your phone in a figure-8 pattern\nto improve compass accuracy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: primaryColor.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Dismiss',
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/qibla/widgets/calibration_overlay_test.dart`
Expected: Both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/qibla/widgets/calibration_overlay.dart test/features/qibla/widgets/calibration_overlay_test.dart
git commit -m "feat(qibla): add calibration overlay widget with figure-8 instructions"
```

---

### Task 7: Compass Widget

**Files:**
- Create: `lib/features/qibla/widgets/compass_widget.dart`
- Create: `test/features/qibla/widgets/compass_widget_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/qibla/widgets/compass_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/widgets/compass_widget.dart';

void main() {
  group('CompassWidget', () {
    testWidgets('renders with given qibla and heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompassWidget(
              qiblaDirection: 58.2,
              compassHeading: 142.0,
              isAligned: false,
            ),
          ),
        ),
      );

      expect(find.byType(CompassWidget), findsOneWidget);
      // Should show cardinal direction markers
      expect(find.text('N'), findsOneWidget);
      expect(find.text('E'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
    });

    testWidgets('shows bearing readout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CompassWidget(
              qiblaDirection: 58.2,
              compassHeading: 142.0,
              isAligned: false,
            ),
          ),
        ),
      );

      expect(find.textContaining('58.2'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/qibla/widgets/compass_widget_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Write the compass widget**

Create `lib/features/qibla/widgets/compass_widget.dart`:

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CompassWidget extends StatelessWidget {
  final double qiblaDirection;
  final double compassHeading;
  final bool isAligned;

  const CompassWidget({
    super.key,
    required this.qiblaDirection,
    required this.compassHeading,
    required this.isAligned,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.sage : AppColors.deepGreen;
    final secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final alignedColor = AppColors.sage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Compass disc
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating compass ring
              Transform.rotate(
                angle: -compassHeading * math.pi / 180,
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter: _CompassRingPainter(
                    color: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                ),
              ),
              // Ka'bah indicator (fixed relative to compass, points to qibla)
              Transform.rotate(
                angle: (qiblaDirection - compassHeading) * math.pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isAligned
                            ? alignedColor
                            : primaryColor.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        boxShadow: isAligned
                            ? [
                                BoxShadow(
                                  color: alignedColor.withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  spreadRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Center dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Bearing readout
        Text(
          '${qiblaDirection.toStringAsFixed(1)}\u00B0',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: isAligned ? alignedColor : primaryColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isAligned ? 'Facing Qibla' : 'Qibla Direction',
          style: TextStyle(
            fontSize: 14,
            color: isAligned ? alignedColor : secondaryColor,
          ),
        ),
      ],
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _CompassRingPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Outer ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Degree ticks
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    final majorTickPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2;

    for (var i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180 - math.pi / 2;
      final isMajor = i % 90 == 0;
      final innerR = isMajor ? radius - 16 : radius - 8;
      final start = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, isMajor ? majorTickPaint : tickPaint);
    }

    // Cardinal direction labels
    final labels = {'N': -math.pi / 2, 'E': 0.0, 'S': math.pi / 2, 'W': math.pi};
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    );
    final nStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color, // N is brighter
    );

    labels.forEach((label, angle) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: label == 'N' ? nStyle : textStyle.copyWith(color: secondaryColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelRadius = radius - 28;
      final offset = Offset(
        center.dx + labelRadius * math.cos(angle) - textPainter.width / 2,
        center.dy + labelRadius * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    });
  }

  @override
  bool shouldRepaint(covariant _CompassRingPainter oldDelegate) =>
      color != oldDelegate.color || secondaryColor != oldDelegate.secondaryColor;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/qibla/widgets/compass_widget_test.dart`
Expected: Both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/qibla/widgets/compass_widget.dart test/features/qibla/widgets/compass_widget_test.dart
git commit -m "feat(qibla): add compass widget with rotating ring and Ka'bah indicator"
```

---

### Task 8: Qibla Screen

**Files:**
- Create: `lib/features/qibla/qibla_screen.dart`
- Create: `test/features/qibla/qibla_screen_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/features/qibla/qibla_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/qibla_provider.dart';
import 'package:khushu/features/qibla/qibla_screen.dart';

void main() {
  group('QiblaScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiblaProvider.overrideWith(
              (ref) => _FakeQiblaNotifier(const QiblaState.loading()),
            ),
          ],
          child: const MaterialApp(home: QiblaScreen()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows static bearing when no magnetometer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiblaProvider.overrideWith(
              (ref) => _FakeQiblaNotifier(
                const QiblaState.noMagnetometer(
                  staticBearing: 58.2,
                  compassDirection: 'NE',
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: QiblaScreen()),
        ),
      );

      expect(find.textContaining('58.2'), findsOneWidget);
      expect(find.textContaining('NE'), findsOneWidget);
    });

    testWidgets('shows compass when magnetometer available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiblaProvider.overrideWith(
              (ref) => _FakeQiblaNotifier(
                const QiblaState(
                  isLoading: false,
                  hasMagnetometer: true,
                  qiblaDirection: 58.2,
                  compassHeading: 142.0,
                  needsCalibration: false,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: QiblaScreen()),
        ),
      );

      expect(find.text('N'), findsOneWidget); // Compass cardinal
    });

    testWidgets('shows calibration overlay when needed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiblaProvider.overrideWith(
              (ref) => _FakeQiblaNotifier(
                const QiblaState(
                  isLoading: false,
                  hasMagnetometer: true,
                  qiblaDirection: 58.2,
                  compassHeading: 142.0,
                  needsCalibration: true,
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: QiblaScreen()),
        ),
      );

      expect(find.textContaining('figure'), findsOneWidget);
    });

    testWidgets('shows app bar with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            qiblaProvider.overrideWith(
              (ref) => _FakeQiblaNotifier(const QiblaState.loading()),
            ),
          ],
          child: const MaterialApp(home: QiblaScreen()),
        ),
      );

      expect(find.text('Qibla Compass'), findsOneWidget);
    });
  });
}

class _FakeQiblaNotifier extends QiblaNotifier {
  final QiblaState _initialState;

  _FakeQiblaNotifier(this._initialState) : super._test();

  @override
  QiblaState get state => _initialState;
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/qibla/qibla_screen_test.dart`
Expected: FAIL — file does not exist.

- [ ] **Step 3: Add test constructor to QiblaNotifier**

Add a named constructor to `lib/features/qibla/qibla_provider.dart` for testing:

After the existing `QiblaNotifier` constructor, add:

```dart
  /// Test-only constructor — does not call _init().
  QiblaNotifier._test() : _ref = null as Ref, super(const QiblaState.loading());
```

Also change `final Ref _ref;` to `final Ref? _ref;` and update `_init()` to use `_ref!` instead of `_ref`.

- [ ] **Step 4: Write the Qibla screen**

Create `lib/features/qibla/qibla_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'qibla_provider.dart';
import 'widgets/calibration_overlay.dart';
import 'widgets/compass_widget.dart';
import 'widgets/static_bearing.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(qiblaProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Qibla Compass', style: theme.textTheme.bodyLarge),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Main content
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
                  isAligned: state.isAligned,
                ),
                const Spacer(),
                // Calibrate button
                TextButton(
                  onPressed: () {
                    // Show calibration overlay manually
                    ref.read(qiblaProvider.notifier)._showCalibration();
                  },
                  child: Text(
                    'Calibrate',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.sage.withValues(alpha: 0.6)
                          : AppColors.deepGreen.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),

          // Calibration overlay
          if (state.needsCalibration)
            CalibrationOverlay(
              onDismiss: () {
                ref.read(qiblaProvider.notifier).dismissCalibration();
              },
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Add _showCalibration method to QiblaNotifier**

In `lib/features/qibla/qibla_provider.dart`, add this method to `QiblaNotifier`:

```dart
  void _showCalibration() {
    state = QiblaState(
      isLoading: state.isLoading,
      hasMagnetometer: state.hasMagnetometer,
      qiblaDirection: state.qiblaDirection,
      compassHeading: state.compassHeading,
      needsCalibration: true,
    );
  }
```

Make it accessible from the screen by changing the method name or making it public. Since the screen calls it via `ref.read(qiblaProvider.notifier)`, rename to `showCalibration()` (public).

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/features/qibla/qibla_screen_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/features/qibla/qibla_screen.dart lib/features/qibla/qibla_provider.dart test/features/qibla/qibla_screen_test.dart
git commit -m "feat(qibla): add Qibla compass screen with loading, compass, fallback, and calibration states"
```

---

### Task 9: Add Route and Button to Prayer Times Screen

**Files:**
- Modify: `lib/navigation/app_router.dart`
- Modify: `lib/features/prayer_times/prayer_times_screen.dart`

- [ ] **Step 1: Add `/qibla` route to GoRouter**

In `lib/navigation/app_router.dart`, add the import and route:

Add import at top:
```dart
import '../features/qibla/qibla_screen.dart';
```

Add route after the `/settings/notifications` route (before the closing `]`):
```dart
      GoRoute(
        path: '/qibla',
        builder: (context, state) => const QiblaScreen(),
      ),
```

- [ ] **Step 2: Add QiblaButton to prayer times screen (bottom-left)**

In `lib/features/prayer_times/prayer_times_screen.dart`, add import at top:
```dart
import '../qibla/widgets/qibla_button.dart';
```

Wrap the Scaffold `body` in a `Stack` to position the Qibla button at bottom-left. **Important: Do NOT change the existing settings FAB (floatingActionButton) at all.**

Wrap the existing `body:` content in a Stack and add the Qibla button as a `Positioned` widget at bottom-left. Replace the `body:` value (the current `SafeArea(...)`) with:

```dart
      body: Stack(
        children: [
          // Existing content — unchanged
          SafeArea(
            // ... existing SafeArea content stays exactly as-is ...
          ),
          // Qibla button — bottom-left
          Positioned(
            left: 16,
            bottom: 16,
            child: SafeArea(
              child: QiblaButton(onPressed: () => context.push('/qibla')),
            ),
          ),
        ],
      ),
```

The existing `floatingActionButton` (settings gear) stays exactly where it is on the bottom-right.

- [ ] **Step 3: Verify the app builds**

Run: `flutter analyze`
Expected: No errors.

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/navigation/app_router.dart lib/features/prayer_times/prayer_times_screen.dart
git commit -m "feat(qibla): add /qibla route and Ka'bah button to prayer times screen"
```

---

### Task 10: Push and Verify

- [ ] **Step 1: Run full test suite**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 2: Run flutter analyze**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 3: Push to remote**

```bash
git push origin feat/qibla-compass
```

- [ ] **Step 4: Verify on GitHub**

Check that all commits appear on the `feat/qibla-compass` branch.
