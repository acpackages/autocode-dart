import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';

/* AcDoc({
  "summary": "Represents a reusable data model (schema) in an API specification.",
  "description": "This class models a Schema Object in an OpenAPI specification, which defines the structure of data models used in the API (e.g., for request and response bodies). It includes a name (used for referencing), a type (usually 'object'), and a map of its properties.",
  "example": "final userModel = AcApiDocModel()\n  ..name = 'User'\n  ..type = 'object'\n  ..properties = {\n    'id': AcApiDocSchema(type: 'integer', format: 'int64'),\n    'name': AcApiDocSchema(type: 'string'),\n    'email': AcApiDocSchema(type: 'string', format: 'email')\n  };"
}) */
@AcReflectable()
class AcApiDocModel {
  // Renamed static consts to follow lowerCamelCase Dart naming conventions.
  static const String keyName = 'name';
  static const String keyType = 'type';
  static const String keyProperties = 'properties';

  /* AcDoc({
    "summary": "The name of the model, used for referencing from other parts of the specification."
  }) */
  @AcBindJsonProperty(key: keyName)
  String name = '';

  /* AcDoc({
    "summary": "The data type of the model, typically 'object' for complex models."
  }) */
  @AcBindJsonProperty(key: keyType)
  String type = 'object';

  /* AcDoc({
    "summary": "A map defining the properties of this model.",
    "description": "The keys are the property names (e.g., 'id', 'name'), and the values are `AcApiDocSchema` objects that define the type and format of each property."
  }) */
  @AcBindJsonProperty(key: keyProperties)
  Map<String, dynamic> properties = {};

  /* AcDoc({"summary": "Creates a new, empty instance of an API data model."}) */
  AcApiDocModel();

  /* AcDoc({
    "summary": "Creates a new AcApiDocModel instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the data model."}
    ],
    "returns": "A new, populated AcApiDocModel instance.",
    "returns_type": "AcApiDocModel"
  }) */
  factory AcApiDocModel.instanceFromJson({required Map<String, dynamic> jsonData}) {
    final instance = AcApiDocModel();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "An instance method that uses reflection-based utilities to set the properties of this object from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the model's properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocModel"
  }) */
  AcApiDocModel fromJson({required Map<String, dynamic> jsonData}) {
    AcJsonUtils.setInstancePropertiesFromJsonData(instance: this, jsonData: jsonData);
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current model instance to a JSON map.",
    "returns": "A JSON map representation of the data model.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    return AcJsonUtils.getJsonDataFromInstance(instance: this);
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the data model.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}