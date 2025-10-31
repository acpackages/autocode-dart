import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a single condition for a query or filter.",
  "description": "This class defines a single logical comparison, such as `column_name = 'value'`, used within data dictionary definitions. It is typically used to specify conditions for triggers, views, or filtered relationships.",
  "example": "// Represents the condition: WHERE status = 'active'\nfinal condition = AcDDCondition.instanceFromJson(jsonData: {\n  'column_name': 'status',\n  'operator': 'equals',\n  'value': 'active'\n});"
}) */
@AcReflectable()
class AcDDCondition {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDatabaseType = "databaseType";
  static const String keyKey = "key";
  static const String keyOperator = "operator";
  static const String keyValue = "value";

  /* AcDoc({
    "summary": "Specifies the target database type for this condition.",
    "description": "Allows for database-specific conditions, e.g., 'mysql', 'postgres'."
  }) */
  @AcBindJsonProperty(key: keyDatabaseType)
  String databaseType = "";

  /* AcDoc({
    "summary": "The name of the column to which the condition applies."
  }) */
  @AcBindJsonProperty(key: keyKey)
  String key = "";

  /* AcDoc({
    "summary": "The comparison operator to be used.",
    "description": "An enum representing the logical operator (e.g., equals, greater than, not equals)."
  }) */
  AcEnumConditionOperator operator = AcEnumConditionOperator.unknown;

  /* AcDoc({
    "summary": "The value to compare against the column's data.",
    "description": "The type of this value is dynamic and should match the data type of the column specified in `columnName`."
  }) */
  dynamic value;

  /* AcDoc({
    "summary": "Creates a new, empty instance of a data dictionary condition."
  }) */
  AcDDCondition();

  /* AcDoc({
    "summary": "Creates a new AcDDCondition instance from a JSON map.",
    "description": "This factory constructor provides a convenient way to create and populate a condition object directly from a JSON data structure.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the condition."}
    ],
    "returns": "A new, populated AcDDCondition instance.",
    "returns_type": "AcDDCondition"
  }) */
  factory AcDDCondition.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDCondition();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the condition's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDCondition"
  }) */
  AcDDCondition fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current condition instance to a JSON map.",
    "description": "An instance method that uses reflection-based utilities to convert this object's properties into a JSON map.",
    "returns": "A JSON map representation of the condition.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the condition.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
