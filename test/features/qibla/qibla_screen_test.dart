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

      expect(find.text('N'), findsOneWidget);
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
  final QiblaState _state;

  _FakeQiblaNotifier(this._state) : super.test();

  @override
  QiblaState get state => _state;
}
