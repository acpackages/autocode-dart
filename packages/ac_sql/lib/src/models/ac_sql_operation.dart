import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents the configuration for a database connection.",
  "description": "This class holds all the necessary parameters for establishing a connection to a database, such as hostname, port, credentials, the target database name, and any additional options.",
  "example": "final connectionConfig = AcSqlOperation(\n  hostname: 'localhost',\n  port: 3306,\n  username: 'dev_user',\n  password: 'password123',\n  database: 'my_app_db'\n);"
}) */
@AcReflectable()
class AcSqlOperation {
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
  Map<String,dynamic>? row;

  /* AcDoc({"summary": "The hostname or IP address of the database server."}) */
  @AcBindJsonProperty(key: keyParameters)
  Map<String,dynamic>? parameters;

  /* AcDoc({"summary": "The username for authenticating with the database."}) */
  @AcBindJsonProperty(key: keyTable)
  String table = "";
  
  AcSqlOperation({AcEnumDDRowOperation? operation,Map<String,dynamic>? row,String? table,String? condition,Map<String,dynamic>? parameters}) {
    if(operation!=null){
      this.operation = operation;
    }
    if(row!=null){
      this.row = row;
    }
    if(table!=null){
      this.table = table;
    }
    if(condition!=null){
      this.condition = condition;
    }
    if(parameters!=null){
      this.parameters = parameters;
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
  factory AcSqlOperation.instanceFromJson({required Map<String, dynamic> jsonData}) {
    var instance = AcSqlOperation();
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
  AcSqlOperation fromJson({Map<String, dynamic> jsonData = const {}}) {
    if(jsonData.containsKey(keyOperation)){
      operation = AcEnumDDRowOperation.fromValue(jsonData[keyOperation]);
    }
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
    result[keyOperation] = operation.value;
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