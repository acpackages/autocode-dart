import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents the configuration for a database connection.",
  "description": "This class holds all the necessary parameters for establishing a connection to a database, such as hostname, port, credentials, the target database name, and any additional options.",
  "example": "final connectionConfig = AcSqlConnection(\n  hostname: 'localhost',\n  port: 3306,\n  username: 'dev_user',\n  password: 'password123',\n  database: 'my_app_db'\n);"
}) */
@AcReflectable()
class AcSqlSchemaDifference {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  List<String> missingTablesInDatabase = List.empty(growable: true);
  List<String> missingTablesInDataDictionary = List.empty(growable: true);
  List<AcSqlSchemaTableDifference> modifiedTables = List.empty(growable: true);

  /* AcDoc({
    "summary": "Serializes the current connection configuration to a JSON map.",
    "returns": "A JSON map representation of the connection configuration.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
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

@AcReflectable()
class AcSqlSchemaTableDifference{
  String tableName = "";
  List<String> missingColumnsInDatabase = List.empty(growable: true);
  List<String> missingColumnsInDataDictionary = List.empty(growable: true);

  AcSqlSchemaTableDifference({String? tableName}){
    if(tableName!=null){
      this.tableName = tableName;
    }
  }
}