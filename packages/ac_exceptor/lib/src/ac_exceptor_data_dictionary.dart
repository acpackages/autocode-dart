/// Column name constants for ac_exceptor tables.
abstract class AcExceptorColumns {
  // exceptions table
  static const String id = 'id';
  static const String exceptionType = 'exception_type';
  static const String exceptionMessage = 'exception_message';
  static const String stackTrace = 'stack_trace';
  static const String firstOccurredAt = 'first_occurred_at';
  static const String lastOccurredAt = 'last_occurred_at';
  static const String occurrenceCount = 'occurrence_count';
  static const String isHandled = 'is_handled';

  // exception_occurrences table
  static const String exceptionId = 'exception_id';
  static const String occurredAt = 'occurred_at';
}

/// Table name constants for ac_exceptor.
abstract class AcExceptorTables {
  static const String exceptions = 'exceptions';
  static const String exceptionOccurrences = 'exception_occurrences';
}

/// Data dictionary schema definition for the ac_exceptor SQLite database.
///
/// This JSON is registered under the name `"ac_exceptor"` (or user configured name)
/// and consumed by [AcSqlDbSchemaManager] to create / migrate the database schema.
const String kAcExceptorDataDictionaryJson = r'''
{
  "name": "ac_exceptor",
  "version": 1,
  "tables": {
    "exceptions": {
      "tableName": "exceptions",
      "tableColumns": {
        "id": {
          "columnName": "id",
          "columnType": "AUTO_INCREMENT",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true }
          }
        },
        "exception_type": {
          "columnName": "exception_type",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "exception_message": {
          "columnName": "exception_message",
          "columnType": "TEXT",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "stack_trace": {
          "columnName": "stack_trace",
          "columnType": "TEXT"
        },
        "first_occurred_at": {
          "columnName": "first_occurred_at",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "last_occurred_at": {
          "columnName": "last_occurred_at",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "occurrence_count": {
          "columnName": "occurrence_count",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 1 }
          }
        },
        "is_handled": {
          "columnName": "is_handled",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        }
      },
      "tableProperties": {
        "CONSTRAINTS": {
          "propertyName": "CONSTRAINTS",
          "propertyValue": [
            { "type": "COMPOSITE_UNIQUE_KEY", "value": "`exception_type`, `exception_message`" }
          ]
        }
      }
    },
    "exception_occurrences": {
      "tableName": "exception_occurrences",
      "tableColumns": {
        "id": {
          "columnName": "id",
          "columnType": "AUTO_INCREMENT",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true }
          }
        },
        "exception_id": {
          "columnName": "exception_id",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "occurred_at": {
          "columnName": "occurred_at",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "stack_trace": {
          "columnName": "stack_trace",
          "columnType": "TEXT"
        },
        "is_handled": {
          "columnName": "is_handled",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        }
      }
    }
  },
  "relationships": [
    {
      "sourceTable": "exceptions",
      "sourceColumn": "id",
      "destinationTable": "exception_occurrences",
      "destinationColumn": "exception_id",
      "cascadeDeleteDestination": true
    }
  ]
}
''';
