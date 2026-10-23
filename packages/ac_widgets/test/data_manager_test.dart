import 'package:flutter_test/flutter_test.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_widgets/src/data_manager/ac_data_manager.dart';

void main() {
  group('AcDataManager tests', () {
    final sampleData = [
      {'id': '1', 'name': 'Alice', 'age': 30, 'dept': 'Engineering'},
      {'id': '2', 'name': 'Bob', 'age': 25, 'dept': 'Design'},
      {'id': '3', 'name': 'Charlie', 'age': 35, 'dept': 'Engineering'},
      {'id': '4', 'name': 'Diana', 'age': 28, 'dept': 'Marketing'},
    ];

    test('Initializes rows and displayedRows correctly', () {
      final dm = AcDataManager(data: sampleData);
      expect(dm.rows.length, equals(4));
      expect(dm.displayedRows.length, equals(4));
      expect(dm.totalRows, equals(4));
    });

    test('Filters by single condition correctly', () {
      final dm = AcDataManager(data: sampleData);
      final group = AcFilterGroup()
        ..addFilter(
          key: 'dept',
          operator: AcEnumConditionOperator.equalTo,
          value: 'Engineering',
        );
      dm.setFilterGroup(group);

      expect(dm.displayedRows.length, equals(2));
      expect(dm.displayedRows.map((r) => r.getValue('name')), containsAll(['Alice', 'Charlie']));
    });

    test('Searches across fields correctly', () {
      final dm = AcDataManager(data: sampleData);
      dm.setSearchQuery('ali');
      expect(dm.displayedRows.length, equals(1));
      expect(dm.displayedRows.first.getValue('name'), equals('Alice'));

      dm.setSearchQuery('35');
      expect(dm.displayedRows.length, equals(1));
      expect(dm.displayedRows.first.getValue('name'), equals('Charlie'));
    });

    test('Sorts ascending and descending correctly', () {
      final dm = AcDataManager(data: sampleData);
      dm.setSort(key: 'age', order: AcEnumSortOrder.ascending);
      expect(dm.displayedRows.first.getValue('name'), equals('Bob')); // 25
      expect(dm.displayedRows.last.getValue('name'), equals('Charlie')); // 35

      dm.setSort(key: 'age', order: AcEnumSortOrder.descending);
      expect(dm.displayedRows.first.getValue('name'), equals('Charlie'));
      expect(dm.displayedRows.last.getValue('name'), equals('Bob'));
    });

    test('Pagination slices data correctly', () {
      final dm = AcDataManager(
        data: sampleData,
        usePagination: true,
        pageSize: 2,
      );

      expect(dm.totalPages, equals(2));
      expect(dm.activePage, equals(1));
      expect(dm.displayedRows.length, equals(2));
      expect(dm.displayedRows.map((r) => r.getValue('name')), equals(['Alice', 'Bob']));

      dm.setActivePage(2);
      expect(dm.displayedRows.length, equals(2));
      expect(dm.displayedRows.map((r) => r.getValue('name')), equals(['Charlie', 'Diana']));
    });

    test('Selection tracks selected rows', () {
      final dm = AcDataManager(data: sampleData);
      expect(dm.selectedRows.isEmpty, isTrue);

      dm.toggleRowSelection(dm.displayedRows[0]);
      expect(dm.selectedRows.length, equals(1));
      expect(dm.selectedRows.first.getValue('name'), equals('Alice'));

      dm.selectAll();
      expect(dm.selectedRows.length, equals(4));

      dm.clearSelection();
      expect(dm.selectedRows.isEmpty, isTrue);
    });

    test('Tree hierarchy expands and collapses correctly', () {
      final treeData = [
        {'id': 'p1', 'name': 'Parent 1', 'parent': null},
        {'id': 'c1', 'name': 'Child 1.1', 'parent': 'p1'},
        {'id': 'c2', 'name': 'Child 1.2', 'parent': 'p1'},
        {'id': 'p2', 'name': 'Parent 2', 'parent': null},
      ];

      final dm = AcDataManager(
        data: treeData,
        parentIdField: 'parent',
      );

      // Initially collapsed: only roots are displayed
      expect(dm.displayedRows.length, equals(2));
      expect(dm.displayedRows.map((r) => r.getValue('name')), equals(['Parent 1', 'Parent 2']));

      // Expand parent 1
      final p1 = dm.rows.firstWhere((r) => r.id == 'p1');
      dm.toggleRowExpansion(p1);
      expect(dm.displayedRows.length, equals(4));

      // Collapse parent 1
      dm.toggleRowExpansion(p1);
      expect(dm.displayedRows.length, equals(2));
    });
  });
}
