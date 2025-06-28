import 'package:ac_mirrors/ac_mirrors.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_web/ac_web.dart';

/* AcDoc({
  "summary": "A utility class with helper methods for generating OpenAPI documentation components.",
  "description": "This class provides static methods to simplify the creation of OpenAPI-compliant schemas and other documentation objects from existing data dictionary definitions or Dart class types. It acts as a bridge between the application's internal models and the OpenAPI specification format."
}) */
class AcApiDocUtils {
  // Private constructor to prevent instantiation of this static utility class.
  AcApiDocUtils._();

  /* AcDoc({
    "summary": "Maps a data dictionary column type to an OpenAPI data format.",
    "description": "Translates an `AcEnumDDColumnType` into a standard OpenAPI `format` string (e.g., `int64`, `date-time`). If no specific format applies, an empty string is returned.",
    "params": [
      {"name": "dataType", "description": "The data dictionary column type."}
    ],
    "returns": "The corresponding OpenAPI format string.",
    "returns_type": "String"
  }) */
  static String getApiDataFormatFromDataDictionaryDataType({
    required AcEnumDDColumnType dataType,
  }) {
    String result = "";
    if ([
      AcEnumDDColumnType.autoIncrement,
      AcEnumDDColumnType.integer,
    ].contains(dataType)) {
      result = AcEnumApiDataFormat.int64.value;
    } else if (dataType == AcEnumDDColumnType.double_) {
      result = AcEnumApiDataFormat.double_.value;
    } else if (dataType == AcEnumDDColumnType.date) {
      result = AcEnumApiDataFormat.date.value;
    } else if (dataType == AcEnumDDColumnType.datetime) {
      result = AcEnumApiDataFormat.datetime.value;
    } else if (dataType == AcEnumDDColumnType.password) {
      result = AcEnumApiDataFormat.password.value;
    }
    return result;
  }

  /* AcDoc({
    "summary": "Maps a data dictionary column type to an OpenAPI data type.",
    "description": "Translates an `AcEnumDDColumnType` into a standard OpenAPI `type` string (e.g., `integer`, `object`, `string`). Defaults to 'string'.",
    "params": [
      {"name": "dataType", "description": "The data dictionary column type."}
    ],
    "returns": "The corresponding OpenAPI type string.",
    "returns_type": "String"
  }) */
  static String getApiDataTypeFromDataDictionaryDataType({
    required AcEnumDDColumnType dataType,
  }) {
    String result = AcEnumApiDataType.string.value;
    if ([
      AcEnumDDColumnType.autoIncrement,
      AcEnumDDColumnType.integer,
    ].contains(dataType)) {
      result = AcEnumApiDataType.integer.value;
    } else if ([
      AcEnumDDColumnType.json,
      AcEnumDDColumnType.mediaJson,
    ].contains(dataType)) {
      result = AcEnumApiDataType.object.value;
    } else if (dataType == AcEnumDDColumnType.double_) {
      result = AcEnumApiDataType.number.value;
    }
    return result;
  }

  /* AcDoc({
    "summary": "Generates a reusable schema definition from a data dictionary table.",
    "description": "This method takes an `AcDDTable` definition, creates a corresponding OpenAPI schema, adds it to the main `AcApiDoc`'s components section, and returns a JSON schema reference (`\$ref`) to it.",
    "params": [
      {"name": "acDDTable", "description": "The data dictionary table definition."},
      {"name": "acApiDoc", "description": "The main API documentation object where the generated model will be stored."}
    ],
    "returns": "A map representing a JSON schema reference (e.g., `{\"\$ref\": \"#/components/schemas/User\"}`).",
    "returns_type": "Map<String, dynamic>"
  }) */
  static Map<String, dynamic> getApiModelRefFromAcDDTable({
    required AcDDTable acDDTable,
    required AcApiDoc acApiDoc,
  }) {
    if (acApiDoc.models.containsKey(acDDTable.tableName)) {
      return {
        r'$ref': "#/components/schemas/${acApiDoc.models[acDDTable.tableName]!.name}",
      };
    }

    final acApiDocModel = AcApiDocModel();
    acApiDocModel.name = acDDTable.tableName;
    final modelProperties = <String, dynamic>{};

    for (final column in acDDTable.tableColumns) {
      final columnType = getApiDataTypeFromDataDictionaryDataType(dataType: column.columnType);
      final columnFormat = getApiDataFormatFromDataDictionaryDataType(dataType: column.columnType);

      final propertySchema = {'type': columnType};
      if (columnFormat.isNotEmpty) {
        propertySchema['format'] = columnFormat;
      }
      modelProperties[column.columnName] = propertySchema;
    }

    acApiDocModel.properties = modelProperties;
    acApiDoc.addModel(model: acApiDocModel);

    return {
      r'$ref': "#/components/schemas/${acApiDoc.models[acDDTable.tableName]!.name}",
    };
  }

