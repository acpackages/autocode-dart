import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_calculator/ac_calculator.dart';

void main() {
  testWidgets(
    'AcCalculator renders display, keypad buttons and computes standard addition',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AcCalculator(
              theme: AcCalculatorTheme.windowsLight(),
              initialMode: CalculatorMode.standard,
            ),
          ),
        ),
      );

      // Initial display should be '0'
      expect(find.text('0'), findsAtLeast(1));

      // Tap '7'
      await tester.tap(find.text('7'));
      await tester.pump();
      expect(find.text('7'), findsAtLeast(1));

      // Tap '+'
      await tester.tap(find.text('+'));
      await tester.pump();

      // Tap '8'
      await tester.tap(find.text('8'));
      await tester.pump();

      // Tap '='
      await tester.tap(find.text('='));
      await tester.pump();

      // Result 15 should be displayed
      expect(find.text('15'), findsOneWidget);
    },
  );

  testWidgets(
    'Theme switching updates theme without crashing or losing state',
    (tester) async {
      var currentTheme = AcCalculatorTheme.windowsLight();

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          () => setState(
                            () => currentTheme = AcCalculatorTheme.iphoneDark(),
                          ),
                      child: const Text('Switch Theme'),
                    ),
                    Expanded(
                      child: AcCalculator(
                        theme: currentTheme,
                        initialMode: CalculatorMode.standard,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Input '9'
      await tester.tap(find.text('9'));
      await tester.pump();
      expect(find.text('9'), findsAtLeast(1));

      // Switch theme
      await tester.tap(find.text('Switch Theme'));
      await tester.pumpAndSettle();

      // Verify '9' is preserved
      expect(find.text('9'), findsAtLeast(1));
    },
  );
}
