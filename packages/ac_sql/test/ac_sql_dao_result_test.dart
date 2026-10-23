import 'package:test/test.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

void main() {
  group('AcSqlDaoResult Reflection-Free Serialization Tests', () {
    test('Should serialize and deserialize AcSqlDaoResult with rows and metadata', () {
      final daoResult = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert)
        ..setSuccess(message: 'Row inserted')
        ..rows = [
          {'id': 1, 'name': 'Item A'},
          {'id': 2, 'name': 'Item B'},
        ]
        ..affectedRowsCount = 2
        ..lastInsertedId = 2
        ..primaryKeyColumn = 'id'
        ..primaryKeyValue = 2
        ..totalRows = 100;

      final json = daoResult.toJson();

      expect(json['status'], equals('success'));
      expect(json['message'], equals('Row inserted'));
      expect(json['operation'], equals(AcEnumDDRowOperation.insert.value));
      expect(json['rows'], hasLength(2));
      expect(json['affectedRowsCount'], equals(2));
      expect(json['lastInsertedId'], equals(2));
      expect(json['primaryKeyColumn'], equals('id'));
      expect(json['primaryKeyValue'], equals(2));
      expect(json['totalRows'], equals(100));

      final restored = AcSqlDaoResult.instanceFromJson(jsonData: json);
      expect(restored.isSuccess(), isTrue);
      expect(restored.message, equals('Row inserted'));
      expect(restored.operation, equals(AcEnumDDRowOperation.insert));
      expect(restored.hasRows(), isTrue);
      expect(restored.rowsCount, equals(2));
      expect(restored.rows.first['name'], equals('Item A'));
      expect(restored.hasAffectedRows(), isTrue);
      expect(restored.affectedRowsCount, equals(2));
      expect(restored.lastInsertedId, equals(2));
      expect(restored.primaryKeyColumn, equals('id'));
      expect(restored.primaryKeyValue, equals(2));
      expect(restored.totalRows, equals(100));
    });

    test('Should handle snake_case keys correctly from legacy payloads', () {
      final json = {
        'status': 'success',
        'code': 1,
        'message': 'Loaded',
        'rows': [
          {'id': 10, 'title': 'Test'}
        ],
        'affected_rows_count': '5',
        'last_inserted_id': 99,
        'operation': 'SELECT',
        'primary_key_column': 'user_id',
        'primary_key_value': 10,
        'total_rows': '50',
      };

      final restored = AcSqlDaoResult.instanceFromJson(jsonData: json);
      expect(restored.isSuccess(), isTrue);
      expect(restored.rowsCount, equals(1));
      expect(restored.affectedRowsCount, equals(5));
      expect(restored.lastInsertedId, equals(99));
      expect(restored.operation, equals(AcEnumDDRowOperation.select));
      expect(restored.primaryKeyColumn, equals('user_id'));
      expect(restored.primaryKeyValue, equals(10));
      expect(restored.totalRows, equals(50));
    });
  });
}
