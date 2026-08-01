import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('AcSqliteDao schema modification tests', () {
    late AcSqliteDao dao;
    const dbPath = 'test_schema_mod.db';

    setUp(() async {
      dao = AcSqliteDao();
      dao.sqlConnection = AcSqlConnection(database: dbPath);
      
      // Clean up previous run if any
      final file = File(dbPath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }

      // Create initial tables
      final db = sqlite3.open(dbPath);
      db.execute('CREATE TABLE parent (id INTEGER PRIMARY KEY, name TEXT);');
      db.execute('CREATE TABLE child (id INTEGER PRIMARY KEY, parent_id INTEGER, age INTEGER);');
      db.execute("INSERT INTO parent (id, name) VALUES (1, 'Alice');");
      db.execute('INSERT INTO child (id, parent_id, age) VALUES (10, 1, 5);');
      db.close();
    });

    tearDown(() async {
      await dao.close();
      final file = File(dbPath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    });

    test('dropColumns drops the specified columns', () async {
      // Verify initial columns
      var colsResult = await dao.getTableColumns(tableName: 'child');
      expect(colsResult.isSuccess(), isTrue);
      var colNames = colsResult.rows.map((r) => r[AcDDTableColumn.keyColumnName] as String).toList();
      expect(colNames, contains('age'));

      // Drop column
      final dropResult = await dao.dropColumns(tableName: 'child', columnNames: ['age']);
      expect(dropResult.isSuccess(), isTrue);

      // Verify columns after drop
      colsResult = await dao.getTableColumns(tableName: 'child');
      colNames = colsResult.rows.map((r) => r[AcDDTableColumn.keyColumnName] as String).toList();
      expect(colNames, isNot(contains('age')));
      expect(colNames, containsAll(['id', 'parent_id']));
    });

    test('createRelationships and dropRelationshipsByColumnName work correctly', () async {
      // 1. Create a relationship definition
      final rel = AcDDRelationship()
        ..sourceTable = 'parent'
        ..sourceColumn = 'id'
        ..destinationTable = 'child'
        ..destinationColumn = 'parent_id'
        ..cascadeDeleteDestination = true;

      // Create relationship
      final createResult = await dao.createRelationships(relationships: [rel]);
      expect(createResult.isSuccess(), isTrue);

      // Verify FK exists in SQLite
      final db = sqlite3.open(dbPath);
      final fkList = db.select('PRAGMA foreign_key_list(child);');
      expect(fkList.length, equals(1));
      expect(fkList.first['table'], equals('parent'));
      expect(fkList.first['from'], equals('parent_id'));
      expect(fkList.first['to'], equals('id'));
      expect(fkList.first['on_delete'], equals('CASCADE'));
      db.close();

      // 2. Drop relationship by column name
      final dropRelResult = await dao.dropRelationshipsByColumnName(
        tableName: 'child',
        columnName: 'parent_id',
      );
      expect(dropRelResult.isSuccess(), isTrue);

      // Verify FK is gone
      final dbAfter = sqlite3.open(dbPath);
      final fkListAfter = dbAfter.select('PRAGMA foreign_key_list(child);');
      expect(fkListAfter.isEmpty, isTrue);
      dbAfter.close();
    });
  });
}
