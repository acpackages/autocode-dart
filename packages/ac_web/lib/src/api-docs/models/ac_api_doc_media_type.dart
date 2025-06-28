import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a specific media type within a request or response.",
  "description": "This class models the Media Type Object in an OpenAPI specification, providing the schema and examples for a single media type (e.g., 'application/json'). It is used to describe the payload of requests and responses.",
  "example": "final jsonMediaType = AcApiDocMediaType()\n  ..schema = [{\n    '\$ref': '#/components/schemas/User'\n  }];"
}) */
@AcReflectable()
class AcApiDocMediaType {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keySchema = 'schema';
  static const String keyExamples = 'examples';

  /* AcDoc({
    "summary": "The schema defining the data structure for this media type.",
    "description": "This can be a complete schema object or a reference to a reusable schema in the components section."
  }) */
  @AcBindJsonProperty(key: keySchema)
  List<dynamic>? schema;

  /* AcDoc({
    "summary": "Examples of the media type.",
    "description": "A map of examples, where each key is a name for the example and the value is an Example Object or a reference."
  }) */
  @AcBindJsonProperty(key: keyExamples)
  List<dynamic>? examples;

  /* AcDoc({"summary": "Creates a new, empty instance of a media type definition."}) */
  AcApiDocMediaType();

  /* AcDoc({
    "summary": "Creates a new AcApiDocMediaType instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the media type."}
    ],
    "returns": "A new, populated AcApiDocMediaType instance.",
    "returns_type": "AcApiDocMediaType"
  }) */
  factory AcApiDocMediaType.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocMediaType();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the media type properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocMediaType"
  }) */
  AcApiDocMediaType fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current media type instance to a JSON map.",
    "returns": "A JSON map representation of the media type.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the media type.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}