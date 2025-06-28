import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "A generator for creating an OpenAPI 3.0 specification from an `AcApiDoc` object.",
  "description": "This class takes a structured `AcApiDoc` instance, which represents the entire API, and transforms it into a JSON map that conforms to the OpenAPI 3.0 standard. This JSON can then be served to Swagger UI or other OpenAPI-compatible tools.",
  "example": "final apiDoc = AcApiDoc(title: 'My API', version: '1.0');\n// ... populate apiDoc with paths, models, etc. ...\n\nfinal swaggerGenerator = AcApiSwagger()..acApiDoc = apiDoc;\nfinal openApiJson = swaggerGenerator.generateJson();\n\n// Serve `openApiJson` at a '/swagger.json' endpoint."
}) */
class AcApiSwagger {
  /* AcDoc({"summary": "The master API documentation object to be converted into an OpenAPI specification."}) */
  late AcApiDoc acApiDoc;

  /* AcDoc({"summary": "Creates a new instance of the OpenAPI specification generator."}) */
  AcApiSwagger();

  /* AcDoc({
    "summary": "A placeholder for future initialization logic.",
    "description": "This method is reserved for any setup or initialization logic that may be required before generating the specification."
  }) */
  void initialize(dynamic method, List<dynamic> args) {
    // Placeholder for future init logic
  }

  /* AcDoc({
    "summary": "Generates the complete OpenAPI 3.0 specification as a JSON map.",
    "description": "This method orchestrates the transformation of the `acApiDoc` object into a valid OpenAPI JSON structure by assembling the servers, paths, components (schemas), and tags.",
    "returns": "A `Map<String, dynamic>` representing the full OpenAPI specification.",
    "returns_type": "Map<String, dynamic>"
  }) */
  Map<String, dynamic> generateJson() {
    final result = <String, dynamic>{
      'openapi': '3.0.4',
      'components': {'schemas': <String, dynamic>{}},
    };

    final docsJson = acApiDoc.toJson();

    // Assumes constants from other files have been refactored to lowerCamelCase
    if (docsJson.containsKey(AcApiDoc.keyServers)) {
      final servers = docsJson[AcApiDoc.keyServers];
      if (servers is List && servers.isNotEmpty) {
        result['servers'] = servers;
      }
    }

    if (docsJson.containsKey(AcApiDoc.keyModels)) {
      Map<String, dynamic> models = Map.from(docsJson[AcApiDoc.keyModels]);
      if (models.isNotEmpty) {
        for (var model in models.values) {
          result['components']['schemas'][model[AcApiDocModel.keyName]] = {
            'properties': model[AcApiDocModel.keyProperties],
          };
        }
      }
    }

    if (docsJson.containsKey(AcApiDoc.keyPaths)) {
      final paths = docsJson[AcApiDoc.keyPaths];
      if (paths is List && paths.isNotEmpty) {
        result['paths'] = <String, dynamic>{};
        for (var path in paths) {
          final pathDetails = Map<String, dynamic>.from(path);
          pathDetails.remove(AcApiDocPath.keyUrl);
          result['paths'][path[AcApiDocPath.keyUrl]] = pathDetails;
        }
      }
    }

    if (docsJson.containsKey(AcApiDoc.keyTags)) {
      final tags = docsJson[AcApiDoc.keyTags];
      if (tags is List && tags.isNotEmpty) {
        result['tags'] = tags;
      }
    }

    return result;
  }

  /* AcDoc({
    "summary": "Recursively generates a JSON schema for a Dart class using reflection.",
    "description": "This utility method uses the `ac_mirrors` package to inspect a Dart class at runtime and generate a corresponding OpenAPI Schema Object. It handles primitive types and recursively calls itself for nested classes. Note: This relies on a reflection mechanism which may have platform limitations (e.g., not supported in AOT-compiled Flutter without build-time code generation).",
    "params": [
      {"name": "classType", "description": "The `Type` of the Dart class to generate a schema for."},
      {"name": "components", "description": "The master map of all component schemas, used to avoid circular dependencies and create references (`\$ref`)."}
    ],
    "returns": "A JSON map representing the schema, often as a reference (`\$ref`) to the main components section.",
    "returns_type": "Map<String, dynamic>"
  }) */
  static Map<String, dynamic> generateModelSchema({
    required Type classType,
    required Map<String, dynamic> components,
  }) {
    // 1. Use ac_mirrors to get the class mirror
    final classMirror = acReflectClass(classType);
    final className = classMirror.getName();

    if (components.containsKey(className)) {
      return {
        '\$ref': '#/components/schemas/$className',
      };
    }

    final schemaName = className;
    final schema = <String, dynamic>{
      'type': 'object',
      'title': schemaName,
      'properties': <String, dynamic>{},
    };

    // 2. Iterate over instance members provided by ac_mirrors.
    for (var decl in classMirror.instanceMembers.values) {
      // 3. We are only interested in fields (AcVariableMirror).
      if (decl is AcVariableMirror) {
        final propName = decl.getName();
        final propType = decl.type;
        final propSchema = <String, dynamic>{};

        // 4. Get the type's name as a string for the switch statement.
        final typeName = propType.toString();

        // Map Dart types to JSON Schema
        switch (typeName) {
          case 'int':
            propSchema['type'] = 'integer';
            break;
          case 'double':
          case 'num':
            propSchema['type'] = 'number';
            break;
          case 'bool':
            propSchema['type'] = 'boolean';
            break;
          case 'List':
            propSchema['type'] = 'array';
            propSchema['items'] = {'type': 'object'}; // generic items
            break;
          case 'String':
          default:
          // For other types, assume it's a nested model.
            try {
              propSchema.addAll(generateModelSchema(classType: propType, components: components));
            } catch (e) {
              // If it's not a reflectable class, treat it as a string.
              propSchema['type'] = 'string';
            }
            break;
        }

        schema['properties']![propName] = propSchema;
      }
    }

    components[className] = schema;

    return {'\$ref': '#/components/schemas/$schemaName'};
  }
}