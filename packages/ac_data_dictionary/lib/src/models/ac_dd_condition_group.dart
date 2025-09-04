import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Represents a group of conditions linked by a logical operator.",
  "description": "This class allows for the construction of complex, nested query conditions by grouping `AcDDCondition` and other `AcDDConditionGroup` objects. This enables creating expressions like `(condition1 AND condition2) OR condition3`.",
  "example": "// Represents: (age > 18 AND city = 'New York')\nfinal group = AcDDConditionGroup()\n  ..operator = AcEnumLogicalOperator.and\n  ..addCondition(columnName: 'age', operator: AcEnumConditionOperator.greaterThan, value: 18)\n  ..addCondition(columnName: 'city', operator: AcEnumConditionOperator.equals, value: 'New York');"
}) */
@AcReflectable()
class AcDDConditionGroup {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDatabaseType = "databaseType";
  static const String keyConditions = "conditions";
  static const String keyOperator = "operator";

  /* AcDoc({
    "summary": "Specifies the target database type for this condition group.",
    "description": "Allows for database-specific logic for the entire group, e.g., 'mysql', 'postgres'."
  }) */
  @AcBindJsonProperty(key: keyDatabaseType)
  String databaseType = "";

  /* AcDoc({
    "summary": "A list of conditions or nested condition groups.",
    "description": "This list can contain instances of both `AcDDCondition` and `AcDDConditionGroup`, allowing for the creation of a nested condition tree."
  }) */
  List<dynamic> conditions = [];

  /* AcDoc({
    "summary": "The logical operator that joins the items in the `conditions` list.",
    "description": "An enum representing the logical operator (e.g., AND, OR) used to evaluate the conditions within this group."
  }) */
  AcEnumLogicalOperator operator = AcEnumLogicalOperator.unknown;

  /* AcDoc({
    "summary": "Creates a new, empty instance of a condition group."
  }) */
  AcDDConditionGroup();

  /* AcDoc({
    "summary": "Creates a new AcDDConditionGroup instance from a JSON map.",
    "description": "This factory constructor provides a convenient way to create and populate a condition group, including its nested conditions, directly from a JSON data structure.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the condition group."}
    ],
    "returns": "A new, populated AcDDConditionGroup instance.",
    "returns_type": "AcDDConditionGroup"
  }) */
  factory AcDDConditionGroup.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDConditionGroup();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Adds a simple condition to this group.",
    "description": "Creates and adds an `AcDDCondition` to the `conditions` list.",
    "params": [
      {"name": "columnName", "description": "The name of the column for the condition."},
      {"name": "operator", "description": "The comparison operator."},
      {"name": "value", "description": "The value to compare against."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDConditionGroup"
  }) */
  AcDDConditionGroup addCondition({
    required String columnName,
    required AcEnumConditionOperator operator,
    required dynamic value,
  }) {
    conditions.add(
      AcDDCondition.instanceFromJson(
        jsonData: {
          // Assuming AcDDCondition constants are also refactored to lowerCamelCase
          AcDDCondition.keyColumnName: columnName,
          AcDDCondition.keyOperator: operator,
          AcDDCondition.keyValue: value,
        },
      ),
    );
    return this;
  }

