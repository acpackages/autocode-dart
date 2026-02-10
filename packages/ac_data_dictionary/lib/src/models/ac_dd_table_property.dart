import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a single property of a database table.",
  "description": "This class models a key-value pair that defines a specific metadata attribute for a table, such as 'pluralName' or 'singularName'. The `propertyName` is an enum (`AcEnumDDTableProperty`) and `propertyValue` is dynamic.",
  "example": "// Example of a 'pluralName' property for a 'user' table.\nfinal pluralNameProp = AcDDTableProperty.instanceFromJson(jsonData: {\n  'property_name': 'pluralName',\n  'property_value': 'Users'\n});"
}) */
@AcReflectable()
class AcDDTableProperty {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyPropertyName = "propertyName";
  static const String keyPropertyValue = "propertyValue";

  /* AcDoc({
    "summary": "The name of the table property.",
    "description": "An enum value that identifies the specific property, such as `pluralName` or `singularName`."
  }) */
  @AcBindJsonProperty(key: keyPropertyName)
  AcEnumDDTableProperty propertyName = AcEnumDDTableProperty.unknown;

  /* AcDoc({
    "summary": "The value associated with the property.",
    "description": "The type of this value is dynamic but is typically a string (e.g., 'Users' for a `pluralName` property)."
  }) */
  @AcBindJsonProperty(key: keyPropertyValue)
  dynamic propertyValue;

  /* AcDoc({
    "summary": "Creates a new, empty instance of a table property."
  }) */
  AcDDTableProperty();

  /* AcDoc({
    "summary": "Creates a new AcDDTableProperty instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the table property."}
    ],
    "returns": "A new, populated AcDDTableProperty instance.",
    "returns_type": "AcDDTableProperty"
  }) */
  factory AcDDTableProperty.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcDDTableProperty();
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
    "returns_type": "AcDDTableProperty"
  }) */
  AcDDTableProperty fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current table property instance to a JSON map.",
    "returns": "A JSON map representation of the table property.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the table property.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    return AcJsonUtils.prettyEncode(toJson());
  }
}
