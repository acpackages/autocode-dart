import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents the configuration for a database connection.",
  "description": "This class holds all the necessary parameters for establishing a connection to a database, such as hostname, port, credentials, the target database name, and any additional options.",
  "example": "final connectionConfig = AcSqlOperation(\n  hostname: 'localhost',\n  port: 3306,\n  username: 'dev_user',\n  password: 'password123',\n  database: 'my_app_db'\n);"
}) */
@AcReflectable()
class AcSqlEventResult extends AcResult {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCondition = 'condition';
  static const String keyOperation = 'operation';
  static const String keyParameters = 'parameters';
  static const String keyRow = 'row';
  static const String keyTable = 'table';

  /* AcDoc({"summary": "The username for authenticating with the database."}) */
  @AcBindJsonProperty(key: keyCondition)
  String? condition;

  /* AcDoc({"summary": "The port number for the database connection."}) */
  @AcBindJsonProperty(key: keyOperation)
  AcEnumDDRowOperation operation = AcEnumDDRowOperation.unknown;

  /* AcDoc({"summary": "The hostname or IP address of the database server."}) */
  @AcBindJsonProperty(key: keyRow)
  Map<String, dynamic>? row;
  List<Map<String, dynamic>>? rows;
  List<Map<String, dynamic>>? rowsWithConditions;

  /* AcDoc({"summary": "The hostname or IP address of the database server."}) */
  @AcBindJsonProperty(key: keyParameters)
  Map<String, dynamic>? parameters;

  AcResult? result;

  /* AcDoc({"summary": "The username for authenticating with the database."}) */
  @AcBindJsonProperty(key: keyTable)
  String table = "";

  AcSqlEventResult({
    AcEnumDDRowOperation? operation,
    Map<String, dynamic>? row,
    String? table,
    String? condition,
    Map<String, dynamic>? parameters,
    AcResult? result,
    List<Map<String, dynamic>>? rows,
    List<Map<String, dynamic>>? rowsWithConditions,
  }) {
    if (operation != null) {
      this.operation = operation;
    }
    if (row != null) {
      this.row = row;
    }
    if (rows != null) {
      this.rows = rows;
    }
    if (table != null) {
      this.table = table;
    }
    if (condition != null) {
      this.condition = condition;
    }
    if (parameters != null) {
      this.parameters = parameters;
    }
    if (result != null) {
      this.result = result;
    }
    if (rowsWithConditions != null) {
      this.rowsWithConditions = rowsWithConditions;
    }
  }

  /* AcDoc({
    "summary": "Creates a new AcSqlOperation instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the connection configuration."}
    ],
    "returns": "A new, populated AcSqlOperation instance.",
    "returns_type": "AcSqlOperation"
  }) */
  factory AcSqlEventResult.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcSqlEventResult();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the connection properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcSqlOperation"
  }) */
  @override
  AcSqlEventResult fromJson({Map<String, dynamic> jsonData = const {}}) {
    super.fromJson(jsonData: jsonData);
    if (jsonData.containsKey(keyCondition)) {
      condition = jsonData[keyCondition]?.toString();
    }
    if (jsonData.containsKey(keyOperation)) {
      final op = jsonData[keyOperation];
      if (op is String) {
        operation = AcEnumDDRowOperation.fromValue(op);
      } else if (op is AcEnumDDRowOperation) {
        operation = op;
      }
    }
    if (jsonData.containsKey(keyRow) && jsonData[keyRow] is Map) {
      row = Map<String, dynamic>.from(jsonData[keyRow] as Map);
    }
    if (jsonData.containsKey('rows') && jsonData['rows'] is List) {
      rows = (jsonData['rows'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (jsonData.containsKey('rowsWithConditions') && jsonData['rowsWithConditions'] is List) {
      rowsWithConditions = (jsonData['rowsWithConditions'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (jsonData.containsKey(keyParameters) && jsonData[keyParameters] is Map) {
      parameters = Map<String, dynamic>.from(jsonData[keyParameters] as Map);
    }
    if (jsonData.containsKey('result') && jsonData['result'] is Map) {
      result = AcResult.instanceFromJson(jsonData: Map<String, dynamic>.from(jsonData['result']));
    }
    if (jsonData.containsKey(keyTable)) {
      table = jsonData[keyTable]?.toString() ?? table;
    }
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current connection configuration to a JSON map.",
    "returns": "A JSON map representation of the connection configuration.",
    "returns_type": "Map<String, dynamic>"
  }) */
  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map[keyCondition] = condition;
    map[keyOperation] = AcJsonUtils.serializeValue(operation);
    map[keyRow] = AcJsonUtils.serializeValue(row);
    map['rows'] = AcJsonUtils.serializeValue(rows);
    map['rowsWithConditions'] = AcJsonUtils.serializeValue(rowsWithConditions);
    map[keyParameters] = AcJsonUtils.serializeValue(parameters);
    map['result'] = AcJsonUtils.serializeValue(result);
    map[keyTable] = table;
    return map;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the connection.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}
