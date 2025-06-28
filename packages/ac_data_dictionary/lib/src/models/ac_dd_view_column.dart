import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a single column within a database view definition.",
  "description": "This class models a column as it appears in a view, including its name, data type, its original source table and column, and any specific properties. This is distinct from a table column as it represents a column in a result set of a query.",
  "example": "// Example of a view column 'user_name' derived from the 'users' table.\nfinal viewColumn = AcDDViewColumn.instanceFromJson(jsonData: {\n  'column_name': 'user_name',\n  'column_type': 'text',\n  'column_source': 'table',\n  'column_source_name': 'users.name'\n});"
}) */
@AcReflectable()
class AcDDViewColumn {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyColumnName = "column_name";
  static const String keyColumnProperties = "column_properties";
  static const String keyColumnType = "column_type";
  static const String keyColumnValue = "column_value";
  static const String keyColumnSource = "column_source";
  static const String keyColumnSourceName = "column_source_name";

  /* AcDoc({"summary": "The name of the column as it appears in the view."}) */
  @AcBindJsonProperty(key: keyColumnName)
  String columnName = "";

  /* AcDoc({
    "summary": "A map of properties that define the view column's behavior.",
    "description": "Contains key-value pairs for metadata specific to this column in the context of the view."
  }) */
  @AcBindJsonProperty(key: keyColumnProperties)
  Map<String, AcDDTableColumnProperty> columnProperties = {};

  /* AcDoc({
    "summary": "The data type of the column as a string (e.g., 'text', 'integer')."
  }) */
  @AcBindJsonProperty(key: keyColumnType)
  String columnType = "text";

  /* AcDoc({"summary": "The current value of the column, used when this object represents a specific record's data."}) */
  @AcBindJsonProperty(key: keyColumnValue)
  dynamic columnValue;

  /* AcDoc({
    "summary": "The type of the source for this column's data (e.g., 'table')."
  }) */
  @AcBindJsonProperty(key: keyColumnSource)
  String columnSource = "";

  /* AcDoc({
    "summary": "The original source of the data (e.g., 'users.name')."
  }) */
  @AcBindJsonProperty(key: keyColumnSourceName)
  String columnSourceName = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of a view column definition."
  }) */
  AcDDViewColumn();

  /* AcDoc({
    "summary": "Creates a new AcDDViewColumn instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the view column."}
    ],
    "returns": "A new, populated AcDDViewColumn instance.",
    "returns_type": "AcDDViewColumn"
  }) */
  factory AcDDViewColumn.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcDDViewColumn();
    instance.fromJson(jsonData:jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested `columnProperties` map before using a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the view column's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDViewColumn"
  }) */
  AcDDViewColumn fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyColumnProperties)) {
      final props = json[keyColumnProperties] as Map<String, dynamic>;
      for (final entry in props.entries) {
        columnProperties[entry.key] = AcDDTableColumnProperty.instanceFromJson(jsonData:entry.value);
      }
      json.remove(keyColumnProperties);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current view column instance to a JSON map.",
    "returns": "A JSON map representation of the view column.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the view column.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency with other classes.
    return AcJsonUtils.prettyEncode(toJson());
  }
}
// import 'dart:convert';
// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// @AcReflectable()
// class AcDDViewColumn {
//   static const String KEY_COLUMN_NAME = "column_name";
//   static const String KEY_COLUMN_PROPERTIES = "column_properties";
//   static const String KEY_COLUMN_TYPE = "column_type";
//   static const String KEY_COLUMN_VALUE = "column_value";
//   static const String KEY_COLUMN_SOURCE = "column_source";
//   static const String KEY_COLUMN_SOURCE_NAME = "column_source_name";
//
//   @AcBindJsonProperty(key: KEY_COLUMN_NAME)
//   String columnName = "";
//
//   @AcBindJsonProperty(key: KEY_COLUMN_PROPERTIES)
//   Map<String, AcDDTableColumnProperty> columnProperties = {};
//
//   @AcBindJsonProperty(key: KEY_COLUMN_TYPE)
//   String columnType = "text";
//
//   @AcBindJsonProperty(key: KEY_COLUMN_VALUE)
//   dynamic columnValue;
//
//   @AcBindJsonProperty(key: KEY_COLUMN_SOURCE)
//   String columnSource = "";
//
//   @AcBindJsonProperty(key: KEY_COLUMN_SOURCE_NAME)
//   String columnSourceName = "";
//
//   AcDDViewColumn();
//
//   static AcDDViewColumn instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDViewColumn();
//     instance.fromJson(jsonData:jsonData);
//     return instance;
//   }
//
//   AcDDViewColumn fromJson({required Map<String, dynamic> jsonData}) {
//     Map<String,dynamic> json = Map.from(jsonData);
//     if (json.containsKey(KEY_COLUMN_PROPERTIES)) {
//       final props = json[KEY_COLUMN_PROPERTIES] as Map<String, dynamic>;
//       for (final entry in props.entries) {
//         columnProperties[entry.key] = AcDDTableColumnProperty.instanceFromJson(jsonData:entry.value);
//       }
//       json.remove(KEY_COLUMN_PROPERTIES);
//     }
//     AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
//     return this;
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance: this);
//   }
//
//   @override
//   String toString() {
//     return JsonEncoder.withIndent('  ').convert(toJson());
//   }
// }