  /* AcDoc({
    "summary": "Generates a reusable schema definition from a Dart class type using reflection.",
    "description": "This method uses the `ac_mirrors` package to inspect a Dart class at runtime and generate a corresponding OpenAPI Schema Object. It handles primitive types and recursively calls itself for nested classes. The generated schema is added to the main `acApiDoc` object, and a reference to it is returned.\n\nNote: This relies on a reflection mechanism which may have platform limitations (e.g., it is not supported in AOT-compiled Flutter without build-time code generation).",
    "params": [
      {"name": "type", "description": "The `Type` of the Dart class to generate a schema for."},
      {"name": "acApiDoc", "description": "The main API documentation object where the generated model will be stored."}
    ],
    "returns": "A map representing a JSON schema reference (e.g., `{\"\$ref\": \"#/components/schemas/User\"}`).",
    "returns_type": "Map<String, dynamic>"
  }) */
  static Map<String, dynamic> getApiModelRefFromClass({
    required Type type,
    required AcApiDoc acApiDoc,
  }) {
    final classMirror = acReflectClass(type);
    final schemaName = classMirror.getName();

    if (acApiDoc.models.containsKey(schemaName)) {
      return {r'$ref': "#/components/schemas/$schemaName"};
    }

    final acApiDocModel = AcApiDocModel()..name = schemaName;
    final modelProperties = <String, dynamic>{};

    for (final member in classMirror.instanceMembers.values) {
      if (member is AcVariableMirror) {
        final propName = member.getName();
        final propType = member.type;
        final propSchema = <String, dynamic>{};
        final typeName = propType.toString().replaceAll('?', '');

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
            propSchema['items'] = {'type': 'object'}; // Default for unknown list type
            break;
          case 'String':
            propSchema['type'] = 'string';
            break;
          default:
            try {
              acReflectClass(propType);
              propSchema.addAll(getApiModelRefFromClass(type: propType, acApiDoc: acApiDoc));
            } catch (e) {
              propSchema['type'] = 'string'; // Fallback for non-reflectable types
            }
            break;
        }
        modelProperties[propName] = propSchema;
      }
    }

    acApiDocModel.properties = modelProperties;
    acApiDoc.addModel(model: acApiDocModel);

    return {r'$ref': "#/components/schemas/$schemaName"};
  }

  /* AcDoc({
    "summary": "Generates a default list of API responses for an operation.",
    "description": "Creates a standard '200 OK' success response definition, using the provided table schema to describe the structure of the data returned in the response body.",
    "params": [
      {"name": "operation", "description": "The type of row operation (for future use)."},
      {"name": "acDDTable", "description": "The data dictionary table definition for the response schema."},
      {"name": "acApiDoc", "description": "The main API documentation object."}
    ],
    "returns": "A list containing a default `AcApiDocResponse` for a successful operation.",
    "returns_type": "List<AcApiDocResponse>"
  }) */
  static List<AcApiDocResponse> getApiDocRouteResponsesForOperation({
    required AcEnumDDRowOperation operation,
    required AcDDTable acDDTable,
    required AcApiDoc acApiDoc,
  }) {
    final schema = getApiModelRefFromAcDDTable(
      acDDTable: acDDTable,
      acApiDoc: acApiDoc,
    );
    final responses = <AcApiDocResponse>[];

    final jsonContent = AcApiDocContent(
      schema: {
        'type': AcEnumApiDataType.object.value,
        'properties': {
          'code': {
            'type': AcEnumApiDataType.integer.value,
            'enum': [1, 2, 3],
          },
          'status': {
            'type': AcEnumApiDataType.string.value,
            'enum': ['success', 'failure'],
          },
          'message': {'type': AcEnumApiDataType.string.value},
          'rows': {'type': AcEnumApiDataType.array.value, 'items': schema},
        },
      },
    );

    final acApiDocResponse = AcApiDocResponse(description: "Successful operation")
      ..code = AcEnumHttpResponseCode.ok
      ..content['application/json'] = jsonContent;

    responses.add(acApiDocResponse);

    return responses;
  }
}