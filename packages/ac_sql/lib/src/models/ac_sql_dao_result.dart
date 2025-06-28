import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents the result of a database Data Access Object (DAO) operation.",
  "description": "This class encapsulates the outcome of a SQL query such as SELECT, INSERT, UPDATE, or DELETE. It holds any returned rows, the number of affected rows, the last inserted ID(s), and other relevant metadata about the operation.",
  "example": "// Example result from an INSERT operation that created one new record.\nfinal result = AcSqlDaoResult(operation: AcEnumDDRowOperation.insert)\n  ..affectedRowsCount = 1\n  ..lastInsertedId = 123;"
}) */
@AcReflectable()
class AcSqlDaoResult extends AcResult {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyRows = 'rows';
  static const String keyAffectedRowsCount = 'affected_rows_count';
  static const String keyLastInsertedId = 'last_inserted_id';
  static const String keyOperation = 'operation';
  static const String keyPrimaryKeyColumn = 'primary_key_column';
  static const String keyPrimaryKeyValue = 'primary_key_value';
  static const String keyTotalRows = 'total_rows';

  /* AcDoc({
    "summary": "A list of rows returned by a SELECT query.",
    "description": "Each item in the list is a map representing a single row, with column names as keys."
  }) */
  List<Map<String,dynamic>> rows = [];

  /* AcDoc({
    "summary": "The number of rows affected by an INSERT, UPDATE, or DELETE operation."
  }) */
  @AcBindJsonProperty(key: keyAffectedRowsCount)
  int? affectedRowsCount;

  /* AcDoc({
    "summary": "The last auto-generated ID from a single INSERT operation.",
    "remarks": ["This field shares a JSON key with `lastInsertedIds`. Deserialization behavior may vary depending on the exact JSON payload (single value vs. list)."]
  }) */
  @AcBindJsonProperty(key: keyLastInsertedId)
  int? lastInsertedId;

  /* AcDoc({
    "summary": "A list of auto-generated IDs from a bulk INSERT operation.",
    "remarks": ["This field shares a JSON key with `lastInsertedId`. Deserialization behavior may vary depending on the exact JSON payload (single value vs. list)."]
  }) */
  @AcBindJsonProperty(key: keyLastInsertedId)
  dynamic lastInsertedIds;

  /* AcDoc({
    "summary": "The type of DAO operation that was performed (e.g., select, insert, update)."
  }) */
  AcEnumDDRowOperation operation;

  /* AcDoc({
    "summary": "The name of the primary key column involved in the operation."
  }) */
  @AcBindJsonProperty(key: keyPrimaryKeyColumn)
  String? primaryKeyColumn;

  /* AcDoc({
    "summary": "The value of the primary key involved in the operation."
  }) */
  @AcBindJsonProperty(key: keyPrimaryKeyValue)
  dynamic primaryKeyValue;

  /* AcDoc({
    "summary": "The total number of rows available for a paginated query.",
    "description": "This is typically used in SELECT queries with a LIMIT clause to indicate the total number of records that match the WHERE clause, ignoring pagination."
  }) */
  @AcBindJsonProperty(key: keyTotalRows)
  int totalRows = 0;

  /* AcDoc({
    "summary": "Creates an instance of a DAO result.",
    "params": [
      {"name": "operation", "description": "The type of operation this result represents."}
    ]
  }) */
  AcSqlDaoResult({this.operation = AcEnumDDRowOperation.unknown});

  /* AcDoc({
    "summary": "Checks if the operation affected any rows.",
    "returns": "True if the number of affected rows is greater than zero.",
    "returns_type": "bool"
  }) */
  bool hasAffectedRows() {
    return (affectedRowsCount ?? 0) > 0;
  }

  /* AcDoc({
    "summary": "Checks if the result contains any data rows.",
    "returns": "True if the `rows` list is not empty.",
    "returns_type": "bool"
  }) */
  bool hasRows() {
    return rows.isNotEmpty;
  }

  /* AcDoc({
    "summary": "Gets the number of data rows returned by the query.",
    "returns": "The count of items in the `rows` list.",
    "returns_type": "int"
  }) */
  int get rowsCount => rows.length;
}

// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// @AcReflectable()
// class AcSqlDaoResult extends AcResult {
//   static const String KEY_ROWS = 'rows';
//   static const String KEY_AFFECTED_ROWS_COUNT = 'affected_rows_count';
//   static const String KEY_LAST_INSERTED_ID = 'last_inserted_id';
//   static const String KEY_OPERATION = 'operation';
//   static const String KEY_PRIMARY_KEY_COLUMN = 'primary_key_column';
//   static const String KEY_PRIMARY_KEY_VALUE = 'primary_key_value';
//   static const String KEY_TOTAL_ROWS = 'total_rows';
//
//
//   List<Map<String,dynamic>> rows = [];
//
//   @AcBindJsonProperty(key: AcSqlDaoResult.KEY_AFFECTED_ROWS_COUNT)
//   int? affectedRowsCount;
//
//   @AcBindJsonProperty(key: AcSqlDaoResult.KEY_LAST_INSERTED_ID)
//   int? lastInsertedId;
//
//   @AcBindJsonProperty(key: AcSqlDaoResult.KEY_LAST_INSERTED_ID)
//   dynamic lastInsertedIds;
//
//   AcEnumDDRowOperation operation = AcEnumDDRowOperation.unknown;
//
//   @AcBindJsonProperty(key: AcSqlDaoResult.KEY_PRIMARY_KEY_COLUMN)
//   String? primaryKeyColumn;
//
//   @AcBindJsonProperty(key: AcSqlDaoResult.KEY_PRIMARY_KEY_VALUE)
//   dynamic primaryKeyValue;
//
//   @AcBindJsonProperty(key: AcSqlDaoResult.KEY_TOTAL_ROWS)
//   int totalRows = 0;
//
//   AcSqlDaoResult({AcEnumDDRowOperation? operation = AcEnumDDRowOperation.unknown}) {
//     this.operation = operation!;
//   }
//
//   bool hasAffectedRows() {
//     return affectedRowsCount != null && affectedRowsCount! > 0;
//   }
//
//   bool hasRows() {
//     return rows.isNotEmpty;
//   }
//
//   int rowsCount() {
//     return rows.length;
//   }
// }
