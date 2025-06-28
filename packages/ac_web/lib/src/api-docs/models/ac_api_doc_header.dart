import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents the definition of a single HTTP header.",
  "description": "This class models the Header Object in an OpenAPI specification. It defines a single header that can be used in responses, including a description, a schema for the header's value, and flags for requirement and deprecation.",
  "example": "final rateLimitHeader = AcApiDocHeader()\n  ..description = 'The number of requests left for the time window.'\n  ..schema = {'type': 'integer'};\n\n// This would then be added to a response definition in the API documentation."
}) */
@AcReflectable()
class AcApiDocHeader {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDescription = 'description';
  static const String keyRequired = 'required';
  static const String keyDeprecated = 'deprecated';
  static const String keySchema = 'schema';

  /* AcDoc({"summary": "A detailed description of the header."}) */
  @AcBindJsonProperty(key: keyDescription)
  String description = '';

  /* AcDoc({
    "summary": "Determines whether this header is required to be present.",
    "description": "This field is not currently supported by the OpenAPI specification for response headers, but is included for completeness."
  }) */
  @AcBindJsonProperty(key: keyRequired)
  bool required = false;

  /* AcDoc({"summary": "Specifies that the header is deprecated and should be transitioned out of usage."}) */
  @AcBindJsonProperty(key: keyDeprecated)
  bool deprecated = false;

  /* AcDoc({
    "summary": "The schema defining the data type and format of the header's value."
  }) */
  @AcBindJsonProperty(key: keySchema)
  Map<String, dynamic> schema = {};

  /* AcDoc({"summary": "Creates a new, empty instance of an API header definition."}) */
  AcApiDocHeader();

  /* AcDoc({
    "summary": "Creates a new AcApiDocHeader instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the header definition."}
    ],
    "returns": "A new, populated AcApiDocHeader instance.",
    "returns_type": "AcApiDocHeader"
  }) */
  factory AcApiDocHeader.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocHeader();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the header's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocHeader"
  }) */
  AcApiDocHeader fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current header definition instance to a JSON map.",
    "returns": "A JSON map representation of the header definition.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the header definition.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}