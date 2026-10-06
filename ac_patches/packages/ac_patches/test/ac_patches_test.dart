import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_patches/ac_patches.dart';

void main() {
  testWidgets('AcPatchAutoUpdater renders child correctly', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: AcPatchAutoUpdater(
          autoDownload: false,
          child: Text('Test App Content'),
        ),
      ),
    );

    expect(find.text('Test App Content'), findsOneWidget);
  });
}
