
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

class AcSqlDaoResult extends AcResult {
  static const String KEY_ROWS = 'rows';
  static const String KEY_AFFECTED_ROWS_COUNT = 'affected_rows_count';
  static const String KEY_LAST_INSERTED_ID = 'last_inserted_id';
  static const String KEY_OPERATION = 'operation';
  static const String KEY_PRIMARY_KEY_COLUMN = 'primary_key_column';
  static const String KEY_PRIMARY_KEY_VALUE = 'primary_key_value';
  static const String KEY_TOTAL_ROWS = 'total_rows';


  List<Map<String,dynamic>> rows = [];

  @AcBindJsonProperty(key: AcSqlDaoResult.KEY_AFFECTED_ROWS_COUNT)
  int? affectedRowsCount;

  @AcBindJsonProperty(key: AcSqlDaoResult.KEY_LAST_INSERTED_ID)
  int? lastInsertedId;

  @AcBindJsonProperty(key: AcSqlDaoResult.KEY_LAST_INSERTED_ID)
  dynamic lastInsertedIds;

  String operation = AcEnumDDRowOperation.UNKNOWN;

  @AcBindJsonProperty(key: AcSqlDaoResult.KEY_PRIMARY_KEY_COLUMN)
  String? primaryKeyColumn;

  @AcBindJsonProperty(key: AcSqlDaoResult.KEY_PRIMARY_KEY_VALUE)
  dynamic primaryKeyValue;

  @AcBindJsonProperty(key: AcSqlDaoResult.KEY_TOTAL_ROWS)
  int totalRows = 0;

  AcSqlDaoResult({String? operation = AcEnumDDRowOperation.UNKNOWN}) {
    this.operation = operation!;
  }

  bool hasAffectedRows() {
    return affectedRowsCount != null && affectedRowsCount! > 0;
  }

  bool hasRows() {
    return rows.isNotEmpty;
  }

  int rowsCount() {
    return rows.length;
  }
}
