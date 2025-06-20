import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_web/ac_web.dart';

class AcApiDocUtils {
  static String getApiDataFormatFromDataDictionaryDataType({
    required String dataType,
  }) {
    String result = "";
    if ([
      AcEnumDDColumnType.AUTO_INCREMENT,
      AcEnumDDColumnType.INTEGER,
    ].contains(dataType)) {
      result = AcEnumApiDataFormat.INT64;
    } else if (dataType == AcEnumDDColumnType.DOUBLE) {
      result = AcEnumApiDataFormat.DOUBLE;
    } else if (dataType == AcEnumDDColumnType.DATE) {
      result = AcEnumApiDataFormat.DATE;
    } else if (dataType == AcEnumDDColumnType.DATETIME) {
      result = AcEnumApiDataFormat.DATETIME;
    } else if (dataType == AcEnumDDColumnType.PASSWORD) {
      result = AcEnumApiDataFormat.PASSWORD;
    }
    return result;
  }

  static String getApiDataTypeFromDataDictionaryDataType({
    required String dataType,
  }) {
    String result = AcEnumApiDataType.STRING;
    if ([
      AcEnumDDColumnType.AUTO_INCREMENT,
      AcEnumDDColumnType.INTEGER,
    ].contains(dataType)) {
      result = AcEnumApiDataType.INTEGER;
    } else if ([
      AcEnumDDColumnType.JSON,
      AcEnumDDColumnType.MEDIA_JSON,
    ].contains(dataType)) {
      result = AcEnumApiDataType.OBJECT;
    } else if (dataType == AcEnumDDColumnType.DOUBLE) {
      result = AcEnumApiDataType.NUMBER;
    }
    return result;
  }

  static Map<String, dynamic> getApiModelRefFromAcDDTable({
    required AcDDTable acDDTable,
    required AcApiDoc acApiDoc,
  }) {
    if (acApiDoc.models.containsKey(acDDTable.tableName)) {
      return {
        r'$ref':
            "#/components/schemas/${acApiDoc.models[acDDTable.tableName]!.name}",
      };
    }

    final acApiDocModel = AcApiDocModel();
    acApiDocModel.name = acDDTable.tableName;
    final model = <String, dynamic>{};

    for (final column in acDDTable.tableColumns) {
      final columnType = getApiDataTypeFromDataDictionaryDataType(
        dataType: column.columnType,
      );
      final columnFormat = getApiDataFormatFromDataDictionaryDataType(
        dataType: column.columnType,
      );
      model[column.columnName] = {'type': columnType};
      if (columnFormat.isNotEmpty) {
        model[column.columnName]!['format'] = columnFormat;
      }
    }

    acApiDocModel.properties = model;
    acApiDoc.addModel(model: acApiDocModel);

    return {
      r'$ref':
          "#/components/schemas/${acApiDoc.models[acDDTable.tableName]!.name}",
    };
  }

  static Map<String, dynamic> getApiModelRefFromClass({
    required Type type,
    required AcApiDoc acApiDoc,
  }) {
    // 1. Use ac_mirrors to reflect on the class type.
    final classMirror = acReflectClass(type);
    // 2. Use the `getName()` method from the custom API.
    final schemaName = classMirror.getName();

    // If the model is already processed, return a reference to it.
    if (acApiDoc.models.containsKey(schemaName)) {
      return {
        r'$ref': "#/components/schemas/$schemaName",
      };
    }

    final acApiDocModel = AcApiDocModel();
    acApiDocModel.name = schemaName;

    // 3. Iterate over the non-synthetic, public instance members.
    for (final member in classMirror.instanceMembers.values) {
      // 4. We are only interested in fields (AcVariableMirror).
      if (member is AcVariableMirror) {
        final propName = member.getName();
        final propType = member.type;
        final propSchema = <String, dynamic>{};

        // 5. Get the type's name as a string for the switch statement.
        final typeName = propType.toString().replaceAll('?', ''); // Remove nullability for type matching.

        switch (typeName) {
          case 'int':
          case 'Integer':
            propSchema['type'] = 'integer';
            break;
          case 'double':
          case 'num':
            propSchema['type'] = 'number';
            break;
          case 'bool':
          case 'boolean':
            propSchema['type'] = 'boolean';
            break;
          case 'List':
          case 'Array':
            propSchema['type'] = 'array';
            // NOTE: For full OpenAPI compliance, you would need to reflect on the
            // list's generic type argument to define `items`.
            propSchema['items'] = {'type': 'object'};
            break;
          case 'String':
            propSchema['type'] = 'string';
            break;
          default:
          // For any other type, try to reflect on it. If it's a known model,
          // recursively call this function to get its schema reference.
            try {
              acReflectClass(propType); // This will throw if the type is not reflectable.
              // Add the reference and ensure the nested model is also processed.
              propSchema.addAll(getApiModelRefFromClass(type: propType, acApiDoc: acApiDoc));
            } catch (e) {
              // If it's not a reflectable class, treat it as a string.
              propSchema['type'] = 'string';
            }
            break;
        }
        acApiDocModel.properties[propName] = propSchema;
      }
    }

    acApiDoc.addModel(model: acApiDocModel);

    return {r'$ref': "#/components/schemas/$schemaName"};
  }

