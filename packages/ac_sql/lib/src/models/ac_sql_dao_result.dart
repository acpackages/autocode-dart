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
  static const String keyAffectedRowsCount = 'affectedRowsCount';
  static const String keyLastInsertedId = 'lastInsertedId';
  static const String keyLastInsertedIds = 'lastInsertedIds';
  static const String keyOperation = 'operation';
  static const String keyPrimaryKeyColumn = 'primaryKeyColumn';
  static const String keyPrimaryKeyValue = 'primaryKeyValue';
  static const String keyTotalRows = 'totalRows';

  /* AcDoc({
    "summary": "A list of rows returned by a SELECT query.",
    "description": "Each item in the list is a map representing a single row, with column names as keys."
  }) */
  List<Map<String, dynamic>> rows = List.empty(growable: true);

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
  dynamic? lastInsertedId;

  /* AcDoc({
    "summary": "A list of auto-generated IDs from a bulk INSERT operation.",
    "remarks": ["This field shares a JSON key with `lastInsertedId`. Deserialization behavior may vary depending on the exact JSON payload (single value vs. list)."]
  }) */
  @AcBindJsonProperty(key: keyLastInsertedIds)
  List<dynamic> lastInsertedIds = [];

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

  /* AcDoc({ "description": "Factory to create an AcSqlDaoResult from JSON." }) */
  factory AcSqlDaoResult.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlDaoResult();
    return instance.fromJson(jsonData: jsonData);
  }

  @override
  AcSqlDaoResult fromJson({required Map<String, dynamic> jsonData}) {
    super.fromJson(jsonData: jsonData);
    if (jsonData.containsKey(keyRows) || jsonData.containsKey('rows')) {
      final r = jsonData[keyRows] ?? jsonData['rows'];
      if (r is List) {
        rows = r.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    affectedRowsCount = AcJsonUtils.deserializeValue<int>(
      jsonData[keyAffectedRowsCount] ?? jsonData['affected_rows_count'],
    );
    if (jsonData.containsKey(keyLastInsertedId) || jsonData.containsKey('last_inserted_id')) {
      lastInsertedId = jsonData[keyLastInsertedId] ?? jsonData['last_inserted_id'];
    }
    if (jsonData.containsKey(keyLastInsertedIds) || jsonData.containsKey('last_inserted_ids')) {
      lastInsertedIds = AcJsonUtils.deserializeList<dynamic>(
        jsonData[keyLastInsertedIds] ?? jsonData['last_inserted_ids'],
      );
    }
    operation = AcJsonUtils.deserializeValue<AcEnumDDRowOperation>(
      jsonData[keyOperation] ?? jsonData['operation'],
      enumValues: AcEnumDDRowOperation.values,
      defaultValue: operation,
    )!;
    primaryKeyColumn = AcJsonUtils.deserializeValue<String>(
      jsonData[keyPrimaryKeyColumn] ?? jsonData['primary_key_column'],
      defaultValue: primaryKeyColumn,
    );
    if (jsonData.containsKey(keyPrimaryKeyValue) || jsonData.containsKey('primary_key_value')) {
      primaryKeyValue = jsonData[keyPrimaryKeyValue] ?? jsonData['primary_key_value'];
    }
    totalRows = AcJsonUtils.deserializeValue<int>(
      jsonData[keyTotalRows] ?? jsonData['total_rows'],
      defaultValue: totalRows,
    )!;
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map[keyRows] = AcJsonUtils.serializeValue(rows);
    map[keyAffectedRowsCount] = affectedRowsCount;
    map[keyLastInsertedId] = lastInsertedId;
    map[keyLastInsertedIds] = AcJsonUtils.serializeValue(lastInsertedIds);
    map[keyOperation] = AcJsonUtils.serializeValue(operation);
    map[keyPrimaryKeyColumn] = primaryKeyColumn;
    map[keyPrimaryKeyValue] = AcJsonUtils.serializeValue(primaryKeyValue);
    map[keyTotalRows] = totalRows;
    return map;
  }
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
