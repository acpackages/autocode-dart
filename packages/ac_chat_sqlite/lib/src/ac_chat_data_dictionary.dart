/// Data dictionary schema definition for the ac_chat SQLite database.
///
/// This JSON is registered at startup under the name `"ac_chat"` and is
/// consumed by [AcSqlDbSchemaManager] to create / migrate the database schema
/// and by [AcSqlDbTable] for typed CRUD operations.
const String kAcChatDataDictionaryJson = r'''
{
  "name": "ac_chat",
  "version": 1,
  "tables": {
    "users": {
      "tableName": "users",
      "tableColumns": {
        "user_id": {
          "columnName": "user_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "name": {
          "columnName": "name",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "username": {
          "columnName": "username",
          "columnType": "STRING",
          "columnProperties": {
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "" }
          }
        },
        "email": {
          "columnName": "email",
          "columnType": "STRING",
          "columnProperties": {
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "" }
          }
        },
        "phone": {
          "columnName": "phone",
          "columnType": "STRING"
        },
        "avatar": {
          "columnName": "avatar",
          "columnType": "STRING"
        }
      }
    },
    "conversations": {
      "tableName": "conversations",
      "tableColumns": {
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "type": {
          "columnName": "type",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "direct" }
          }
        },
        "group_name": {
          "columnName": "group_name",
          "columnType": "STRING"
        },
        "last_message": {
          "columnName": "last_message",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "" }
          }
        },
        "last_message_type": {
          "columnName": "last_message_type",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "text" }
          }
        },
        "last_time": {
          "columnName": "last_time",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "unread": {
          "columnName": "unread",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "is_pinned": {
          "columnName": "is_pinned",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "is_muted": {
          "columnName": "is_muted",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        }
      }
    },
    "conversation_members": {
      "tableName": "conversation_members",
      "tableColumns": {
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "user_id": {
          "columnName": "user_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        }
      },
      "tableProperties": {
        "CONSTRAINTS": {
          "propertyName": "CONSTRAINTS",
          "propertyValue": [
            { "type": "COMPOSITE_UNIQUE_KEY", "columns": ["conversation_id", "user_id"] }
          ]
        }
      }
    },
    "messages": {
      "tableName": "messages",
      "tableColumns": {
        "message_id": {
          "columnName": "message_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "sender_id": {
          "columnName": "sender_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "type": {
          "columnName": "type",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "text" }
          }
        },
        "text": {
          "columnName": "text",
          "columnType": "TEXT",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "" }
          }
        },
        "time": {
          "columnName": "time",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "status": {
          "columnName": "status",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "sending" }
          }
        },
        "media_caption": {
          "columnName": "media_caption",
          "columnType": "TEXT"
        },
        "amount": {
          "columnName": "amount",
          "columnType": "DOUBLE"
        },
        "payment_note": {
          "columnName": "payment_note",
          "columnType": "TEXT"
        },
        "duration": {
          "columnName": "duration",
          "columnType": "STRING"
        },
        "file_name": {
          "columnName": "file_name",
          "columnType": "STRING"
        },
        "file_size": {
          "columnName": "file_size",
          "columnType": "STRING"
        },
        "is_downloaded": {
          "columnName": "is_downloaded",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "local_path": {
          "columnName": "local_path",
          "columnType": "STRING"
        },
        "reply_to_id": {
          "columnName": "reply_to_id",
          "columnType": "STRING"
        }
      }
    }
  }
}
''';
