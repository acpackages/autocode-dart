import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a single parameter for an API operation.",
  "description": "This class models the Parameter Object in an OpenAPI specification. It defines a single parameter that an operation accepts, including its name, location (e.g., 'query', 'path'), whether it is required, and its data schema.",
  "example": "// Defines a required 'userId' path parameter.\nfinal idParam = AcApiDocParameter(\n  name: 'userId',\n  inValue: 'path',\n  required: true,\n  description: 'ID of the user to fetch',\n  schema: {'type': 'integer', 'format': 'int64'}\n);"
}) */
@AcReflectable()
class AcApiDocParameter {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyDescription = "description";
  static const String keyExplode = "explode";
  static const String keyIn = "in";
  static const String keyName = "name";
  static const String keyRequired = "required";
  static const String keySchema = "schema";

  /* AcDoc({"summary": "A verbose explanation of the parameter."}) */
  @AcBindJsonProperty(key: keyDescription)
  String? description;

  /* AcDoc({
    "summary": "The location of the parameter.",
    "description": "Common values are 'query', 'header', 'path', or 'cookie'."
  }) */
  @AcBindJsonProperty(key: keyIn)
  String? in_;

  /* AcDoc({"summary": "The name of the parameter."}) */
  @AcBindJsonProperty(key: keyName)
  String? name;

  /* AcDoc({"summary": "Determines whether this parameter is mandatory."}) */
  @AcBindJsonProperty(key: keyRequired)
  bool required = false;

  /* AcDoc({
    "summary": "Specifies how array/object parameters are serialized.",
    "description": "When true, array or object values generate separate parameters for each value/property. Used for 'query' and 'cookie' parameters."
  }) */
  @AcBindJsonProperty(key: keyExplode)
  bool explode = true;

  /* AcDoc({"summary": "The schema defining the type of the parameter."}) */
  @AcBindJsonProperty(key: keySchema)
  Map<String, dynamic>? schema;

  /* AcDoc({
    "summary": "Creates a new instance of an API parameter definition.",
    "params": [
      {"name": "name", "description": "The name of the parameter."},
      {"name": "inValue", "description": "The location of the parameter (e.g., 'path', 'query')."},
      {"name": "required", "description": "Whether the parameter is required. Defaults to false."}
    ]
  }) */
  AcApiDocParameter({this.name, this.in_, this.required = false});

  /* AcDoc({
    "summary": "Creates a new AcApiDocParameter instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the parameter."}
    ],
    "returns": "A new, populated AcApiDocParameter instance.",
    "returns_type": "AcApiDocParameter"
  }) */
  factory AcApiDocParameter.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocParameter();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the `in` property (mapped to `inValue`) before using a reflection utility for the remaining properties, as `in` is a reserved keyword in Dart.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the parameter's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocParameter"
  }) */
  AcApiDocParameter fromJson({required Map<String, dynamic> jsonData}) {
    Map<String,dynamic> json = Map.from(jsonData);
    if (json.containsKey(keyIn)) {
      in_ = json[keyIn] as String?;
      json.remove(keyIn);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: json);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current parameter instance to a JSON map.",
    "description": "This method manually serializes the `inValue` property to the `in` key to conform to the OpenAPI specification, as `in` is a reserved keyword in Dart.",
    "returns": "A JSON map representation of the parameter.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    final json = AcJsonUtils.getJsonDataFromInstance(instance: this);
    if (in_ != null) {
      json[keyIn] = in_;
    }
    return json;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the parameter.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}