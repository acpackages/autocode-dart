import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_widgets/ac_widgets.dart';

void main() {
  final sampleData = [
    {'id': '1', 'name': 'Alice', 'role': 'Developer', 'salary': 100000},
    {'id': '2', 'name': 'Bob', 'role': 'Designer', 'salary': 85000},
    {'id': '3', 'name': 'Charlie', 'role': 'Manager', 'salary': 120000},
    {'id': '4', 'name': 'David', 'role': 'Developer', 'salary': 95000},
  ];

  group('AcPagination Widget Tests', () {
    testWidgets('Renders navigation buttons and triggers page changes', (tester) async {
      int activePage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AcPagination(
                  activePage: activePage,
                  pageSize: 2,
                  totalRows: 4,
                  onPageChange: (p) => setState(() => activePage = p),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Showing 1 to 2 of 4 entries'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // Tap next page
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(activePage, equals(2));
      expect(find.text('Showing 3 to 4 of 4 entries'), findsOneWidget);
    });
  });

  group('AcResizablePanels Widget Tests', () {
    testWidgets('Renders panels and allows drag resizing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 300,
              child: AcResizablePanels(
                direction: Axis.horizontal,
                panels: const [
                  AcResizablePanel(child: Text('Panel A')),
                  AcResizablePanel(child: Text('Panel B')),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Panel A'), findsOneWidget);
      expect(find.text('Panel B'), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });

  group('AcRepeater Widget Tests', () {
    testWidgets('Renders data rows and responds to search', (tester) async {
      final dm = AcDataManager(data: sampleData);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: AcRepeater(
                dataManager: dm,
                itemBuilder: (context, row, i) {
                  return ListTile(
                    title: Text(row.getValue('name')),
                    subtitle: Text(row.getValue('role')),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('David'), findsOneWidget);

      // Search for Developer
      await tester.enterText(find.byType(TextField), 'Developer');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('David'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
      expect(find.text('Charlie'), findsNothing);
    });
  });

  group('AcDatagrid Widget Tests', () {
    testWidgets('Renders columns, cells, and handles sorting', (tester) async {
      final dm = AcDataManager(data: sampleData);
      final columns = [
        AcDatagridColumn(field: 'id', title: 'ID', width: 60),
        AcDatagridColumn(field: 'name', title: 'Name', width: 120),
        AcDatagridColumn(field: 'role', title: 'Role', width: 120),
        AcDatagridColumn(
          field: 'salary',
          title: 'Salary',
          width: 100,
          dataType: AcDatagridColumnDataType.number,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              width: 500,
              child: AcDatagrid(
                dataManager: dm,
                columns: columns,
                showSelectionCheckbox: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);

      // Tap column header to sort by name ascending
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      expect(dm.displayedRows.first.getValue('name'), equals('Alice'));
      expect(dm.displayedRows.last.getValue('name'), equals('David'));

      // Tap again to sort descending
      await tester.tap(find.text('Name'));
      await tester.pumpAndSettle();

      expect(dm.displayedRows.first.getValue('name'), equals('David'));
      expect(dm.displayedRows.last.getValue('name'), equals('Alice'));
    });

    test('Exports to CSV correctly', () {
      final dm = AcDataManager(data: sampleData);
      final columns = [
        AcDatagridColumn(field: 'id', title: 'ID'),
        AcDatagridColumn(field: 'name', title: 'Name'),
        AcDatagridColumn(field: 'role', title: 'Role'),
      ];

      final csv = AcDatagridCsvExporter.exportToString(
        dataManager: dm,
        columns: columns,
      );

      expect(csv, contains('ID,Name,Role'));
      expect(csv, contains('1,Alice,Developer'));
      expect(csv, contains('2,Bob,Designer'));
    });
  });

  group('Filter and Sort Popups Tests', () {
    testWidgets('Opens AcDataFilterPopup and applies condition', (tester) async {
      final dm = AcDataManager(data: sampleData);
      final filterField = AcFilterField(key: 'role', label: 'Role');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AcDataFilterButton(
                dataManager: dm,
                fields: [filterField],
                targetField: filterField,
              ),
            ),
          ),
        ),
      );

      // Tap filter button
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.text('Filter: Role'), findsOneWidget);
      expect(find.text('Apply'), findsOneWidget);

      // Enter filter value
      await tester.enterText(find.byType(TextFormField), 'Designer');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(dm.displayedRows.length, equals(1));
      expect(dm.displayedRows.first.getValue('name'), equals('Bob'));
    });
  });
}
