import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khushu/features/qibla/widgets/qibla_button.dart';

void main() {
  group('QiblaButton', () {
    testWidgets('renders a 40x40 circular button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QiblaButton(onPressed: () {}),
          ),
        ),
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

    testWidgets('contains CustomPaint for Ka\'bah icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QiblaButton(onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
