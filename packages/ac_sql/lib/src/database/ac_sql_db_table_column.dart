import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_sql/ac_sql.dart';

/* AcDoc({
  "summary": "A database service handler focused on a single table column.",
  "description": "This class extends `AcSqlDbBase` to provide a convenient context for operations related to a specific column within a table. It automatically loads the definitions for both the parent table and the column itself from the data dictionary upon instantiation.",
  "example": "// Prerequisite: A data dictionary with a 'users' table and 'email' column is registered.\n\n// Create a handler specifically for the users.email column.\nfinal columnHandler = AcSqlDbTableColumn(\n  tableName: 'users',\n  columnName: 'email',\n);\n\n// Access the column's definition and properties.\nfinal columnType = columnHandler.acDDTableColumn.columnType;\nprint('The `email` column type is: \$columnType');"
}) */
class AcSqlDbTableColumn extends AcSqlDbBase {
  /* AcDoc({"summary": "The name of the column this handler is responsible for."}) */
  late String columnName;

  /* AcDoc({"summary": "The name of the table this column belongs to."}) */
  late String tableName;

  /* AcDoc({"summary": "The loaded data dictionary definition for the parent table."}) */
  late AcDDTable acDDTable;

  /* AcDoc({"summary": "The loaded data dictionary definition for the specific column."}) */
  late AcDDTableColumn acDDTableColumn;

  /* AcDoc({
    "summary": "Creates a service handler for a specific table column.",
    "description": "Initializes the base database service and loads the definitions for the specified table and column from the data dictionary.\n\nNote: This constructor will throw a runtime error if the `tableName` or `columnName` do not exist in the specified `dataDictionaryName`.",
    "params": [
      {"name": "tableName", "description": "The name of the parent table."},
      {"name": "columnName", "description": "The name of the column to manage."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to use. Defaults to 'default'."}
    ]
  }) */
  AcSqlDbTableColumn({
    required String tableName,
    required String columnName,
    String dataDictionaryName = "default",
  }) : super(dataDictionaryName: dataDictionaryName) {
    // Correctly assign instance fields from parameters.
    this.tableName = tableName;
    this.columnName = columnName;

    // Warning: The force-unwrap operator `!` will cause an error if the table is not found.
    acDDTable =
    AcDataDictionary.getTable(
      tableName: tableName,
      dataDictionaryName: dataDictionaryName,
    )!;

    // Warning: The force-unwrap operator `!` will cause an error if the column is not found.
    acDDTableColumn =
    AcDataDictionary.getTableColumn(
      tableName: tableName,
      columnName: columnName,
      dataDictionaryName: dataDictionaryName,
    )!;
  }
}
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_sql/ac_sql.dart';
//
// class AcSqlDbTableColumn extends AcSqlDbBase {
//   late String columnName;
//   late String tableName;
//   late AcDDTable acDDTable;
//   late AcDDTableColumn acDDTableColumn;
//
//   AcSqlDbTableColumn({
//     required String tableName,
//     required String columnName,
//     String dataDictionaryName = "default",
//   }) : super(dataDictionaryName: dataDictionaryName) {
//     tableName = tableName;
//     columnName = columnName;
//     acDDTable =
//         AcDataDictionary.getTable(
//           tableName: tableName,
//           dataDictionaryName: dataDictionaryName,
//         )!;
//     acDDTableColumn =
//         AcDataDictionary.getTableColumn(
//           tableName: tableName,
//           columnName: columnName,
//           dataDictionaryName: dataDictionaryName,
//         )!;
//   }
// }