  // static Map<String, dynamic> getApiModelRefFromClass({
  //   required Type type,
  //   required AcApiDoc acApiDoc,
  // }) {
  //   final classMirror = reflectClass(type);
  //   final schemaName = MirrorSystem.getName(classMirror.simpleName);
  //
  //   if (acApiDoc.models.containsKey(schemaName)) {
  //     return {
  //       r'$ref': "#/components/schemas/${acApiDoc.models[schemaName]!.name}",
  //     };
  //   }
  //
  //   final acApiDocModel = AcApiDocModel();
  //   acApiDocModel.name = schemaName;
  //
  //   final classDeclarations = classMirror.declarations;
  //
  //   classDeclarations.forEach((symbol, declaration) {
  //     if (declaration is VariableMirror &&
  //         !declaration.isStatic &&
  //         !declaration.isPrivate) {
  //       final propName = MirrorSystem.getName(symbol);
  //       final propTypeMirror = declaration.type;
  //       final propSchema = <String, dynamic>{};
  //
  //       if (propTypeMirror is ClassMirror) {
  //         final typeName = MirrorSystem.getName(propTypeMirror.simpleName);
  //         switch (typeName) {
  //           case 'int':
  //           case 'Integer':
  //             propSchema['type'] = 'integer';
  //             break;
  //           case 'double':
  //           case 'num':
  //             propSchema['type'] = 'number';
  //             break;
  //           case 'bool':
  //           case 'boolean':
  //             propSchema['type'] = 'boolean';
  //             break;
  //           case 'List':
  //           case 'Array':
  //             propSchema['type'] = 'array';
  //             propSchema['items'] = {'type': 'object'};
  //             break;
  //           case 'String':
  //             propSchema['type'] = 'string';
  //             break;
  //           default:
  //             // Fallback for nested models or enums
  //             propSchema['\$ref'] = "#/components/schemas/$typeName";
  //             break;
  //         }
  //       } else {
  //         // Fallback for unhandled types
  //         propSchema['type'] = 'string';
  //       }
  //
  //       // if (allowsNull) {
  //       //   propSchema['nullable'] = true;
  //       // }
  //
  //       acApiDocModel.properties[propName] = propSchema;
  //     }
  //   });
  //
  //   acApiDoc.addModel(model: acApiDocModel);
  //
  //   return {r'$ref': "#/components/schemas/$schemaName"};
  // }

  static List<AcApiDocResponse> getApiDocRouteResponsesForOperation({
    required String operation,
    required AcDDTable acDDTable,
    required AcApiDoc acApiDoc,
  }) {
    final schema = getApiModelRefFromAcDDTable(
      acDDTable: acDDTable,
      acApiDoc: acApiDoc,
    );
    final responses = <AcApiDocResponse>[];

    final jsonContent = AcApiDocContent();
    jsonContent.encoding = "application/json";
    jsonContent.schema = {
      'type': AcEnumApiDataType.OBJECT,
      'properties': {
        'code': {
          'type': AcEnumApiDataType.INTEGER,
          'enum': [1, 2, 3],
        },
        'status': {
          'type': AcEnumApiDataType.STRING,
          'enum': ['success', 'failure'],
        },
        'message': {'type': AcEnumApiDataType.STRING},
        'rows': {'type': AcEnumApiDataType.ARRAY, 'items': schema},
      },
    };

    final acApiDocResponse = AcApiDocResponse();
    acApiDocResponse.code = AcEnumHttpResponseCode.OK;
    acApiDocResponse.description = "Successful operation";
    acApiDocResponse.addContent(content: jsonContent);
    responses.add(acApiDocResponse);

    return responses;
  }
}
