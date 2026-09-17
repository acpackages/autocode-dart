const Map<String,dynamic> kAcChatDataDictionaryJson = {
  "name": "ac_chat",
  "version": 1,
  "tables": {
    "users": {
      "tableName": "users",
      "tableColumns": {
        "user_id": {
          "columnName": "user_id",
          "columnType": "UUID",
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
        "last_seen": {
          "columnName": "last_seen",
          "columnType": "DATETIME"
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
          "columnType": "UUID",
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
        "conversation_name": {
          "columnName": "conversation_name",
          "columnType": "STRING"
        },
        "conversation_description": {
          "columnName": "conversation_description",
          "columnType": "STRING"
        },
        "conversation_avatar": {
          "columnName": "conversation_avatar",
          "columnType": "STRING"
        },
        "created_by": {
          "columnName": "created_by",
          "columnType": "STRING"
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME"
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
          "columnType": "DATETIME",
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
        "user_conversation_pref_id": {
          "columnName": "user_conversation_pref_id",
          "columnType": "AUTO_INCREMENT",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
          }
        },
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "UUID",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "user_id": {
          "columnName": "user_id",
          "columnType": "UUID",
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
        "mute_until": {
          "columnName": "mute_until",
          "columnType": "DATETIME"
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
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "user" }
          }
        },
        "last_read_message_id": {
          "columnName": "last_read_message_id",
          "columnType": "STRING"
        },
        "last_read_time": {
          "columnName": "last_read_time",
          "columnType": "DATETIME"
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
        "blocked_user_id": {
          "columnName": "blocked_user_id",
          "columnType": "AUTO_INCREMENT",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
          }
        },
        "user_id": {
          "columnName": "user_id",
          "columnType": "UUID",
          "columnProperties": {
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "blocked_at": {
          "columnName": "blocked_at",
          "columnType": "DATETIME",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        }
      }
    },
    "conversation_users": {
      "tableName": "conversation_users",
      "tableColumns": {
        "conversation_user_id": {
          "columnName": "conversation_user_id",
          "columnType": "AUTO_INCREMENT",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
          }
        },
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "UUID",
          "columnProperties": {
            "NOT_NULL":      { "propertyName": "NOT_NULL",      "propertyValue": true },
            "CHECK_IN_SAVE": { "propertyName": "CHECK_IN_SAVE", "propertyValue": true }
          }
        },
        "user_id": {
          "columnName": "user_id",
          "columnType": "UUID",
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
            "DEFAULT_VALUE": { "propertyName": "DEFAULT_VALUE", "propertyValue": "user" }
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
          "columnType": "UUID",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "UUID",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "sender_id": {
          "columnName": "sender_id",
          "columnType": "UUID",
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
          "columnType": "DATETIME",
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
        "file_url": {
          "columnName": "file_url",
          "columnType": "STRING"
        },
        "reply_to_id": {
          "columnName": "reply_to_id",
          "columnType": "UUID"
        },
        "delivered_time": {
          "columnName": "delivered_time",
          "columnType": "DATETIME"
        },
        "read_time": {
          "columnName": "read_time",
          "columnType": "DATETIME"
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
          "columnType": "DATETIME"
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
        "pinned_until": {
          "columnName": "pinned_until",
          "columnType": "DATETIME"
        },
        "scheduled_time": {
          "columnName": "scheduled_time",
          "columnType": "DATETIME"
        },
        "expires_at": {
          "columnName": "expires_at",
          "columnType": "DATETIME"
        }
      }
    },
    "channel_cache": {
      "tableName": "channel_cache",
      "tableColumns": {
        "cache_id": {
          "columnName": "cache_id",
          "columnType": "AUTO_INCREMENT",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true }
          }
        },
        "envelope_json": {
          "columnName": "envelope_json",
          "columnType": "TEXT",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME",
          "columnProperties": {
            "NOT_NULL": { "propertyName": "NOT_NULL", "propertyValue": true }
          }
        }
      }
    },
    "messages_fts": {
      "tableName": "messages_fts",
      "tableColumns": {
        "message_id": {
          "columnName": "message_id",
          "columnType": "UUID",
          "columnProperties": {
            "PRIMARY_KEY": { "propertyName": "PRIMARY_KEY", "propertyValue": true },
            "NOT_NULL":    { "propertyName": "NOT_NULL",    "propertyValue": true }
          }
        },
        "conversation_id": {
          "columnName": "conversation_id",
          "columnType": "UUID",
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
};

/* Keys Start */
/* Table Keys Start */

class Tables {
  static const String blockedUsers = "blocked_users";
  static const String channelCache = "channel_cache";
  static const String conversationUsers = "conversation_users";
  static const String conversations = "conversations";
  static const String messages = "messages";
  static const String messagesFts = "messages_fts";
  static const String userConversationPrefs = "user_conversation_prefs";
  static const String users = "users";
}

class TblBlockedUsers {
  static const String blockedUserId = "blocked_user_id";
  static const String userId = "user_id";
  static const String blockedAt = "blocked_at";
}
class TblChannelCache {
  static const String cacheId = "cache_id";
  static const String envelopeJson = "envelope_json";
  static const String createdAt = "created_at";
}
class TblConversationUsers {
  static const String conversationUserId = "conversation_user_id";
  static const String conversationId = "conversation_id";
  static const String userId = "user_id";
  static const String role = "role";
}
class TblConversations {
  static const String conversationId = "conversation_id";
  static const String type = "type";
  static const String conversationName = "conversation_name";
  static const String conversationDescription = "conversation_description";
  static const String conversationAvatar = "conversation_avatar";
  static const String createdBy = "created_by";
  static const String createdAt = "created_at";
  static const String lastMessage = "last_message";
  static const String lastMessageType = "last_message_type";
  static const String lastTime = "last_time";
  static const String unread = "unread";
  static const String isPinned = "is_pinned";
  static const String isMuted = "is_muted";
  static const String disappearingDurationSeconds = "disappearing_duration_seconds";
}
class TblMessages {
  static const String messageId = "message_id";
  static const String conversationId = "conversation_id";
  static const String senderId = "sender_id";
  static const String type = "type";
  static const String text = "text";
  static const String time = "time";
  static const String status = "status";
  static const String mediaCaption = "media_caption";
  static const String amount = "amount";
  static const String paymentNote = "payment_note";
  static const String duration = "duration";
  static const String fileName = "file_name";
  static const String fileSize = "file_size";
  static const String isDownloaded = "is_downloaded";
  static const String localPath = "local_path";
  static const String fileUrl = "file_url";
  static const String replyToId = "reply_to_id";
  static const String deliveredTime = "delivered_time";
  static const String readTime = "read_time";
  static const String isEdited = "is_edited";
  static const String editedTime = "edited_time";
  static const String isDeleted = "is_deleted";
  static const String reactionsJson = "reactions_json";
  static const String isStarred = "is_starred";
  static const String mentionsJson = "mentions_json";
  static const String pinnedUntil = "pinned_until";
  static const String scheduledTime = "scheduled_time";
  static const String expiresAt = "expires_at";
}
class TblMessagesFts {
  static const String messageId = "message_id";
  static const String conversationId = "conversation_id";
  static const String text = "text";
}
class TblUserConversationPrefs {
  static const String userConversationPrefId = "user_conversation_pref_id";
  static const String conversationId = "conversation_id";
  static const String userId = "user_id";
  static const String unreadCount = "unread_count";
  static const String isPinned = "is_pinned";
  static const String isMuted = "is_muted";
  static const String muteUntil = "mute_until";
  static const String isArchived = "is_archived";
  static const String isHidden = "is_hidden";
  static const String role = "role";
  static const String lastReadMessageId = "last_read_message_id";
  static const String lastReadTime = "last_read_time";
}
class TblUsers {
  static const String userId = "user_id";
  static const String name = "name";
  static const String username = "username";
  static const String email = "email";
  static const String phone = "phone";
  static const String avatar = "avatar";
  static const String bio = "bio";
  static const String lastSeen = "last_seen";
  static const String isOnline = "is_online";
}

/* Table Keys End */
/* Keys End */
