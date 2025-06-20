import 'package:ac_mirrors/ac_mirrors.dart';
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
    // 1. Use ac_mirrors to get the class mirror
    final classMirror = acReflectClass(classType);
    final className = classMirror.getName();

    if (components.containsKey(className)) {
      return {
        // The title of the schema is the class name.
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
          // This requires the nested model to also be reflectable.
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
  // static Map<String, dynamic> generateModelSchema({
  //   required Type classType,
  //   required Map<String, dynamic> components,
  // }) {
  //   final className = classType.toString();
  //
  //   if (components.containsKey(className)) {
  //     return {
  //       '\$ref': '#/components/schemas/${components[className]['title']}',
  //     };
  //   }
  //
  //   final schemaName = className;
  //   final schema = <String, dynamic>{
  //     'type': 'object',
  //     'title': schemaName,
  //     'properties': <String, dynamic>{},
  //   };
  //
  //   // Reflection - Use mirrors for runtime property inspection (not supported everywhere)
  //   final classMirror = reflectClass(classType);
  //   final instanceMirror = reflect(classMirror.newInstance(Symbol(''), []));
  //
  //   // Get public instance variables (this might need custom annotation or metadata)
  //   for (var decl in classMirror.declarations.values) {
  //     if (decl is VariableMirror && !decl.isStatic) {
  //       final propName = MirrorSystem.getName(decl.simpleName);
  //       final propTypeMirror = decl.type;
  //
  //       final propSchema = <String, dynamic>{};
  //       final typeName = MirrorSystem.getName(propTypeMirror.simpleName);
  //
  //       // Map Dart types to JSON Schema
  //       switch (typeName) {
  //         case 'int':
  //           propSchema['type'] = 'integer';
  //           break;
  //         case 'double':
  //           propSchema['type'] = 'number';
  //           break;
  //         case 'bool':
  //           propSchema['type'] = 'boolean';
  //           break;
  //         case 'List':
  //           propSchema['type'] = 'array';
  //           propSchema['items'] = {'type': 'object'}; // generic items
  //           break;
  //         case 'String':
  //         default:
  //           propSchema['type'] = 'string';
  //           break;
  //       }
  //
  //       // Nullable - Dart types are nullable by default or via ?
  //       // You may want to add a convention to detect this if needed.
  //
  //       // Defaults not available via reflection in Dart easily
  //
  //       schema['properties'][propName] = propSchema;
  //     }
  //   }
  //
  //   components[className] = schema;
  //
  //   return {'\$ref': '#/components/schemas/$schemaName'};
  // }
}
