import 'dart:mirrors';
import 'package:ac_web/ac_web.dart';

class AcApiSwagger {
  late AcApiDoc acApiDoc;

  AcApiSwagger();

  void initialize(dynamic method, List<dynamic> args) {
    // placeholder for future init logic
  }

  Map<String, dynamic> generateJson() {
    final result = <String, dynamic>{
      'openapi': '3.0.4',
      'components': {'schemas': <String, dynamic>{}},
    };

    final docsJson = acApiDoc.toJson();

    if (docsJson.containsKey(AcApiDoc.KEY_SERVERS)) {
      final servers = docsJson[AcApiDoc.KEY_SERVERS];
      if (servers is List && servers.isNotEmpty) {
        result['servers'] = servers;
      }
    }

    if (docsJson.containsKey(AcApiDoc.KEY_MODELS)) {
      Map<String, dynamic> models = Map.from(docsJson[AcApiDoc.KEY_MODELS]);
      if (models.isNotEmpty) {
        for (var model in models.values) {
          print(model);
          result['components']['schemas'][model[AcApiDocModel.KEY_NAME]] = {
            'properties': model[AcApiDocModel.KEY_PROPERTIES],
          };
        }
      }
    }

    if (docsJson.containsKey(AcApiDoc.KEY_PATHS)) {
      final paths = docsJson[AcApiDoc.KEY_PATHS];
      if (paths is List && paths.isNotEmpty) {
        result['paths'] = <String, dynamic>{};
        for (var path in paths) {
          final pathDetails = Map<String, dynamic>.from(path);
          pathDetails.remove(AcApiDocPath.KEY_URL);
          result['paths'][path[AcApiDocPath.KEY_URL]] = pathDetails;
        }
      }
    }

    if (docsJson.containsKey(AcApiDoc.KEY_TAGS)) {
      final tags = docsJson[AcApiDoc.KEY_TAGS];
      if (tags is List && tags.isNotEmpty) {
        result['tags'] = tags;
      }
    }

    return result;
  }

  /// Recursively generate JSON schema for a Dart class.
  ///
  /// Note: Dart runtime reflection is limited, so this is a simplified
  /// version that relies on mirrors (which is unsupported in Flutter),
  /// or you may replace it with your own manual schema definitions.
  static Map<String, dynamic> generateModelSchema({
    required Type classType,
    required Map<String, dynamic> components,
  }) {
    final className = classType.toString();

    if (components.containsKey(className)) {
      return {
        '\$ref': '#/components/schemas/${components[className]['title']}',
      };
    }

    final schemaName = className;
    final schema = <String, dynamic>{
      'type': 'object',
      'title': schemaName,
      'properties': <String, dynamic>{},
    };

    // Reflection - Use mirrors for runtime property inspection (not supported everywhere)
    final classMirror = reflectClass(classType);
    final instanceMirror = reflect(classMirror.newInstance(Symbol(''), []));

    // Get public instance variables (this might need custom annotation or metadata)
    for (var decl in classMirror.declarations.values) {
      if (decl is VariableMirror && !decl.isStatic) {
        final propName = MirrorSystem.getName(decl.simpleName);
        final propTypeMirror = decl.type;

        final propSchema = <String, dynamic>{};
        final typeName = MirrorSystem.getName(propTypeMirror.simpleName);

        // Map Dart types to JSON Schema
        switch (typeName) {
          case 'int':
            propSchema['type'] = 'integer';
            break;
          case 'double':
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
            propSchema['type'] = 'string';
            break;
        }

        // Nullable - Dart types are nullable by default or via ?
        // You may want to add a convention to detect this if needed.

        // Defaults not available via reflection in Dart easily

        schema['properties'][propName] = propSchema;
      }
    }

    components[className] = schema;

    return {'\$ref': '#/components/schemas/$schemaName'};
  }
}
