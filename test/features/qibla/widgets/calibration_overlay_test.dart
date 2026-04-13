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