  /* AcDoc({
    "summary": "Adds a nested condition group to this group.",
    "description": "Creates and adds another `AcDDConditionGroup` to the `conditions` list, allowing for nested logic.",
    "params": [
      {"name": "conditions", "description": "A list of conditions for the new nested group."},
      {"name": "operator", "description": "The logical operator for the new nested group."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDConditionGroup"
  }) */
  AcDDConditionGroup addConditionGroup({
    required List<dynamic> conditions,
    AcEnumLogicalOperator operator = AcEnumLogicalOperator.and,
  }) {
    this.conditions.add(
      AcDDConditionGroup.instanceFromJson(
        jsonData: {
          AcDDConditionGroup.keyConditions: conditions,
          AcDDConditionGroup.keyOperator: operator,
        },
      ),
    );
    return this;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the polymorphic `conditions` list by checking for identifying keys, then uses a reflection utility for the remaining properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the condition group's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDConditionGroup"
  }) */
  AcDDConditionGroup fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyConditions)) {
      final conditionList = json[keyConditions] as List;
      for (final condition in conditionList) {
        if (condition is Map<String, dynamic>) {
          // If it has a 'conditions' key, it's a nested group.
          if (condition.containsKey(keyConditions)) {
            conditions.add(
              AcDDConditionGroup.instanceFromJson(jsonData: condition),
            );
          }
          // Otherwise, if it has a 'column_name' key, it's a simple condition.
          else if (condition.containsKey(AcDDCondition.keyColumnName)) {
            conditions.add(AcDDCondition.instanceFromJson(jsonData: condition));
          }
        }
      }
      json.remove(keyConditions);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current condition group instance to a JSON map.",
    "description": "An instance method that uses reflection-based utilities to convert this object's properties into a JSON map.",
    "returns": "A JSON map representation of the condition group.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the condition group.",
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
// class AcDDConditionGroup {
//   static const String KEY_DATABASE_TYPE = "database_type";
//   static const String KEY_CONDITIONS = "conditions";
//   static const String KEY_OPERATOR = "operator";
//
//   @AcBindJsonProperty(key: KEY_DATABASE_TYPE)
//   String databaseType = "";
//
//   List<dynamic> conditions = [];
//   AcEnumLogicalOperator operator = AcEnumLogicalOperator.unknown;
//
//   AcDDConditionGroup();
//
//   factory AcDDConditionGroup.instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDConditionGroup();
//     instance.fromJson(jsonData:jsonData);
//     return instance;
//   }
//
//   AcDDConditionGroup addCondition({required String columnName, required AcEnumConditionOperator operator, required dynamic value}) {
//     conditions.add(AcDDCondition.instanceFromJson(jsonData:{
//       AcDDCondition.KEY_COLUMN_NAME: columnName,
//       AcDDCondition.KEY_OPERATOR: operator,
//       AcDDCondition.KEY_VALUE: value,
//     }));
//     return this;
//   }
//
//   AcDDConditionGroup addConditionGroup({required List<dynamic> conditions, AcEnumLogicalOperator operator = AcEnumLogicalOperator.and}) {
//     this.conditions.add(AcDDConditionGroup.instanceFromJson(jsonData:{
//       AcDDConditionGroup.KEY_CONDITIONS: conditions,
//       AcDDConditionGroup.KEY_OPERATOR: operator,
//     }));
//     return this;
//   }
//
//   AcDDConditionGroup fromJson({required Map<String, dynamic> jsonData}) {
//     Map<String,dynamic> json = Map.from(jsonData);
//     if (json.containsKey(KEY_CONDITIONS)) {
//       for (var condition in json[KEY_CONDITIONS]) {
//         if (condition is Map<String, dynamic>) {
//           if (condition.containsKey(KEY_CONDITIONS)) {
//             conditions.add(AcDDConditionGroup.instanceFromJson(jsonData:condition));
//           } else if (condition.containsKey(AcDDCondition.KEY_COLUMN_NAME)) {
//             conditions.add(AcDDCondition.instanceFromJson(jsonData:condition));
//           }
//         } else {
//           conditions.add(condition);
//         }
//       }
//       json.remove(KEY_CONDITIONS);
//     }
//     AcJsonUtils.setInstancePropertiesFromJsonData(instance:this, jsonData:json);
//     return this;
//   }
//
//   Map<String, dynamic> toJson() {
//     return AcJsonUtils.getJsonDataFromInstance(instance:this);
//   }
//
//   @override
//   String toString() {
//     return AcJsonUtils.prettyEncode(toJson());
//   }
// }
