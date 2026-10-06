const Map<String, dynamic> kAcPatchesDataDictionaryJson = {
  "name": "ac_patches",
  "version": 1,
  "tables": {
    "ac_patch_app": {
      "tableName": "ac_patch_app",
      "tableColumns": {
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "name": {
          "columnName": "name",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME"
        }
      }
    },
    "ac_patch_release": {
      "tableName": "ac_patch_release",
      "tableColumns": {
        "release_id": {
          "columnName": "release_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "version": {
          "columnName": "version",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "build_number": {
          "columnName": "build_number",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "platform": {
          "columnName": "platform",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "architecture": {
          "columnName": "architecture",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "flutter_version": {
          "columnName": "flutter_version",
          "columnType": "STRING"
        },
        "dart_version": {
          "columnName": "dart_version",
          "columnType": "STRING"
        },
        "engine_revision": {
          "columnName": "engine_revision",
          "columnType": "STRING"
        },
        "base_release_hash": {
          "columnName": "base_release_hash",
          "columnType": "STRING"
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME"
        }
      }
    },
    "ac_patch": {
      "tableName": "ac_patch",
      "tableColumns": {
        "patch_id": {
          "columnName": "patch_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "release_id": {
          "columnName": "release_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "patch_number": {
          "columnName": "patch_number",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "platform": {
          "columnName": "platform",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "architecture": {
          "columnName": "architecture",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "patch_type": {
          "columnName": "patch_type",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "payload_hash": {
          "columnName": "payload_hash",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "storage_key": {
          "columnName": "storage_key",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "size_bytes": {
          "columnName": "size_bytes",
          "columnType": "INTEGER",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "status": {
          "columnName": "status",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "manifest_json": {
          "columnName": "manifest_json",
          "columnType": "TEXT"
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME"
        }
      }
    },
    "ac_patch_track": {
      "tableName": "ac_patch_track",
      "tableColumns": {
        "track_id": {
          "columnName": "track_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "name": {
          "columnName": "name",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "current_patch_id": {
          "columnName": "current_patch_id",
          "columnType": "STRING"
        },
        "rollout_percentage": {
          "columnName": "rollout_percentage",
          "columnType": "INTEGER",
          "columnProperties": {
            "DEFAULT_VALUE": {"propertyName": "DEFAULT_VALUE", "propertyValue": 100}
          }
        },
        "min_runtime_version": {
          "columnName": "min_runtime_version",
          "columnType": "STRING"
        }
      }
    },
    "ac_patch_device": {
      "tableName": "ac_patch_device",
      "tableColumns": {
        "installation_id": {
          "columnName": "installation_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "platform": {
          "columnName": "platform",
          "columnType": "STRING"
        },
        "architecture": {
          "columnName": "architecture",
          "columnType": "STRING"
        },
        "current_release_id": {
          "columnName": "current_release_id",
          "columnType": "STRING"
        },
        "current_patch_id": {
          "columnName": "current_patch_id",
          "columnType": "STRING"
        },
        "last_seen": {
          "columnName": "last_seen",
          "columnType": "DATETIME"
        }
      }
    },
    "ac_patch_event": {
      "tableName": "ac_patch_event",
      "tableColumns": {
        "event_id": {
          "columnName": "event_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "installation_id": {
          "columnName": "installation_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "patch_id": {
          "columnName": "patch_id",
          "columnType": "STRING"
        },
        "release_id": {
          "columnName": "release_id",
          "columnType": "STRING"
        },
        "event_type": {
          "columnName": "event_type",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "error_message": {
          "columnName": "error_message",
          "columnType": "TEXT"
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME"
        }
      }
    },
    "ac_patch_key": {
      "tableName": "ac_patch_key",
      "tableColumns": {
        "key_id": {
          "columnName": "key_id",
          "columnType": "STRING",
          "columnProperties": {
            "PRIMARY_KEY": {"propertyName": "PRIMARY_KEY", "propertyValue": true},
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "app_id": {
          "columnName": "app_id",
          "columnType": "STRING",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "public_key_base64": {
          "columnName": "public_key_base64",
          "columnType": "TEXT",
          "columnProperties": {
            "NOT_NULL": {"propertyName": "NOT_NULL", "propertyValue": true}
          }
        },
        "private_key_base64": {
          "columnName": "private_key_base64",
          "columnType": "TEXT"
        },
        "is_active": {
          "columnName": "is_active",
          "columnType": "INTEGER",
          "columnProperties": {
            "DEFAULT_VALUE": {"propertyName": "DEFAULT_VALUE", "propertyValue": 1}
          }
        },
        "created_at": {
          "columnName": "created_at",
          "columnType": "DATETIME"
        }
      }
    }
  }
};
