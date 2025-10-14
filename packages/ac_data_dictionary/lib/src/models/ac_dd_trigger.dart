import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a database trigger definition from a data dictionary.",
  "description": "This class models a database trigger, including its name, the table it's associated with, the event that fires it (e.g., 'AFTER INSERT'), and the SQL code to be executed. It provides methods for generating SQL statements to create or drop the trigger.",
  "example": "// 1. Retrieve a trigger definition.\nfinal myTrigger = AcDDTrigger.getInstance('update_timestamp_on_user_change');\n\n// 2. Generate the SQL to create the trigger for MySQL.\nfinal createSql = myTrigger.getCreateTriggerStatement(databaseType: AcEnumSqlDatabaseType.mysql);\nprint(createSql);"
}) */
@AcReflectable()
class AcDDTrigger {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyRowOperation = "rowOperation";
  static const String keyTableName = "tableName";
  static const String keyTriggerCode = "triggerCode";
  static const String keyTriggerExecution = "triggerExecution";
  static const String keyTriggerName = "triggerName";

  /* AcDoc({
    "summary": "The DML operation that fires the trigger (e.g., 'INSERT', 'UPDATE', 'DELETE')."
  }) */
  @AcBindJsonProperty(key: keyRowOperation)
  String rowOperation = "";

  /* AcDoc({
    "summary": "The timing of the trigger's execution (e.g., 'BEFORE', 'AFTER')."
  }) */
  @AcBindJsonProperty(key: keyTriggerExecution)
  String triggerExecution = "";

  /* AcDoc({
    "summary": "The name of the table this trigger is attached to."
  }) */
  @AcBindJsonProperty(key: keyTableName)
  String tableName = "";

  /* AcDoc({
    "summary": "The unique name of the trigger."
  }) */
  @AcBindJsonProperty(key: keyTriggerName)
  String triggerName = "";

  /* AcDoc({
    "summary": "The SQL code block that is executed when the trigger fires."
  }) */
  @AcBindJsonProperty(key: keyTriggerCode)
  String triggerCode = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a trigger definition."
  }) */
  AcDDTrigger();

  /* AcDoc({
    "summary": "Creates a new AcDDTrigger instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the trigger."}
    ],
    "returns": "A new, populated AcDDTrigger instance.",
    "returns_type": "AcDDTrigger"
  }) */
  factory AcDDTrigger.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDTrigger();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Gets a trigger definition from a registered data dictionary.",
    "description": "Looks up a trigger by its name within the specified data dictionary and returns a populated instance. If not found, an empty instance is returned.",
    "params": [
      {"name": "triggerName", "description": "The name of the trigger to retrieve."},
      {"name": "dataDictionaryName", "description": "The name of the data dictionary to query. Defaults to 'default'."}
    ],
    "returns": "An AcDDTrigger instance.",
    "returns_type": "AcDDTrigger"
  }) */
  factory AcDDTrigger.getInstance(
    String triggerName, {
    String dataDictionaryName = "default",
  }) {
    final result = AcDataDictionary.getTrigger(triggerName: triggerName,dataDictionaryName: dataDictionaryName) ?? AcDDTrigger();
    return result;
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to drop the trigger.",
    "description": "Creates a standard `DROP TRIGGER IF EXISTS` statement. The `databaseType` parameter is included for future dialect-specific implementations but is not currently used.",
    "params": [
      {"name": "triggerName", "description": "The name of the trigger to drop."},
      {"name": "databaseType", "description": "The target SQL database type (for future use)."}
    ],
    "returns": "A SQL string to drop the trigger.",
    "returns_type": "String"
  }) */
  static String getDropTriggerStatement({
    required String triggerName,
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    return 'DROP TRIGGER IF EXISTS $triggerName;';
  }

  /* AcDoc({
    "summary": "Generates a SQL statement to create the trigger.",
    "description": "Constructs a complete `CREATE TRIGGER` statement based on the object's properties for a specific SQL dialect.",
    "params": [
      {"name": "databaseType", "description": "The target SQL dialect (e.g., MySQL, SQLite)."}
    ],
    "returns": "The complete SQL string to create the trigger, or an empty string if the database type is not supported.",
    "returns_type": "String"
  }) */
  String getCreateTriggerStatement({
    AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown,
  }) {
    String result = '';
    if ([
      AcEnumSqlDatabaseType.mysql,
      AcEnumSqlDatabaseType.sqlite,
    ].contains(databaseType)) {
      result =
          'CREATE TRIGGER $triggerName $triggerExecution $rowOperation ON $tableName FOR EACH ROW BEGIN $triggerCode END;';
    }
    return result;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the trigger's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDTrigger"
  }) */
  AcDDTrigger fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current trigger instance to a JSON map.",
    "returns": "A JSON map representation of the trigger.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the trigger.",
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
// class AcDDTrigger {
//   static const String KEY_ROW_OPERATION = "row_operation";
//   static const String KEY_TABLE_NAME = "table_name";
//   static const String KEY_TRIGGER_CODE = "trigger_code";
//   static const String KEY_TRIGGER_EXECUTION = "trigger_execution";
//   static const String KEY_TRIGGER_NAME = "trigger_name";
//
//   @AcBindJsonProperty(key: AcDDTrigger.KEY_ROW_OPERATION)
//   String rowOperation = "";
//
//   @AcBindJsonProperty(key: AcDDTrigger.KEY_TRIGGER_EXECUTION)
//   String triggerExecution = "";
//
//   @AcBindJsonProperty(key: AcDDTrigger.KEY_TABLE_NAME)
//   String tableName = "";
//
//   @AcBindJsonProperty(key: AcDDTrigger.KEY_TRIGGER_NAME)
//   String triggerName = "";
//
//   @AcBindJsonProperty(key: AcDDTrigger.KEY_TRIGGER_CODE)
//   String triggerCode = "";
//
//   static AcDDTrigger instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDTrigger();
//     instance.fromJson(jsonData:jsonData);
//     return instance;
//   }
//
//   static AcDDTrigger getInstance(String triggerName, {String dataDictionaryName = "default"}) {
//     final result = AcDDTrigger();
//     final acDataDictionary = AcDataDictionary.getInstance(dataDictionaryName:dataDictionaryName);
//
//     if (acDataDictionary.triggers.containsKey(triggerName)) {
//       result.fromJson(jsonData: acDataDictionary.triggers[triggerName]);
//     }
//
//     return result;
//   }
//
//   static String getDropTriggerStatement({required String triggerName, AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     return 'DROP TRIGGER IF EXISTS $triggerName;';
//   }
//
//   String getCreateTriggerStatement({AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown}) {
//     String result = '';
//     if ([AcEnumSqlDatabaseType.mysql,AcEnumSqlDatabaseType.sqlite].contains(databaseType)) {
//       result = 'CREATE TRIGGER $triggerName $triggerExecution $rowOperation ON $tableName FOR EACH ROW BEGIN $triggerCode END;';
//     }
//     return result;
//   }
//
//   AcDDTrigger fromJson({required Map<String, dynamic> jsonData}) {
//     AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
//     return this;
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
