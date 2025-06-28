import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents a single response from an API operation.",
  "description": "This class models the Response Object in an OpenAPI specification. It defines a single possible response for an operation, including its description, headers, and content payloads for different media types. An operation will typically have a map of these objects, keyed by HTTP status code (e.g., '200', '404').",
  "example": "final successResponse = AcApiDocResponse(description: 'The requested resource.')\n  ..headers = {\n    'X-Rate-Limit-Remaining': AcApiDocHeader(description: 'Remaining requests')\n  }\n  ..content = {\n    'application/json': AcApiDocContent(schema: {'\$ref': '#/components/schemas/User'})\n  };"
}) */
@AcReflectable()
class AcApiDocResponse {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyCode = 'code';
  static const String keyDescription = 'description';
  static const String keyHeaders = 'headers';
  static const String keyContent = 'content';
  static const String keyLinks = 'links';

  /* AcDoc({
    "summary": "The HTTP status code of the response.",
    "description": "This property is not part of the standard OpenAPI Response Object itself, but is used by the framework. The actual status code is the key in the parent 'Responses Object'."
  }) */
  @AcBindJsonProperty(key: keyCode)
  AcEnumHttpResponseCode code = AcEnumHttpResponseCode.notFound;

  /* AcDoc({"summary": "A required, short description of the response."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = '';

  /* AcDoc({
    "summary": "A map of headers that can be sent with the response.",
    "description": "The key is the name of the header and the value is an `AcApiDocHeader` object defining it."
  }) */
  @AcBindJsonProperty(key: keyHeaders)
  Map<String, AcApiDocHeader> headers = {};

  /* AcDoc({
    "summary": "A map of media types and their schemas for the response payload.",
    "description": "The key is the media type (e.g., 'application/json') and the value is an `AcApiDocContent` object describing the payload's structure."
  }) */
  @AcBindJsonProperty(key: keyContent)
  Map<String, AcApiDocContent> content = {};

  /* AcDoc({
    "summary": "A map of possible links that can be followed from this response.",
    "description": "Defines relationships between this response and other API operations."
  }) */
  @AcBindJsonProperty(key: keyLinks)
  Map<String, AcApiDocLink> links = {};

  /* AcDoc({
    "summary": "Creates a new, empty instance of an API response definition.",
    "params": [
      {"name": "description", "description": "An optional, short description of the response."}
    ]
  }) */
  AcApiDocResponse({this.description = ''});

  /* AcDoc({
    "summary": "Creates a new AcApiDocResponse instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the response."}
    ],
    "returns": "A new, populated AcApiDocResponse instance.",
    "returns_type": "AcApiDocResponse"
  }) */
  factory AcApiDocResponse.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocResponse();
    return instance.fromJson(jsonData: jsonData);
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
      this.content[this.content.length.toString()] = content;
    }
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested maps for `content`, `headers`, and `links` before using a reflection utility for any other properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the response's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocResponse"
  }) */
  AcApiDocResponse fromJson({required Map<String, dynamic> jsonData}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyContent)) {
      final contentMap = json[keyContent] as Map<String, dynamic>;
      contentMap.forEach((mime, contentJson) {
        content[mime] = AcApiDocContent.instanceFromJson(jsonData: contentJson);
      });
      json.remove(keyContent);
    }

    if (json.containsKey(keyHeaders)) {
      final headersMap = json[keyHeaders] as Map<String, dynamic>;
      headersMap.forEach((headerName, headerJson) {
        headers[headerName] = AcApiDocHeader.instanceFromJson(
          jsonData: headerJson,
        );
      });
      json.remove(keyHeaders);
    }

    if (json.containsKey(keyLinks)) {
      final linksMap = json[keyLinks] as Map<String, dynamic>;
      linksMap.forEach((linkName, linkJson) {
        links[linkName] = AcApiDocLink.instanceFromJson(jsonData: linkJson);
      });
      json.remove(keyLinks);
    }

    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current response definition to a JSON map.",
    "description": "This method manually serializes its properties, including nested objects, into the correct structure for an OpenAPI Response Object.",
    "returns": "A JSON map representation of the response definition.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result[keyDescription] = description;

    if (headers.isNotEmpty) {
      result[keyHeaders] = headers.map((key, value) => MapEntry(key, value.toJson()));
    }
    if (content.isNotEmpty) {
      result[keyContent] = content.map((key, value) => MapEntry(key, value.toJson()));
    }
    if (links.isNotEmpty) {
      result[keyLinks] = links.map((key, value) => MapEntry(key, value.toJson()));
    }

    return result;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the response definition.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}