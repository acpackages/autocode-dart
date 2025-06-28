import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a link to external API documentation.",
  "description": "This class models the External Documentation Object in an OpenAPI specification, which allows referencing an external resource for extended documentation, such as a developer guide, wiki, or tutorial.",
  "example": "final externalDocs = AcApiDocExternalDocs()\n  ..description = 'Find more info here'\n  ..url = 'https://docs.example.com';"
}) */
@AcReflectable()
class AcApiDocExternalDocs {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDescription = "description";
  static const String keyUrl = "url";

  /* AcDoc({"summary": "A description of the external documentation."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = "";

  /* AcDoc({"summary": "The URL for the external documentation."}) */
  @AcBindJsonProperty(key: keyUrl)
  String url = "";

  /* AcDoc({"summary": "Creates a new, empty instance of an external documentation link."}) */
  AcApiDocExternalDocs();

  /* AcDoc({
    "summary": "Creates a new AcApiDocExternalDocs instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the external documentation link."}
    ],
    "returns": "A new, populated AcApiDocExternalDocs instance.",
    "returns_type": "AcApiDocExternalDocs"
  }) */
  factory AcApiDocExternalDocs.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocExternalDocs();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocExternalDocs"
  }) */
  AcApiDocExternalDocs fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current instance to a JSON map.",
    "returns": "A JSON map representation of the external documentation link.",
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
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}