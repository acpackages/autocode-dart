import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents the definition for a specific media type in a request or response.",
  "description": "This class models the Media Type Object in an OpenAPI specification. It provides a schema for the data payload and can include example payloads for a given content type (e.g., `application/json`).",
  "example": "final userContent = AcApiDocContent(\n  schema: { '\$ref': '#/components/schemas/User' },\n  examples: {\n    'example1': {\n      'summary': 'A sample user',\n      'value': { 'id': 1, 'name': 'John Doe' }\n    }\n  }\n);"
}) */
@AcReflectable()
class AcApiDocContent {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keySchema = 'schema';
  static const String keyExamples = 'examples';
  static const String keyEncoding = 'encoding';

  /* AcDoc({
    "summary": "The schema defining the data structure for this media type.",
    "description": "This can be a complete schema object or a reference to a reusable schema in the components section (e.g., { '\$ref': '#/components/schemas/User' })."
  }) */
  @AcBindJsonProperty(key: keySchema)
  Map<String, dynamic> schema = {};

  /* AcDoc({
    "summary": "Examples of the media type.",
    "description": "A map of examples, where each key is a name for the example and the value is an Example Object or a reference."
  }) */
  @AcBindJsonProperty(key: keyExamples)
  Map<String, dynamic> examples = {};

  /* AcDoc({
    "summary": "The encoding for the media type.",
    "description": "A map of encoding objects for more complex serialization scenarios, typically used with `multipart/form-data`."
  }) */
  @AcBindJsonProperty(key: keyEncoding)
  String encoding = "";

  /* AcDoc({
    "summary": "Creates a new instance of an API content definition.",
    "params": [
      {"name": "encoding", "description": "The encoding for the media type."},
      {"name": "schema", "description": "The schema defining the data structure."},
      {"name": "examples", "description": "A map of examples for this content type."}
    ]
  }) */
  AcApiDocContent({
    this.encoding = "",
    this.schema = const {},
    this.examples = const {},
  });

  /* AcDoc({
    "summary": "Creates a new AcApiDocContent instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the content definition."}
    ],
    "returns": "A new, populated AcApiDocContent instance.",
    "returns_type": "AcApiDocContent"
  }) */
  factory AcApiDocContent.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocContent();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the content properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocContent"
  }) */
  AcApiDocContent fromJson({Map<String, dynamic> jsonData = const {}}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current content definition instance to a JSON map.",
    "returns": "A JSON map representation of the content definition.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the content definition.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}