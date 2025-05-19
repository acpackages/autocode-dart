import 'package:autocode_data_dictionary/autocode_data_dictionary.dart';

class AcSchemaManagerTables {
  static const SCHEMA_DETAILS = "_ac_schema_details";
  static const SCHEMA_LOGS = "_ac_schema_logs";
}

class TblSchemaDetails {
  static const AC_SCHEMA_DETAIL_ID = "ac_schema_detail_id";
  static const AC_SCHEMA_DETAIL_KEY = "ac_schema_detail_key";
  static const AC_SCHEMA_DETAIL_STRING_VALUE = "ac_schema_detail_string_value";
  static const AC_SCHEMA_DETAIL_NUMERIC_VALUE = "ac_schema_detail_numeric_value";
}

class TblSchemaLogs {
  static const AC_SCHEMA_LOG_ID = "ac_schema_log_id";
  static const AC_SCHEMA_OPERATION = "ac_schema_operation";
  static const AC_SCHEMA_ENTITY_TYPE = "ac_schema_entity_type";
  static const AC_SCHEMA_ENTITY_NAME = "ac_schema_entity_name";
  static const AC_SCHEMA_OPERATION_STATEMENT = "ac_schema_operation_statement";
  static const AC_SCHEMA_OPERATION_RESULT = "ac_schema_operation_result";
  static const AC_SCHEMA_OPERATION_TIMESTAMP = "ac_schema_operation_timestamp";
}

class SchemaDetails {
  static const KEY_CREATED_ON = "CREATED_ON";
  static const KEY_DATA_DICTIONARY_VERSION = "DATA_DICTIONARY_VERSION";
  static const KEY_LAST_UPDATED_ON = "LAST_UPDATED_ON";
}

class AcSMDataDictionary {
  static const DATA_DICTIONARY_NAME = "_ac_schema";

  static const DATA_DICTIONARY = {
    AcDataDictionary.KEY_VERSION: 1,
    AcDataDictionary.KEY_TABLES: {
      AcSchemaManagerTables.SCHEMA_DETAILS: {
        AcDDTable.KEY_TABLE_NAME: AcSchemaManagerTables.SCHEMA_DETAILS,
        AcDDTable.KEY_TABLE_COLUMNS: {
          TblSchemaDetails.AC_SCHEMA_DETAIL_ID: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_ID,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.AUTO_INCREMENT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {
              AcEnumDDColumnProperty.PRIMARY_KEY: {
                AcDDTableColumnProperty.KEY_PROPERTY_NAME: AcEnumDDColumnProperty.PRIMARY_KEY,
                AcDDTableColumnProperty.KEY_PROPERTY_VALUE: true,
              }
            }
          },
          TblSchemaDetails.AC_SCHEMA_DETAIL_KEY: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_KEY,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.STRING,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {
              AcEnumDDColumnProperty.CHECK_IN_SAVE: {
                AcDDTableColumnProperty.KEY_PROPERTY_NAME: AcEnumDDColumnProperty.CHECK_IN_SAVE,
                AcDDTableColumnProperty.KEY_PROPERTY_VALUE: true,
              }
            }
          },
          TblSchemaDetails.AC_SCHEMA_DETAIL_STRING_VALUE: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_STRING_VALUE,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.TEXT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          },
          TblSchemaDetails.AC_SCHEMA_DETAIL_NUMERIC_VALUE: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaDetails.AC_SCHEMA_DETAIL_NUMERIC_VALUE,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.DOUBLE,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          }
        }
      },
      AcSchemaManagerTables.SCHEMA_LOGS: {
        AcDDTable.KEY_TABLE_NAME: AcSchemaManagerTables.SCHEMA_LOGS,
        AcDDTable.KEY_TABLE_COLUMNS: {
          TblSchemaLogs.AC_SCHEMA_LOG_ID: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_LOG_ID,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.AUTO_INCREMENT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {
              AcEnumDDColumnProperty.PRIMARY_KEY: {
                AcDDTableColumnProperty.KEY_PROPERTY_NAME: AcEnumDDColumnProperty.PRIMARY_KEY,
                AcDDTableColumnProperty.KEY_PROPERTY_VALUE: true,
              }
            }
          },
          TblSchemaLogs.AC_SCHEMA_OPERATION: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.STRING,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          },
          TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_ENTITY_TYPE,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.TEXT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          },
          TblSchemaLogs.AC_SCHEMA_ENTITY_NAME: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_ENTITY_NAME,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.TEXT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          },
          TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION_STATEMENT,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.TEXT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          },
          TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION_RESULT,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.TEXT,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          },
          TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP: {
            AcDDTableColumn.KEY_COLUMN_NAME: TblSchemaLogs.AC_SCHEMA_OPERATION_TIMESTAMP,
            AcDDTableColumn.KEY_COLUMN_TYPE: AcEnumDDColumnType.TIMESTAMP,
            AcDDTableColumn.KEY_COLUMN_PROPERTIES: {}
          }
        }
      }
    }
  };
}
