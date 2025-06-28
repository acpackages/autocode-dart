import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents a tag for grouping API operations.",
  "description": "This class models the Tag Object in an OpenAPI specification. Tags are used to group related API endpoints together in documentation UIs like Swagger UI, making the API easier to navigate.",
  "example": "final userTag = AcApiDocTag(\n  name: 'Users',\n  description: 'Operations related to user management'\n);"
}) */
@AcReflectable()
class AcApiDocTag {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyName = "name";
  static const String keyDescription = "description";
  static const String keyExternalDocs = "externalDocs";

  /* AcDoc({"summary": "The name of the tag."}) */
  @AcBindJsonProperty(key: keyName)
  String name = "";

  /* AcDoc({"summary": "A short description for the tag."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = "";

  /* AcDoc({"summary": "A link to external documentation for this tag."}) */
  @AcBindJsonProperty(key: keyExternalDocs)
  late AcApiDocExternalDocs externalDocs;

  /* AcDoc({
    "summary": "Creates a new instance of an API documentation tag.",
    "params": [
      {"name": "name", "description": "The name of the tag."},
      {"name": "description", "description": "A description for the tag."}
    ]
  }) */
  AcApiDocTag({this.name = '', this.description = ''}) {
    externalDocs = AcApiDocExternalDocs();
  }

  /* AcDoc({
    "summary": "Creates a new AcApiDocTag instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the tag."}
    ],
    "returns": "A new, populated AcApiDocTag instance.",
    "returns_type": "AcApiDocTag"
  }) */
  factory AcApiDocTag.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocTag();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the tag's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocTag"
  }) */
  AcApiDocTag fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: jsonData,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current tag instance to a JSON map.",
    "returns": "A JSON map representation of the tag.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the tag.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}