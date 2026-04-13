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
              qiblaOffset: 56.4,
              isAligned: false,
            ),
          ),
        ),
      );

      expect(find.byType(CompassWidget), findsOneWidget);
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
              qiblaOffset: 56.4,
              isAligned: false,
            ),
          ),
        ),
      );

      expect(find.textContaining('56.4'), findsOneWidget);
    });
  });
}
