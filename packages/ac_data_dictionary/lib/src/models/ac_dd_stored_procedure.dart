import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a database stored procedure definition.",
  "description": "This class models a stored procedure from a data dictionary, containing its name and the full SQL code body. It provides methods for generating SQL statements to create or drop the procedure.",
  "example": "// 1. Retrieve a stored procedure definition from the data dictionary.\nfinal sp = AcDDStoredProcedure.getInstance(storedProcedureName: 'get_user_by_id');\n\n// 2. Generate the SQL to create the procedure.\nfinal createSql = sp.getCreateStoredProcedureStatement();\nprint(createSql);"
}) */
@AcReflectable()
class AcDDStoredProcedure {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyStoredProcedureName = "storedProcedureName";
  static const String keyStoredProcedureCode = "storedProcedureCode";

  /* AcDoc({
    "summary": "The name of the database stored procedure."
  }) */
  @AcBindJsonProperty(key: keyStoredProcedureName)
  String storedProcedureName = "";

  /* AcDoc({
    "summary": "The complete SQL code block that defines the stored procedure."
  }) */
  @AcBindJsonProperty(key: keyStoredProcedureCode)
  String storedProcedureCode = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a stored procedure definition."
  }) */
  AcDDStoredProcedure();

  /* AcDoc({
    "summary": "Creates a new AcDDStoredProcedure instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the stored procedure."}
    ],
    "returns": "A new, populated AcDDStoredProcedure instance.",
    "returns_type": "AcDDStoredProcedure"
  }) */
  factory AcDDStoredProcedure.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDStoredProcedure();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Gets a stored procedure definition from a registered data dictionary.",
    "description": "Looks up a stored procedure by its name within the specified data dictionary and returns a populated instance. If not found, an empty instance is returned.",
    "params": [
      {"name": "storedProcedureName", "description": "The name of the stored procedure to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDStoredProcedure instance.",
    "returns_type": "AcDDStoredProcedure"
  }) */
  factory AcDDStoredProcedure.getInstance({
    required String storedProcedureName,
    String dataDictionaryName = "default",
  }) {
    final result = AcDDStoredProcedure();
    final acDataDictionary = AcDataDictionary.getInstance(
      dataDictionaryName: dataDictionaryName,
    );

    if (acDataDictionary.storedProcedures.containsKey(storedProcedureName)) {
      result.fromJson(
        jsonData: acDataDictionary.storedProcedures[storedProcedureName],
      );
    }
    return result;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to drop the stored procedure.",
    "description": "Creates a standard `DROP PROCEDURE IF EXISTS` statement. Note: The `databaseType` parameter is not currently used.",
    "params": [
      {"name": "storedProcedureName", "description": "The name of the stored procedure to drop."},
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to drop the stored procedure.",
    "returns_type": "String"
  }) */
  static String getDropStoredProcedureStatement({
    required String storedProcedureName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return "DROP PROCEDURE IF EXISTS $storedProcedureName;";
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDStoredProcedure"
  }) */
  AcDDStoredProcedure fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to create the stored procedure.",
    "description": "Returns the procedure's code body, intended for a `CREATE PROCEDURE` statement. Note: The `databaseType` parameter is not currently used.",
    "params": [
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "The SQL code for the stored procedure's body.",
    "returns_type": "String"
  }) */
  String getCreateStoredProcedureStatement({
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return storedProcedureCode;
  }

  /* AcDoc({
    "summary": "Serializes the current instance to a JSON map.",
    "returns": "A JSON map representation of the stored procedure.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the object.",
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
// class AcDDStoredProcedure {
//   static const String KEY_STORED_PROCEDURE_NAME = "stored_procedure_name";
//   static const String KEY_STORED_PROCEDURE_CODE = "stored_procedure_code";
//
//   @AcBindJsonProperty(key: AcDDStoredProcedure.KEY_STORED_PROCEDURE_NAME)
//   String storedProcedureName = "";
//
//   @AcBindJsonProperty(key: AcDDStoredProcedure.KEY_STORED_PROCEDURE_CODE)
//   String storedProcedureCode = "";
//
//   static AcDDStoredProcedure instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDStoredProcedure();
//     instance.fromJson(jsonData:jsonData);
//     return instance;
//   }
//
//   static AcDDStoredProcedure getInstance({required String storedProcedureName, String dataDictionaryName = "default"}) {
//     final result = AcDDStoredProcedure();
//     final acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName: dataDictionaryName);
//
//     if (acDataDictionary.storedProcedures.containsKey(storedProcedureName)) {
//       result.fromJson(jsonData: acDataDictionary.storedProcedures[storedProcedureName]);
//     }
//     return result;
//   }
//
//   static String getDropStoredProcedureStatement({required String storedProcedureName,AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     String result = "DROP PROCEDURE IF EXISTS $storedProcedureName;";
//     return result;
//   }
//
//   AcDDStoredProcedure fromJson({required Map<String, dynamic> jsonData}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
//     return this;
//   }
//
//   String getCreateStoredProcedureStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     String result = storedProcedureCode;
//     return result;
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance: this);
//   }
//
//   @override
//   String toString() {
//     return AcJsonUtils.prettyEncode(toJson());
//   }
// }
