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

      expect(find.textContaining('compass sensor'), findsOneWidget);
    });
  });
}
