import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a single property of a table column.",
  "description": "This class models a key-value pair that defines a specific behavior or metadata attribute for a column, such as 'isPrimaryKey' or 'defaultValue'. The `propertyName` is an enum (`AcEnumDDColumnProperty`) and `propertyValue` is dynamic to accommodate different value types (e.g., bool, String, int).",
  "example": "// Example of a 'primaryKey' property.\nfinal pkProperty = AcDDTableColumnProperty.instanceFromJson(jsonData: {\n  'property_name': 'primaryKey',\n  'property_value': true\n});"
}) */
@AcReflectable()
class AcDDTableColumnProperty {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyPropertyName = "propertyName";
  static const String keyPropertyValue = "propertyValue";

  /* AcDoc({
    "summary": "The name of the column property.",
    "description": "An enum value that identifies the specific property, such as `primaryKey`, `notNull`, `defaultValue`, etc."
  }) */
  @AcBindJsonProperty(key: keyPropertyName)
  AcEnumDDColumnProperty propertyName = AcEnumDDColumnProperty.unknown;

  /* AcDoc({
    "summary": "The value associated with the property.",
    "description": "The type of this value is dynamic and corresponds to the `propertyName`. For example, it would be a boolean for `isPrimaryKey` or a string for `defaultValue`."
  }) */
  @AcBindJsonProperty(key: keyPropertyValue)
  dynamic propertyValue;

  /* AcDoc({
    "summary": "Creates a new, empty instance of a column property."
  }) */
  AcDDTableColumnProperty();

  /* AcDoc({
    "summary": "Creates a new AcDDTableColumnProperty instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the column property."}
    ],
    "returns": "A new, populated AcDDTableColumnProperty instance.",
    "returns_type": "AcDDTableColumnProperty"
  }) */
  factory AcDDTableColumnProperty.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDTableColumnProperty();
    instance.fromJson(jsonData: jsonData);
    return instance;
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the property's data."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcDDTableColumnProperty"
  }) */
  AcDDTableColumnProperty fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current column property instance to a JSON map.",
    "returns": "A JSON map representation of the column property.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the column property.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}

// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
// import 'package:ac_mirrors/ac_mirrors.dart';
// import 'package:autocode/autocode.dart';
// @AcReflectable()
// class AcDDTableColumnProperty {
//   static const String KEY_PROPERTY_NAME = "property_name";
//   static const String KEY_PROPERTY_VALUE = "property_value";
//
//   @AcBindJsonProperty(key: AcDDTableColumnProperty.KEY_PROPERTY_NAME)
//   AcEnumDDColumnProperty propertyName = AcEnumDDColumnProperty.unknown;
//
//   @AcBindJsonProperty(key: AcDDTableColumnProperty.KEY_PROPERTY_VALUE)
//   dynamic propertyValue;
//
//   static AcDDTableColumnProperty instanceFromJson({required Map<String, dynamic> jsonData}) {
//     final instance = AcDDTableColumnProperty();
//     instance.fromJson(jsonData:jsonData);
//     return instance;
//   }
//
//   AcDDTableColumnProperty fromJson({required Map<String, dynamic> jsonData}) {
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
