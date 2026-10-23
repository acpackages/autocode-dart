import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_widgets_example/main.dart';

void main() {
  testWidgets('AcWidgetsShowcaseApp compiles and switches tabs without crash', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AcWidgetsShowcaseApp());
    await tester.pumpAndSettle();

    // Check initial tab (AcDatagrid)
    expect(find.text('AcDatagrid'), findsWidgets);
    expect(find.text('Export CSV'), findsOneWidget);

    // Switch to AcRepeater tab
    await tester.tap(find.text('AcRepeater'));
    await tester.pumpAndSettle();
    expect(find.text('Search...'), findsOneWidget);
    expect(find.text('MacBook Pro 16'), findsOneWidget);

    // Switch to Resizable tab
    await tester.tap(find.text('AcResizable & Panels'));
    await tester.pumpAndSettle();
    expect(find.text('Left Sidebar'), findsOneWidget);

    // Switch to Pagination tab
    await tester.tap(find.text('AcPagination'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Current Page: 1'), findsOneWidget);

    // Switch to DataDictionary UI tab
    await tester.tap(find.text('DataDictionary UI'));
    await tester.pumpAndSettle();
    expect(find.text('Sarah Jenkins'), findsOneWidget);

    // Switch to Layout & UI Elements tab
    await tester.tap(find.text('Layout & UI Elements'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('System Operational'), findsOneWidget);
    expect(find.text('FEATURED'), findsOneWidget);

    // Switch to AcMessage tab
    await tester.tap(find.text('AcMessage'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Success Toast'), findsOneWidget);
    expect(find.text('Confirm Modal Dialog'), findsOneWidget);
  });
}
