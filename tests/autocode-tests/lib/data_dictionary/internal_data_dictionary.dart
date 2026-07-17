import 'package:ac_data_dictionary/ac_data_dictionary.dart';
/* Keys Start */
/* Table Keys Start */

class Tables {
  static const String accounteaDetails = "accountea_details";
  static const String activityLogs = "activity_logs";
  static const String deviceAuthorizations = "device_authorizations";
  static const String deviceAuthorizedAccountees = "device_authorized_accountees";
  static const String fileContents = "file_contents";
  static const String settings = "settings";
}

class TblAccounteaDetails {
  static const String accounteaDetailId = "accountea_detail_id";
  static const String accounteaDetailKey = "accountea_detail_key";
  static const String accounteaDetailValue = "accountea_detail_value";
}
class TblActivityLogs {
  static const String activityLogId = "activity_log_id";
  static const String activityLogType = "activity_log_type";
  static const String activityLogStartTime = "activity_log_start_time";
  static const String activityLogEndTime = "activity_log_end_time";
  static const String activityLogKey = "activity_log_key";
  static const String deviceId = "device_id";
  static const String activtyLogDetails = "activty_log_details";
}
class TblDeviceAuthorizations {
  static const String deviceAuthorizationId = "device_authorization_id";
  static const String deviceId = "device_id";
  static const String deviceAuthorizationStatus = "device_authorization_status";
  static const String deviceAuthorizationToken = "device_authorization_token";
  static const String deviceAuthorizedOn = "device_authorized_on";
  static const String isRemoteServer = "is_remote_server";
  static const String remoteServerDetails = "remote_server_details";
  static const String deviceName = "device_name";
  static const String lastActiveOn = "last_active_on";
  static const String lastSyncedOn = "last_synced_on";
  static const String lastSyncValue = "last_sync_value";
}
class TblDeviceAuthorizedAccountees {
  static const String deviceAuthorizedAccounteeId = "device_authorized_accountee_id";
  static const String deviceId = "device_id";
  static const String accounteeId = "accountee_id";
  static const String deviceAccounteeAuthorizationToken = "device_accountee_authorization_token";
  static const String deviceAccounteeAuthorizedOn = "device_accountee_authorized_on";
  static const String deviceAccounteeAuthorizationStatus = "device_accountee_authorization_status";
  static const String remoteAccounteeDetails = "remote_accountee_details";
  static const String isRemote = "is_remote";
  static const String isSyncable = "is_syncable";
  static const String lastSyncValue = "last_sync_value";
  static const String syncConfiguration = "sync_configuration";
}
class TblFileContents {
  static const String fileContentId = "file_content_id";
  static const String filePath = "file_path";
  static const String fileContent = "file_content";
  static const String fileContentGroup = "file_content_group";
}
class TblSettings {
  static const String settingId = "setting_id";
  static const String settingKey = "setting_key";
  static const String settingTextValue = "setting_text_value";
  static const String settingNumericValue = "setting_numeric_value";
}

/* Table Keys End */
/* Keys End */


