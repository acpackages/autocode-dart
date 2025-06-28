import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a data schema definition in an OpenAPI specification.",
  "description": "This class models the Schema Object, which is used to define the structure of data types. It can describe primitive types (like string, integer), arrays, and complex objects with properties. It is one of the most fundamental components of an API documentation, used in parameters, request bodies, and responses.",
  "example": "// Example of a simple string schema with a format.\nfinal emailSchema = AcApiDocSchema(type: 'string', format: 'email');\n\n// Example of a complex object schema.\nfinal userSchema = AcApiDocSchema(\n  type: 'object',\n  properties: {\n    'id': AcApiDocSchema(type: 'integer'),\n    'name': AcApiDocSchema(type: 'string')\n  },\n  required: ['id', 'name']\n);"
}) */
@AcReflectable()
class AcApiDocSchema {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyType = 'type';
  static const String keyFormat = 'format';
  static const String keyTitle = 'title';
  static const String keyDescription = 'description';
  static const String keyProperties = 'properties';
  static const String keyRequired = 'required';
  static const String keyItems = 'items';
  static const String keyEnum = 'enum';

  /* AcDoc({
    "summary": "The data type of the schema (e.g., 'string', 'integer', 'object', 'array')."
  }) */
  @AcBindJsonProperty(key: keyType)
  String? type;

  /* AcDoc({
    "summary": "The specific format of the data type (e.g., 'date-time', 'email', 'int64')."
  }) */
  @AcBindJsonProperty(key: keyFormat)
  String? format;

  /* AcDoc({"summary": "The title of the schema."}) */
  @AcBindJsonProperty(key: keyTitle)
  String? title;

  /* AcDoc({"summary": "A detailed description of the schema."}) */
  @AcBindJsonProperty(key: keyDescription)
  String? description;

  /* AcDoc({
    "summary": "A map of properties for an object schema.",
    "description": "Used when `type` is 'object'. The key is the property name, and the value is another `AcApiDocSchema` defining that property's type."
  }) */
  @AcBindJsonProperty(key: keyProperties)
  Map<String, dynamic>? properties;

  /* AcDoc({
    "summary": "A list of required property names for an object schema."
  }) */
  @AcBindJsonProperty(key: keyRequired)
  List<String>? required;

  /* AcDoc({
    "summary": "The schema for items in an array.",
    "description": "Used when `type` is 'array'. The value is an `AcApiDocSchema` that defines the type of each element in the array."
  }) */
  @AcBindJsonProperty(key: keyItems)
  dynamic items;

  /* AcDoc({
    "summary": "A list of possible values for the schema.",
    "description": "Restricts the value to a fixed set of options. The field is named `enumValues` to avoid conflict with the 'enum' keyword in Dart, but serializes to the 'enum' key in JSON."
  }) */
  @AcBindJsonProperty(key: keyEnum)
  List<dynamic>? enumValues;

  /* AcDoc({
    "summary": "Creates a new instance of an API schema definition.",
    "params": [
      {"name": "type", "description": "The data type of the schema."},
      {"name": "format", "description": "The specific format of the data type."},
      {"name": "title", "description": "The title of the schema."},
      {"name": "description", "description": "A description of the schema."},
      {"name": "properties", "description": "A map of properties for an object schema."},
      {"name": "required", "description": "A list of required property names."},
      {"name": "items", "description": "The schema for items if the type is 'array'."},
      {"name": "enumValues", "description": "A list of possible values."}
    ]
  }) */
  AcApiDocSchema({
    this.type,
    this.format,
    this.title,
    this.description,
    this.properties,
    this.required,
    this.items,
    this.enumValues,
  });

  /* AcDoc({
    "summary": "Creates a new AcApiDocSchema instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the schema."}
    ],
    "returns": "A new, populated AcApiDocSchema instance.",
    "returns_type": "AcApiDocSchema"
  }) */
  factory AcApiDocSchema.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocSchema();
    return instance.fromJson(jsonData:jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the schema's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocSchema"
  }) */
  AcApiDocSchema fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current schema instance to a JSON map.",
    "returns": "A JSON map representation of the schema.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the schema.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}