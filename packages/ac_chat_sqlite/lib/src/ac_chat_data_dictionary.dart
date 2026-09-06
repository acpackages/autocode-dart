/// Data dictionary schema definition for the ac_chat SQLite database.
///
/// This JSON is registered at startup under the name `"ac_chat"` and is
/// consumed by [AcSqlDbSchemaManager] to create / migrate the database schema
/// and by [AcSqlDbTable] for typed CRUD operations.
const String kAcChatDataDictionaryJson = r'''
{
  "name": "ac_chat",
  "version": 4,
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
        },
        "bio": {
          "columnName": "bio",
          "columnType": "STRING"
        },
        "last_seen_utc": {
          "columnName": "last_seen_utc",
          "columnType": "INTEGER"
        },
        "is_online": {
          "columnName": "is_online",
          "columnType": "INTEGER",
          "columnProperties": {
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
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
        "group_description": {
          "columnName": "group_description",
          "columnType": "STRING"
        },
        "group_avatar": {
          "columnName": "group_avatar",
          "columnType": "STRING"
        },
        "created_by": {
          "columnName": "created_by",
          "columnType": "STRING"
        },
        "created_at_utc": {
          "columnName": "created_at_utc",
          "columnType": "INTEGER"
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
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "is_pinned": {
          "columnName": "is_pinned",
          "columnType": "INTEGER",
          "columnProperties": {
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "is_muted": {
          "columnName": "is_muted",
          "columnType": "INTEGER",
          "columnProperties": {
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "disappearing_duration_seconds": {
          "columnName": "disappearing_duration_seconds",
          "columnType": "INTEGER"
        }
      }
    },
    "user_conversation_prefs": {
      "tableName": "user_conversation_prefs",
      "tableColumns": {
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "user_id": {
          "columnName": "user_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "unread_count": {
          "columnName": "unread_count",
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
        },
        "mute_until_utc": {
          "columnName": "mute_until_utc",
          "columnType": "INTEGER"
        },
        "is_archived": {
          "columnName": "is_archived",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "is_hidden": {
          "columnName": "is_hidden",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "role": {
          "columnName": "role",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "member" }
          }
        },
        "last_read_message_id": {
          "columnName": "last_read_message_id",
          "columnType": "STRING"
        },
        "last_read_time_utc": {
          "columnName": "last_read_time_utc",
          "columnType": "INTEGER"
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
    "blocked_users": {
      "tableName": "blocked_users",
      "tableColumns": {
        "user_id": {
          "columnName": "user_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "blocked_at_utc": {
          "columnName": "blocked_at_utc",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
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
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "user_id": {
          "columnName": "user_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "role": {
          "columnName": "role",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "member" }
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
        "file_path": {
          "columnName": "file_path",
          "columnType": "STRING"
        },
        "file_url": {
          "columnName": "file_url",
          "columnType": "STRING"
        },
        "reply_to_id": {
          "columnName": "reply_to_id",
          "columnType": "STRING"
        },
        "delivered_time": {
          "columnName": "delivered_time",
          "columnType": "INTEGER"
        },
        "read_time": {
          "columnName": "read_time",
          "columnType": "INTEGER"
        },
        "is_edited": {
          "columnName": "is_edited",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "edited_time": {
          "columnName": "edited_time",
          "columnType": "INTEGER"
        },
        "is_deleted": {
          "columnName": "is_deleted",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "reactions_json": {
          "columnName": "reactions_json",
          "columnType": "TEXT"
        },
        "is_starred": {
          "columnName": "is_starred",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "mentions_json": {
          "columnName": "mentions_json",
          "columnType": "TEXT"
        },
        "pinned_until_utc": {
          "columnName": "pinned_until_utc",
          "columnType": "INTEGER"
        },
        "scheduled_time_utc": {
          "columnName": "scheduled_time_utc",
          "columnType": "INTEGER"
        },
        "expires_at_utc": {
          "columnName": "expires_at_utc",
          "columnType": "INTEGER"
        }
      }
    },
    "outbox_messages": {
      "tableName": "outbox_messages",
      "tableColumns": {
        "outbox_id": {
          "columnName": "outbox_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "message_id": {
          "columnName": "message_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "recipient_ids_json": {
          "columnName": "recipient_ids_json",
          "columnType": "TEXT",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "retry_count": {
          "columnName": "retry_count",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": 0 }
          }
        },
        "created_at": {
          "columnName": "created_at",
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
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "pending" }
          }
        }
      }
    },
    "messages_fts": {
      "tableName": "messages_fts",
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
        "text": {
          "columnName": "text",
          "columnType": "TEXT",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "" }
          }
        }
      }
    }
  }
}
''';
