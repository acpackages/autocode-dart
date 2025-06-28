import 'package:ac_data_dictionary/ac_data_dictionary.dart';

/* AcDoc({
  "summary": "Defines constant table names for the internal schema manager."
}) */
class AcSchemaManagerTables {
  // Renamed constants to follow lowerCamelCase Dart naming conventions.
  static const String schemaDetails = "_ac_schema_details";
  static const String schemaLogs = "_ac_schema_logs";
}

/* AcDoc({
  "summary": "Defines constant column names for the `_ac_schema_details` table."
}) */
class TblSchemaDetails {
  // Renamed constants to follow lowerCamelCase Dart naming conventions.
  static const String acSchemaDetailId = "ac_schema_detail_id";
  static const String acSchemaDetailKey = "ac_schema_detail_key";
  static const String acSchemaDetailStringValue = "ac_schema_detail_string_value";
  static const String acSchemaDetailNumericValue = "ac_schema_detail_numeric_value";
}

/* AcDoc({
  "summary": "Defines constant column names for the `_ac_schema_logs` table."
}) */
class TblSchemaLogs {
  // Renamed constants to follow lowerCamelCase Dart naming conventions.
  static const String acSchemaLogId = "ac_schema_log_id";
  static const String acSchemaOperation = "ac_schema_operation";
  static const String acSchemaEntityType = "ac_schema_entity_type";
  static const String acSchemaEntityName = "ac_schema_entity_name";
  static const String acSchemaOperationStatement = "ac_schema_operation_statement";
  static const String acSchemaOperationResult = "ac_schema_operation_result";
  static const String acSchemaOperationTimestamp = "ac_schema_operation_timestamp";
}

/* AcDoc({
  "summary": "Defines constant keys for records within the `_ac_schema_details` table."
}) */
class SchemaDetails {
  // Renamed constants to follow lowerCamelCase Dart naming conventions.
  static const String keyCreatedOn = "CREATED_ON";
  static const String keyDataDictionaryVersion = "DATA_DICTIONARY_VERSION";
  static const String keyLastUpdatedOn = "LAST_UPDATED_ON";
}

/* AcDoc({
  "summary": "Defines the built-in data dictionary for the schema manager's internal tables."
}) */
class AcSMDataDictionary {
  /* AcDoc({"summary": "The reserved name for the schema manager's internal data dictionary."}) */
  static const String dataDictionaryName = "_ac_schema";

