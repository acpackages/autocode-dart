import 'dart:mirrors';

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
    final classMirror = reflectClass(type);
    final schemaName = MirrorSystem.getName(classMirror.simpleName);

    if (acApiDoc.models.containsKey(schemaName)) {
      return {
        r'$ref': "#/components/schemas/${acApiDoc.models[schemaName]!.name}",
      };
    }

    final acApiDocModel = AcApiDocModel();
    acApiDocModel.name = schemaName;

    final classDeclarations = classMirror.declarations;

    classDeclarations.forEach((symbol, declaration) {
      if (declaration is VariableMirror &&
          !declaration.isStatic &&
          !declaration.isPrivate) {
        final propName = MirrorSystem.getName(symbol);
        final propTypeMirror = declaration.type;
        final propSchema = <String, dynamic>{};

        if (propTypeMirror is ClassMirror) {
          final typeName = MirrorSystem.getName(propTypeMirror.simpleName);
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
              propSchema['items'] = {'type': 'object'};
              break;
            case 'String':
              propSchema['type'] = 'string';
              break;
            default:
              // Fallback for nested models or enums
              propSchema['\$ref'] = "#/components/schemas/$typeName";
              break;
          }
        } else {
          // Fallback for unhandled types
          propSchema['type'] = 'string';
        }

        // if (allowsNull) {
        //   propSchema['nullable'] = true;
        // }

        acApiDocModel.properties[propName] = propSchema;
      }
    });

    acApiDoc.addModel(model: acApiDocModel);

    return {r'$ref': "#/components/schemas/$schemaName"};
  }

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
