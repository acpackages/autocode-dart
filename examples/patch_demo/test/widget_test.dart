import 'package:flutter_test/flutter_test.dart';
import 'package:patch_demo/main.dart';

void main() {
  testWidgets('PatchDemoApp smoke test', (WidgetTester tester) async {
    expect(const PatchDemoApp(), isNotNull);
  });
}
