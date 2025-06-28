import 'dart:convert';
import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "Represents the Components Object in an OpenAPI specification.",
  "description": "This class is a container for various reusable definitions that can be referenced throughout the API documentation. This implementation focuses on the `schemas` component, which holds reusable data models (also known as component schemas).",
  "example": "final userSchema = AcApiDocSchema(type: 'object', properties: {...});\n\nfinal components = AcApiDocComponents()\n  ..schemas['User'] = userSchema;\n\nfinal apiDoc = AcApiDoc()\n  ..components = components; // This would be part of a full API doc"
}) */
@AcReflectable()
class AcApiDocComponents {
  // Renamed static const to follow lowerCamelCase Dart naming conventions.
  static const String keySchemas = 'schemas';

  /* AcDoc({
    "summary": "A map of reusable data schemas (models).",
    "description": "The key is the name of the schema (e.g., 'User', 'Product'), and the value is the `AcApiDocSchema` object defining its structure. These schemas can be referenced elsewhere in the API documentation."
  }) */
  Map<String, AcApiDocSchema> schemas = {};

  /* AcDoc({
    "summary": "Creates a new, empty instance of an API components object."
  }) */
  AcApiDocComponents();

  /* AcDoc({
    "summary": "Creates a new AcApiDocComponents instance from a JSON map.",
    "params": [
      {"name": "jsonData", "description": "The JSON map representing the components object."}
    ],
    "returns": "A new, populated AcApiDocComponents instance.",
    "returns_type": "AcApiDocComponents"
  }) */
  factory AcApiDocComponents.instanceFromJson({
    required Map<String, dynamic> jsonData,
  }) {
    final instance = AcApiDocComponents();
    return instance.fromJson(jsonData: jsonData);
  }

  /* AcDoc({
    "summary": "Populates the instance's properties from a JSON map.",
    "description": "This method manually deserializes the nested `schemas` map before using a reflection utility for any other potential properties.",
    "params": [
      {"name": "jsonData", "description": "The JSON map containing the components' properties."}
    ],
    "returns": "The current instance, allowing for a fluent interface.",
    "returns_type": "AcApiDocComponents"
  }) */
  AcApiDocComponents fromJson({Map<String, dynamic> jsonData = const {}}) {
    Map<String, dynamic> json = Map.from(jsonData);
    if (json.containsKey(keySchemas)) {
      final schemaData = json[keySchemas];
      if (schemaData is Map<String, dynamic>) {
        for (var entry in schemaData.entries) {
          schemas[entry.key] = AcApiDocSchema.instanceFromJson(
            jsonData: entry.value,
          );
        }
      }
      json.remove(keySchemas);
    }
    AcJsonUtils.setInstancePropertiesFromJsonData(
      instance: this,
      jsonData: json,
    );
    return this;
  }

  /* AcDoc({
    "summary": "Serializes the current components instance to a JSON map.",
    "description": "This method manually serializes the nested `schemas` map into the correct structure for an OpenAPI Components Object.",
    "returns": "A JSON map representation of the components object.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};

    if (schemas.isNotEmpty) {
      final schemaJson = <String, dynamic>{};
      for (var entry in schemas.entries) {
        final json = entry.value.toJson();
        if (json.isNotEmpty) {
          schemaJson[entry.key] = json;
        }
      }
      if (schemaJson.isNotEmpty) {
        result[keySchemas] = schemaJson;
      }
    }

    return result;
  }

  /* AcDoc({
    "summary": "Returns a pretty-printed JSON string representation of the components object.",
    "returns": "A formatted JSON string.",
    "returns_type": "String"
  }) */
  @override
  String toString() {
    // Standardized to use AcJsonUtils for consistency.
    return AcJsonUtils.prettyEncode(toJson());
  }
}