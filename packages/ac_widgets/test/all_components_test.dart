import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_widgets/ac_widgets.dart';

void main() {
  group('New Components Unit & Widget Tests', () {
    testWidgets('AcAlert renders, changes variants and dismisses', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AcAlert(
              variant: AcAlertVariant.success,
              title: const Text('Success Title'),
              dismissible: true,
              onDismissed: () => dismissed = true,
              child: const Text('Operation completed successfully.'),
            ),
          ),
        ),
      );

      expect(find.text('Success Title'), findsOneWidget);
      expect(find.text('Operation completed successfully.'), findsOneWidget);

      // Tap close
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('Success Title'), findsNothing);
    });

    testWidgets('AcBadge renders custom count and pill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const AcBadge(child: Text('NEW')),
                AcBadge.count(count: 142, maxCount: 99),
              ],
            ),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('AcProgress & AcSpinner render properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AcSpinner(size: 32),
                AcProgress(value: 0.65, showLabel: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AcSpinner), findsOneWidget);
      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('AcAccordion toggles expansion state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcAccordion(
              items: [
                AcAccordionItem(
                  title: Text('Section 1'),
                  content: Text('Content 1'),
                  initiallyExpanded: true,
                ),
                AcAccordionItem(
                  title: Text('Section 2'),
                  content: Text('Content 2'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);

      // Tap section 2
      await tester.tap(find.text('Section 2'));
      await tester.pumpAndSettle();

      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('AcCard renders structured content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcCard(
              title: Text('Card Title'),
              subtitle: Text('Card Subtitle'),
              body: Text('Card Body Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card Subtitle'), findsOneWidget);
      expect(find.text('Card Body Content'), findsOneWidget);
    });

    testWidgets('AcTabs switches views', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcTabs(
              tabs: [
                AcTabItem(label: Text('Tab A'), content: Text('Body A')),
                AcTabItem(label: Text('Tab B'), content: Text('Body B')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Body A'), findsOneWidget);

      // Tap Tab B
      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();

      expect(find.text('Body B'), findsOneWidget);
    });

    testWidgets('AcTomSelectInput opens modal and selects options', (tester) async {
      List<String> selected = ['apple'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AcTomSelectInput<String>(
                  label: 'Fruits',
                  options: const [
                    AcTomSelectOption(value: 'apple', label: 'Apple'),
                    AcTomSelectOption(value: 'banana', label: 'Banana'),
                    AcTomSelectOption(value: 'orange', label: 'Orange'),
                  ],
                  selectedValues: selected,
                  onChanged: (vals) => setState(() => selected = vals),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Apple'), findsOneWidget);

      // Open selection dialog
      await tester.tap(find.byType(AcTomSelectInput<String>));
      await tester.pumpAndSettle();

      expect(find.text('Fruits'), findsWidgets);
      expect(find.text('Banana'), findsOneWidget);

      // Select Banana
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      // Click Done
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(selected, containsAll(['apple', 'banana']));
    });

    testWidgets('AcFilePreview displays metadata', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcFilePreview(
              fileName: 'contract.pdf',
              fileSize: '2.4 MB',
              fileType: AcFileType.pdf,
            ),
          ),
        ),
      );

      expect(find.text('contract.pdf'), findsOneWidget);
      expect(find.text('2.4 MB'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    });

    testWidgets('AcBreadcrumb renders navigation path', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AcBreadcrumb(
              items: [
                AcBreadcrumbItem(label: Text('Home')),
                AcBreadcrumbItem(label: Text('Products')),
                AcBreadcrumbItem(label: Text('Laptops')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Laptops'), findsOneWidget);
    });
  });
}
