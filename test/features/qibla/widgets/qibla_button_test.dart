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