const Map<String,dynamic> DATA_DICTIONARY = {
  AcDataDictionary.keyName : "Accountea Pro Internal",
  AcDataDictionary.keyVersion : 3,
  AcDataDictionary.keyTables : {
    Tables.accounteaDetails : {
      AcDDTable.keyTableName : Tables.accounteaDetails,
      AcDDTable.keyTableColumns : {
        TblAccounteaDetails.accounteaDetailId : {
          AcDDTableColumn.keyColumnName : TblAccounteaDetails.accounteaDetailId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Detail Id"
            },
            AcEnumDDColumnProperty.primaryKey : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
              AcDDTableColumnProperty.keyPropertyValue : true
            }
          }
        },
        TblAccounteaDetails.accounteaDetailKey : {
          AcDDTableColumn.keyColumnName : TblAccounteaDetails.accounteaDetailKey,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Detail Key"
            }
          }
        },
        TblAccounteaDetails.accounteaDetailValue : {
          AcDDTableColumn.keyColumnName : TblAccounteaDetails.accounteaDetailValue,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Detail Value"
            }
          }
        }
      },
      AcDDTable.keyTableProperties : {
        AcEnumDDTableProperty.pluralName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
          AcDDTableProperty.keyPropertyValue : "accountea_details"
        },
        AcEnumDDTableProperty.singularName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
          AcDDTableProperty.keyPropertyValue : "accountea_detail"
        }
      }
    },
    Tables.activityLogs : {
      AcDDTable.keyTableName : Tables.activityLogs,
      AcDDTable.keyTableColumns : {
        TblActivityLogs.activityLogId : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.activityLogId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Log Id"
            },
            AcEnumDDColumnProperty.primaryKey : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
              AcDDTableColumnProperty.keyPropertyValue : true
            }
          }
        },
        TblActivityLogs.activityLogType : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.activityLogType,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Log Type"
            }
          }
        },
        TblActivityLogs.activityLogStartTime : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.activityLogStartTime,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Start Time"
            }
          }
        },
        TblActivityLogs.activityLogEndTime : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.activityLogEndTime,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "End Time"
            }
          }
        },
        TblActivityLogs.activityLogKey : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.activityLogKey,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Log Key"
            }
          }
        },
        TblActivityLogs.deviceId : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.deviceId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.uuid,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Device"
            }
          }
        },
        TblActivityLogs.activtyLogDetails : {
          AcDDTableColumn.keyColumnName : TblActivityLogs.activtyLogDetails,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.json,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Details"
            }
          }
        }
      },
      AcDDTable.keyTableProperties : {
        AcEnumDDTableProperty.pluralName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
          AcDDTableProperty.keyPropertyValue : "activity_logs"
        },
        AcEnumDDTableProperty.singularName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
          AcDDTableProperty.keyPropertyValue : "activity_log"
        }
      }
    },
    Tables.deviceAuthorizations : {
      AcDDTable.keyTableName : Tables.deviceAuthorizations,
      AcDDTable.keyTableColumns : {
        TblDeviceAuthorizations.deviceAuthorizationId : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.deviceAuthorizationId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorization Id"
            },
            AcEnumDDColumnProperty.primaryKey : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
              AcDDTableColumnProperty.keyPropertyValue : true
            },
            AcEnumDDColumnProperty.useForRowLikeFilter : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.useForRowLikeFilter,
              AcDDTableColumnProperty.keyPropertyValue : false
            }
          }
        },
        TblDeviceAuthorizations.deviceId : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.deviceId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.uuid,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Device Id"
            }
          }
        },
        TblDeviceAuthorizations.deviceAuthorizationStatus : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.deviceAuthorizationStatus,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorization Status"
            }
          }
        },
        TblDeviceAuthorizations.deviceAuthorizationToken : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.deviceAuthorizationToken,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorization Token"
            }
          }
        },
        TblDeviceAuthorizations.deviceAuthorizedOn : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.deviceAuthorizedOn,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.timestamp,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorized On"
            }
          }
        },
        TblDeviceAuthorizations.isRemoteServer : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.isRemoteServer,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.yesNo,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Is Remote Server"
            }
          }
        },
        TblDeviceAuthorizations.remoteServerDetails : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.remoteServerDetails,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.json,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Remote Server Details"
            }
          }
        },
        TblDeviceAuthorizations.deviceName : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.deviceName,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Device Name"
            }
          }
        },
        TblDeviceAuthorizations.lastActiveOn : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.lastActiveOn,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Last Active On"
            }
          }
        },
        TblDeviceAuthorizations.lastSyncedOn : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.lastSyncedOn,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Last Synced On"
            }
          }
        },
        TblDeviceAuthorizations.lastSyncValue : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizations.lastSyncValue,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Last Sync Value"
            }
          }
        }
      },
      AcDDTable.keyTableProperties : {
        AcEnumDDTableProperty.pluralName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
          AcDDTableProperty.keyPropertyValue : "device_authorizations"
        },
        AcEnumDDTableProperty.singularName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
          AcDDTableProperty.keyPropertyValue : "device_authorization"
        }
      }
    },
    Tables.deviceAuthorizedAccountees : {
      AcDDTable.keyTableName : Tables.deviceAuthorizedAccountees,
      AcDDTable.keyTableColumns : {
        TblDeviceAuthorizedAccountees.deviceAuthorizedAccounteeId : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.deviceAuthorizedAccounteeId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Device Authorized Accountee Id"
            },
            AcEnumDDColumnProperty.primaryKey : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
              AcDDTableColumnProperty.keyPropertyValue : true
            }
          }
        },
        TblDeviceAuthorizedAccountees.deviceId : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.deviceId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.uuid,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Device"
            }
          }
        },
        TblDeviceAuthorizedAccountees.accounteeId : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.accounteeId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.uuid,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Accountee"
            }
          }
        },
        TblDeviceAuthorizedAccountees.deviceAccounteeAuthorizationToken : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.deviceAccounteeAuthorizationToken,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorization Token"
            }
          }
        },
        TblDeviceAuthorizedAccountees.deviceAccounteeAuthorizedOn : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.deviceAccounteeAuthorizedOn,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.timestamp,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorized On"
            }
          }
        },
        TblDeviceAuthorizedAccountees.deviceAccounteeAuthorizationStatus : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.deviceAccounteeAuthorizationStatus,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Authorization Status"
            }
          }
        },
        TblDeviceAuthorizedAccountees.remoteAccounteeDetails : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.remoteAccounteeDetails,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.json,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Remote Accountee Details"
            }
          }
        },
        TblDeviceAuthorizedAccountees.isRemote : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.isRemote,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.yesNo,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Is Remote"
            }
          }
        },
        TblDeviceAuthorizedAccountees.isSyncable : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.isSyncable,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.yesNo,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Is Syncable"
            }
          }
        },
        TblDeviceAuthorizedAccountees.lastSyncValue : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.lastSyncValue,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Last Sync Value"
            }
          }
        },
        TblDeviceAuthorizedAccountees.syncConfiguration : {
          AcDDTableColumn.keyColumnName : TblDeviceAuthorizedAccountees.syncConfiguration,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.json,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Sync Configuration"
            }
          }
        }
      },
      AcDDTable.keyTableProperties : {
        AcEnumDDTableProperty.pluralName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
          AcDDTableProperty.keyPropertyValue : "device_authorized_accountees"
        },
        AcEnumDDTableProperty.singularName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
          AcDDTableProperty.keyPropertyValue : "device_authorized_accountee"
        }
      }
    },
    Tables.fileContents : {
      AcDDTable.keyTableName : Tables.fileContents,
      AcDDTable.keyTableColumns : {
        TblFileContents.fileContentId : {
          AcDDTableColumn.keyColumnName : TblFileContents.fileContentId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "File Id"
            },
            AcEnumDDColumnProperty.primaryKey : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
              AcDDTableColumnProperty.keyPropertyValue : true
            }
          }
        },
        TblFileContents.filePath : {
          AcDDTableColumn.keyColumnName : TblFileContents.filePath,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "File Path"
            }
          }
        },
        TblFileContents.fileContent : {
          AcDDTableColumn.keyColumnName : TblFileContents.fileContent,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "File Content"
            }
          }
        },
        TblFileContents.fileContentGroup : {
          AcDDTableColumn.keyColumnName : TblFileContents.fileContentGroup,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "File Content Group"
            }
          }
        }
      },
      AcDDTable.keyTableProperties : {
        AcEnumDDTableProperty.pluralName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
          AcDDTableProperty.keyPropertyValue : "file_contents"
        },
        AcEnumDDTableProperty.singularName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
          AcDDTableProperty.keyPropertyValue : "file_content"
        }
      }
    },
    Tables.settings : {
      AcDDTable.keyTableName : Tables.settings,
      AcDDTable.keyTableColumns : {
        TblSettings.settingId : {
          AcDDTableColumn.keyColumnName : TblSettings.settingId,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Setting Id"
            },
            AcEnumDDColumnProperty.primaryKey : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
              AcDDTableColumnProperty.keyPropertyValue : true
            }
          }
        },
        TblSettings.settingKey : {
          AcDDTableColumn.keyColumnName : TblSettings.settingKey,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Setting Key"
            }
          }
        },
        TblSettings.settingTextValue : {
          AcDDTableColumn.keyColumnName : TblSettings.settingTextValue,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Text Value"
            }
          }
        },
        TblSettings.settingNumericValue : {
          AcDDTableColumn.keyColumnName : TblSettings.settingNumericValue,
          AcDDTableColumn.keyColumnType : AcEnumDDColumnType.double_,
          AcDDTableColumn.keyColumnProperties : {
            AcEnumDDColumnProperty.columnTitle : {
              AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
              AcDDTableColumnProperty.keyPropertyValue : "Numeric Value"
            }
          }
        }
      },
      AcDDTable.keyTableProperties : {
        AcEnumDDTableProperty.pluralName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
          AcDDTableProperty.keyPropertyValue : "settings"
        },
        AcEnumDDTableProperty.singularName : {
          AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
          AcDDTableProperty.keyPropertyValue : "setting"
        }
      }
    }
  },
  AcDataDictionary.keyViews : {

  },
  AcDataDictionary.keyRelationships : [
    {
      AcDDRelationship.keySourceTable : Tables.deviceAuthorizations,
      AcDDRelationship.keySourceColumn : TblDeviceAuthorizations.deviceId,
      AcDDRelationship.keyDestinationTable : Tables.deviceAuthorizedAccountees,
      AcDDRelationship.keyDestinationColumn : TblDeviceAuthorizedAccountees.deviceId,
      AcDDRelationship.keyCascadeDeleteDestination : false,
      AcDDRelationship.keyCascadeDeleteSource : false
    },
    {
      AcDDRelationship.keySourceTable : Tables.deviceAuthorizations,
      AcDDRelationship.keySourceColumn : TblDeviceAuthorizations.deviceId,
      AcDDRelationship.keyDestinationTable : Tables.activityLogs,
      AcDDRelationship.keyDestinationColumn : TblActivityLogs.deviceId,
      AcDDRelationship.keyCascadeDeleteDestination : false,
      AcDDRelationship.keyCascadeDeleteSource : false
    }
  ],
  AcDataDictionary.keyTriggers : {

  },
  AcDataDictionary.keyStoredProcedures : {

  },
  AcDataDictionary.keyFunctions : {

  }
};
