import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:ac_web/ac_web.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents the configuration for a database connection.",
  "description": "This class holds all the necessary parameters for establishing a connection to a database, such as hostname, port, credentials, the target database name, and any additional options.",
  "example": "final connectionConfig = AcSqlOperation(\n  hostname: 'localhost',\n  port: 3306,\n  username: 'dev_user',\n  password: 'password123',\n  database: 'my_app_db'\n);"
}) */
@AcReflectable()
class AcWsOnWebInterceptorResult extends AcResult {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyContinueOperation = 'continueOperation';
  static const String keyWebResponse = 'webResponse';

  /* AcDoc({"summary": "The username for authenticating with the database."}) */
  @AcBindJsonProperty(key: keyContinueOperation)
  bool? continueOperation;

  Map<String, dynamic>? webResponse;

  AcWsOnWebInterceptorResult({
    bool? continueOperation,
    Map<String, dynamic>? webResponse,
  }) {
    if (continueOperation != null) {
      this.continueOperation = continueOperation;
    }
    if (webResponse != null) {
      this.webResponse = webResponse;
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
  factory AcWsOnWebInterceptorResult.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    var instance = AcWsOnWebInterceptorResult();
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
  AcWsOnWebInterceptorResult fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current connection configuration to a JSON map.",
    "returns": "A JSON map representation of the connection configuration.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = AcJsonUtils.getJsonDataFromInstance(
      instance: this,
    );
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
