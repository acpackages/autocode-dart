import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents the license information for the exposed API.",
  "description": "This class models the License Object in an OpenAPI specification, providing the name of the license used for the API and a URL to the full license text.",
  "example": "final license = AcApiDocLicense()\n  ..name = 'MIT License'\n  ..url = 'https://opensource.org/licenses/MIT';"
}) */
@AcReflectable()
class AcApiDocLicense {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyName = "name";
  static const String keyUrl = "url";

  /* AcDoc({
    "summary": "The name of the license used (e.g., 'Apache 2.0', 'MIT License')."
  }) */
  @AcBindJsonProperty(key: keyName)
  String name = "";

  /* AcDoc({
    "summary": "A URL to the license used for the API.",
    "description": "This should point to the full text of the license."
  }) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({
    "summary": "Creates a new, empty instance of API license information."
  }) */
  AcApiDocLicense();

  /* AcDoc({
    "summary": "Creates a new AcApiDocLicense instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the license information."}
    ],
    "returns": "A new, populated AcApiDocLicense instance.",
    "returns_type": "AcApiDocLicense"
  }) */
  factory AcApiDocLicense.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocLicense();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the license properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocLicense"
  }) */
  AcApiDocLicense fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current license instance to a JSON map.",
    "returns": "A JSON map representation of the license information.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the license object.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}