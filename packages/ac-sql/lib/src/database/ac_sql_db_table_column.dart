import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

class AcSqlDbTableColumn extends AcSqlDbBase {
  late String columnName;
  late String tableName;
  late AcDDTable acDDTable;
  late AcDDTableColumn acDDTableColumn;

  AcSqlDbTableColumn({
    required String tableName,
    required String columnName,
    String dataDictionaryName = "default",
  }) : super(dataDictionaryName: dataDictionaryName) {
    tableName = tableName;
    columnName = columnName;
    acDDTable =
        AcDataDictionary.getTable(
          tableName: tableName,
          dataDictionaryName: dataDictionaryName,
        )!;
    acDDTableColumn =
        AcDataDictionary.getTableColumn(
          tableName: tableName,
          columnName: columnName,
          dataDictionaryName: dataDictionaryName,
        )!;
  }
}
