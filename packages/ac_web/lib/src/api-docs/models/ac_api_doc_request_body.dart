import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents the request body for an API operation.",
  "description": "This class models the Request Body Object in an OpenAPI specification. It describes the payload of a request, including its description, whether it's required, and a map of media types (like 'application/json') to their specific content definitions.",
  "example": "final requestBody = AcApiDocRequestBody()\n  ..description = 'User object to be created.'\n  ..required = true\n  ..content = {\n    'application/json': AcApiDocContent(\n      schema: { '\$ref': '#/components/schemas/User' }\n    )\n  };"
}) */
@AcReflectable()
class AcApiDocRequestBody {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDescription = 'description';
  static const String keyContent = 'content';
  static const String keyRequired = 'required';

  /* AcDoc({"summary": "A brief description of the request body."}) */
  @AcBindJsonProperty(key: keyDescription)
  String? description = "";

  /* AcDoc({
    "summary": "The content of the request body.",
    "description": "A map where the key is the media type (e.g., 'application/json') and the value is an `AcApiDocContent` object describing the schema and examples for that media type."
  }) */
  @AcBindJsonProperty(key: keyContent)
  Map<String, AcApiDocContent> content = {};

  /* AcDoc({"summary": "Determines if the request body is required for the operation."}) */
  @AcBindJsonProperty(key: keyRequired)
  bool required = false;

  /* AcDoc({"summary": "Creates a new, empty instance of an API request body definition."}) */
  AcApiDocRequestBody();

  /* AcDoc({
    "summary": "Creates a new AcApiDocRequestBody instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the request body."}
    ],
    "returns": "A new, populated AcApiDocRequestBody instance.",
    "returns_type": "AcApiDocRequestBody"
  }) */
  factory AcApiDocRequestBody.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocRequestBody();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested `content` map before using a reflection utility for any other properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the request body properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocRequestBody"
  }) */
  AcApiDocRequestBody fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyContent)) {
      final contentMap = json[keyContent] as Map<String, dynamic>;
      contentMap.forEach((mime, contentJson) {
        content[mime] = AcApiDocContent.instanceFromJson(jsonData: contentJson);
      });
      json.remove(keyContent);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Adds a content definition for a specific media type.",
    "description": "Note: This implementation uses the content's `encoding` property as the key in the map, which typically should be a media type like 'application/json'.",
    "params": [
      {"name": "content", "description": "The `AcApiDocContent` object to add."}
    ]
  }) */
  void addContent({required AcApiDocContent content}) {
    // The key for the content map in OpenAPI is the media type (e.g., 'application/json').
    // This implementation uses the `encoding` field as the key.
    if (content.encoding.isNotEmpty) {
      this.content[content.encoding] = content;
    } else {
      // Fallback to a numeric key is non-standard for OpenAPI.
      this.content[this.content.length.toString()] = content;
    }
  }

  /* AcDoc({
    "summary": "Serializes the current request body instance to a JSON map.",
    "description": "This method manually serializes its properties into the correct structure for an OpenAPI Request Body Object.",
    "returns": "A JSON map representation of the request body.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (description != null && description!.isNotEmpty) {
      result[keyDescription] = description;
    }
    if (required) {
      result[keyRequired] = required;
    }
    if (content.isNotEmpty) {
      final contentJson = <String, dynamic>{};
      content.forEach((encoding, contentItem) {
        contentJson[encoding] = contentItem.toJson();
      });
      result[keyContent] = contentJson;
    }
    return result;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the request body.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}