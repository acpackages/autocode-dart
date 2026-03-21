import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents the configuration for a database connection.",
  "description": "This class holds all the necessary parameters for establishing a connection to a database, such as hostname, port, credentials, the target database name, and any additional options.",
  "example": "final connectionConfig = AcSqlEventArgs(\n  hostname: 'localhost',\n  port: 3306,\n  username: 'dev_user',\n  password: 'password123',\n  database: 'my_app_db'\n);"
}) */
@AcReflectable()
class AcSqlEventArgs {
  late AcSqlDbTable sqlDbTableInstance;
  Map<String,dynamic>? row;
  List<Map<String,dynamic>>? rows;
  List<Map<String,dynamic>>? rowsWithConditions;
  Map<String,dynamic>? parameters;
  String? condition;
  AcResult? result;

  AcSqlEventArgs({AcSqlDbTable? sqlDbTableInstance ,Map<String,dynamic>? row,String? table,String? condition,Map<String,dynamic>? parameters,AcResult? result,List<Map<String,dynamic>>? rows,List<Map<String,dynamic>>? rowsWithConditions}) {
    if(sqlDbTableInstance!=null){
      this.sqlDbTableInstance = sqlDbTableInstance;
    }
    if(row!=null){
      this.row = row;
    }

    if(rows!=null){
      this.rows = rows;
    }
    if(condition!=null){
      this.condition = condition;
    }
    if(parameters!=null){
      this.parameters = parameters;
    }
    if(result!=null){
      this.result = result;
    }
    if(rowsWithConditions != null){
      this.rowsWithConditions = rowsWithConditions;
    }
  }

  /* AcDoc({
    "summary": "Creates a new AcSqlEventArgs instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the connection configuration."}
    ],
    "returns": "A new, populated AcSqlEventArgs instance.",
    "returns_type": "AcSqlEventArgs"
  }) */
  factory AcSqlEventArgs.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlEventArgs();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the connection properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcSqlEventArgs"
  }) */
  AcSqlEventArgs fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current connection configuration to a JSON map.",
    "returns": "A JSON map representation of the connection configuration.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = AcJsonUtils.getJsonDataFromInstance(instance: this);
    return result;
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