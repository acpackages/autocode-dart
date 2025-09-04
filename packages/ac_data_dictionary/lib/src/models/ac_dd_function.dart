import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a database function definition from a data dictionary.",
  "description": "This class models a stored function or procedure, holding its name and the corresponding SQL code body. It provides methods for generating SQL statements to create or drop the function.",
  "example": "// Example of retrieving a function definition from the data dictionary.\nfinal myFunction = AcDDFunction.getInstance(functionName: 'calculate_total');\n\n// Generate the SQL to create the function.\nfinal createSql = myFunction.getCreateFunctionStatement();\nprint(createSql);"
}) */
@AcReflectable()
class AcDDFunction {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyFunctionName = "functionName";
  static const String keyFunctionCode = "functionCode";

  /* AcDoc({
    "summary": "The name of the database function."
  }) */
  @AcBindJsonProperty(key: keyFunctionName)
  String functionName = "";

  /* AcDoc({
    "summary": "The complete SQL code block for the function's body."
  }) */
  @AcBindJsonProperty(key: keyFunctionCode)
  String functionCode = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a data dictionary function."
  }) */
  AcDDFunction();

  /* AcDoc({
    "summary": "Creates a new AcDDFunction instance from a JSON map.",
    "description": "This factory constructor provides a convenient way to create and populate a function object directly from a JSON data structure.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the function."}
    ],
    "returns": "A new, populated AcDDFunction instance.",
    "returns_type": "AcDDFunction"
  }) */
  factory AcDDFunction.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDFunction();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Gets a function definition from a registered data dictionary.",
    "description": "Looks up a function by its name within the specified data dictionary and returns a populated `AcDDFunction` instance. If not found, an empty instance is returned.",
    "params": [
      {"name": "functionName", "description": "The name of the function to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDFunction instance.",
    "returns_type": "AcDDFunction"
  }) */
  factory AcDDFunction.getInstance({
    required String functionName,
    String dataDictionaryName = "default",
  }) {
    final result = AcDDFunction();
    final acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );
    if (acDataDictionary.functions.containsKey(functionName)) {
      result.fromJson(jsonData: acDataDictionary.functions[functionName]);
    }
    return result;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to drop the function.",
    "description": "Creates a standard `DROP FUNCTION IF EXISTS` statement. Note: The `databaseType` parameter is not currently used, but is included for future dialect-specific implementations.",
    "params": [
      {"name": "functionName", "description": "The name of the function to drop."},
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to drop the function.",
    "returns_type": "String"
  }) */
  static String getDropFunctionStatement({
    required String functionName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return "DROP FUNCTION IF EXISTS $functionName;";
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the function's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDFunction"
  }) */
  AcDDFunction fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current function instance to a JSON map.",
    "description": "An instance method that uses reflection-based utilities to convert this object's properties into a JSON map.",
    "returns": "A JSON map representation of the function.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to create the function.",
    "description": "Returns the function's code body, intended to be used within a `CREATE FUNCTION` statement. Note: The `databaseType` parameter is not currently used, but is included for future dialect-specific implementations.",
    "params": [
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "The SQL code for the function's body.",
    "returns_type": "String"
  }) */
  String getCreateFunctionStatement({
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return functionCode;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the function.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}

// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// @AcReflectable()
// class AcDDFunction {
//   static const String KEY_FUNCTION_NAME = "function_name";
//   static const String KEY_FUNCTION_CODE = "function_code";
//
//   @AcBindJsonProperty(key: KEY_FUNCTION_NAME)
//   String functionName = "";
//
//   @AcBindJsonProperty(key: KEY_FUNCTION_CODE)
//   String functionCode = "";
//
//   AcDDFunction();
//
//   factory AcDDFunction.instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDFunction();
//     instance.fromJson(jsonData:jsonData);
//     return instance;
//   }
//
//   factory AcDDFunction.getInstance({required String functionName, String dataDictionaryName = "default"}) {
//     final result = AcDDFunction();
//     final acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName:dataDictionaryName);
//     if (acDataDictionary.functions.containsKey(functionName)) {
//       result.fromJson(jsonData:acDataDictionary.functions[functionName]);
//     }
//     return result;
//   }
//
//   static String getDropFunctionStatement({required String functionName, AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     String result = "DROP FUNCTION IF EXISTS $functionName;";
//     return result;
//   }
//
//   AcDDFunction fromJson({required Map<String, dynamic> jsonData}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(instance:this, jsonData:jsonData);
//     return this;
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance:this);
//   }
//
//
//
//   String getCreateFunctionStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     String result = functionCode;
//     return result;
//   }
//
//   @override
//   String toString() {
//     return AcJsonUtils.prettyEncode(toJson());
//   }
// }