  /* AcDoc({
    "summary": "The static data dictionary definition for the schema manager.",
    "description": "This map defines the structure of the internal tables (`_ac_schema_details` and `_ac_schema_logs`) that the schema manager uses to track its own version and migration operations. It follows the standard `AcDataDictionary` format."
  }) */
  static Map<String,dynamic> dataDictionary = {
    // Assumes external constants have also been refactored to lowerCamelCase
    AcDataDictionary.keyVersion: 1,
    AcDataDictionary.keyTables: {
      AcSchemaManagerTables.schemaDetails: {
        AcDDTable.keyTableName: AcSchemaManagerTables.schemaDetails,
        AcDDTable.keyTableColumns: {
          TblSchemaDetails.acSchemaDetailId: {
            AcDDTableColumn.keyColumnName: TblSchemaDetails.acSchemaDetailId,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.autoIncrement.value,
            AcDDTableColumn.keyColumnProperties: {
              AcEnumDDColumnProperty.primaryKey.value: {
                AcDDTableColumnProperty.keyPropertyName: AcEnumDDColumnProperty.primaryKey.value,
                AcDDTableColumnProperty.keyPropertyValue: true,
              }
            }
          },
          TblSchemaDetails.acSchemaDetailKey: {
            AcDDTableColumn.keyColumnName: TblSchemaDetails.acSchemaDetailKey,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.string.value,
            AcDDTableColumn.keyColumnProperties: {
              AcEnumDDColumnProperty.checkInSave.value: {
                AcDDTableColumnProperty.keyPropertyName: AcEnumDDColumnProperty.checkInSave.value,
                AcDDTableColumnProperty.keyPropertyValue: true,
              }
            }
          },
          TblSchemaDetails.acSchemaDetailStringValue: {
            AcDDTableColumn.keyColumnName: TblSchemaDetails.acSchemaDetailStringValue,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.text.value,
            AcDDTableColumn.keyColumnProperties: {}
          },
          TblSchemaDetails.acSchemaDetailNumericValue: {
            AcDDTableColumn.keyColumnName: TblSchemaDetails.acSchemaDetailNumericValue,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.double_.value,
            AcDDTableColumn.keyColumnProperties: {}
          }
        }
      },
      AcSchemaManagerTables.schemaLogs: {
        AcDDTable.keyTableName: AcSchemaManagerTables.schemaLogs,
        AcDDTable.keyTableColumns: {
          TblSchemaLogs.acSchemaLogId: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaLogId,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.autoIncrement.value,
            AcDDTableColumn.keyColumnProperties: {
              AcEnumDDColumnProperty.primaryKey.value: {
                AcDDTableColumnProperty.keyPropertyName: AcEnumDDColumnProperty.primaryKey.value,
                AcDDTableColumnProperty.keyPropertyValue: true,
              }
            }
          },
          TblSchemaLogs.acSchemaOperation: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaOperation,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.string.value,
            AcDDTableColumn.keyColumnProperties: {}
          },
          TblSchemaLogs.acSchemaEntityType: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaEntityType,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.text.value,
            AcDDTableColumn.keyColumnProperties: {}
          },
          TblSchemaLogs.acSchemaEntityName: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaEntityName,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.text.value,
            AcDDTableColumn.keyColumnProperties: {}
          },
          TblSchemaLogs.acSchemaOperationStatement: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaOperationStatement,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.text.value,
            AcDDTableColumn.keyColumnProperties: {}
          },
          TblSchemaLogs.acSchemaOperationResult: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaOperationResult,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.text.value,
            AcDDTableColumn.keyColumnProperties: {}
          },
          TblSchemaLogs.acSchemaOperationTimestamp: {
            AcDDTableColumn.keyColumnName: TblSchemaLogs.acSchemaOperationTimestamp,
            AcDDTableColumn.keyColumnType: AcEnumDDColumnType.timestamp.value,
            AcDDTableColumn.keyColumnProperties: {}
          }
        }
      }
    }
  };
}
// import 'package:ac_data_dictionary/ac_data_dictionary.dart';
//
// class AcSchemaManagerTables {
//   static const SCHEMA_DETAILS = "_ac_schema_details";
//   static const SCHEMA_LOGS = "_ac_schema_logs";
// }
//
// class TblSchemaDetails {
//   static const AC_SCHEMA_DETAIL_ID = "ac_schema_detail_id";
//   static const AC_SCHEMA_DETAIL_KEY = "ac_schema_detail_key";
//   static const AC_SCHEMA_DETAIL_STRING_VALUE = "ac_schema_detail_string_value";
//   static const AC_SCHEMA_DETAIL_NUMERIC_VALUE = "ac_schema_detail_numeric_value";
// }
//
// class TblSchemaLogs {
//   static const AC_SCHEMA_LOG_ID = "ac_schema_log_id";
//   static const AC_SCHEMA_OPERATION = "ac_schema_operation";
//   static const AC_SCHEMA_ENTITY_TYPE = "ac_schema_entity_type";
//   static const AC_SCHEMA_ENTITY_NAME = "ac_schema_entity_name";
//   static const AC_SCHEMA_OPERATION_STATEMENT = "ac_schema_operation_statement";
//   static const AC_SCHEMA_OPERATION_RESULT = "ac_schema_operation_result";
//   static const AC_SCHEMA_OPERATION_TIMESTAMP = "ac_schema_operation_timestamp";
// }
//
// class SchemaDetails {
//   static const KEY_CREATED_ON = "CREATED_ON";
//   static const KEY_DATA_DICTIONARY_VERSION = "DATA_DICTIONARY_VERSION";
//   static const KEY_LAST_UPDATED_ON = "LAST_UPDATED_ON";
// }
//
// class AcSMDataDictionary {
//   static const DATA_DICTIONARY_NAME = "_ac_schema";
//
//   static Map<String,dynamic> DATA_DICTIONARY = {
//     AcDataDictionary.KEY_VERSION: 1,
//     AcDataDictionary.KEY_TABLES: {
//       AcSchemaManagerTables.SCHEMA_DETAILS: {
//         AcDDTable.KEY_TABLE_NAME: AcSchemaManagerTables.SCHEMA_DETAILS,
//         AcDDTable.KEY_TABLE_COLUMNS: {
//           TblSchemaDetails.AC_SCHEMA_DETAIL_ID: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_ID,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.autoIncrement.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {
//               AcEnumDDColumnProperty.primaryKey: {
//                 AcDDTableColumnProperty.KEY_PROPERTY_NAME: AcEnumDDColumnProperty.primaryKey.value,
//                 AcDDTableColumnProperty.KEY_PROPERTY_VALUE: true,
//               }
//             }
//           },
//           TblSchemaDetails.AC_SCHEMA_DETAIL_KEY: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_KEY,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.string,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {
//               AcEnumDDColumnProperty.checkInSave.value: {
//                 AcDDTableColumnProperty.KEY_PROPERTY_NAME: AcEnumDDColumnProperty.checkInSave.value,
//                 AcDDTableColumnProperty.KEY_PROPERTY_VALUE: true,
//               }
//             }
//           },
//           TblSchemaDetails.AC_SCHEMA_DETAIL_STRING_VALUE: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_STRING_VALUE,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.text.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           },
//           TblSchemaDetails.AC_SCHEMA_DETAIL_NUMERIC_VALUE: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_NUMERIC_VALUE,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.double_.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           }
//         }
//       },
//       AcSchemaManagerTables.SCHEMA_LOGS: {
//         AcDDTable.KEY_TABLE_NAME: AcSchemaManagerTables.SCHEMA_LOGS,
//         AcDDTable.KEY_TABLE_COLUMNS: {
//           TblSchemaLogs.AC_SCHEMA_LOG_ID: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_LOG_ID,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.autoIncrement.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {
//               AcEnumDDColumnProperty.primaryKey.value: {
//                 AcDDTableColumnProperty.KEY_PROPERTY_NAME: AcEnumDDColumnProperty.primaryKey.value,
//                 AcDDTableColumnProperty.KEY_PROPERTY_VALUE: true,
//               }
//             }
//           },
//           TblSchemaLogs.AC_SCHEMA_OPERATION: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.string.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           },
//           TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.text.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           },
//           TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_ENTITY_NAME,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.text.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           },
//           TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.text.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           },
//           TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.text.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           },
//           TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: {
//             AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP,
//             AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.timestamp.value,
//             AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
//           }
//         }
//       }
//     }
//   };
// }
