import 'package:flutter_test/flutter_test.dart';
import 'package:ac_calculator_example/main.dart';

void main() {
  testWidgets('Example app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorExampleApp());
    expect(find.text('AC Calculator'), findsOneWidget);
    expect(find.text('0'), findsAtLeast(1));
  });
}
