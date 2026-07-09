import 'package:ac_data_dictionary/ac_data_dictionary.dart';
/* Keys Start */
/* Table Keys Start */

class AcSyncTables {
	static const String acSyncChangeLogs = "_ac_sync_change_logs";
	static const String acSyncDetails = "_ac_sync_details";
	static const String acSyncDeviceLogs = "_ac_sync_device_logs";
	static const String acSyncDevices = "_ac_sync_devices";
	static const String acSyncSessions = "_ac_sync_sessions";
}

class TblAcSyncChangeLogs {
	static const String syncChangeLogId = "sync_change_log_id";
	static const String tableName = "table_name";
	static const String rowId = "row_id";
	static const String rowOperation = "row_operation";
	static const String operationTimestamp = "operation_timestamp";
	static const String rowPayload = "row_payload";
}
class TblAcSyncDetails {
	static const String syncDetailId = "sync_detail_id";
	static const String syncDetailKey = "sync_detail_key";
	static const String syncDetailStringValue = "sync_detail_string_value";
	static const String syncDetailNumericValue = "sync_detail_numeric_value";
}
class TblAcSyncDeviceLogs {
	static const String syncDeviceLogId = "sync_device_log_id";
	static const String syncDeviceId = "sync_device_id";
	static const String startTimestamp = "start_timestamp";
	static const String endTimestamp = "end_timestamp";
	static const String oldSyncChangeLogId = "old_sync_change_log_id";
	static const String newSyncChangeLogId = "new_sync_change_log_id";
	static const String syncOperationResult = "sync_operation_result";
}
class TblAcSyncDevices {
	static const String syncDeviceId = "sync_device_id";
	static const String isSourceOfTruth = "is_source_of_truth";
	static const String lastSyncedOn = "last_synced_on";
	static const String lastSyncChangeLogId = "last_sync_change_log_id";
}
class TblAcSyncSessions {
	static const String syncSessionId = "sync_session_id";
	static const String clientIdentifier = "client_identifier";
	static const String status = "status";
	static const String incomingCheckpoint = "incoming_checkpoint";
	static const String incomingTargetCheckpoint = "incoming_target_checkpoint";
	static const String incomingCompleted = "incoming_completed";
	static const String outgoingCheckpoint = "outgoing_checkpoint";
	static const String outgoingTargetCheckpoint = "outgoing_target_checkpoint";
	static const String outgoingCompleted = "outgoing_completed";
	static const String metadata = "metadata";
	static const String createdAt = "created_at";
	static const String updatedAt = "updated_at";
	static const String lastActivityAt = "last_activity_at";
	static const String expiresAt = "expires_at";
}

/* Table Keys End */
/* Keys End */


const Map<String,dynamic> AC_SYNC_DATA_DICTIONARY = {
	AcDataDictionary.keyName : "Autocode Sync",
	AcDataDictionary.keyVersion : 1,
	AcDataDictionary.keyTables : {
		AcSyncTables.acSyncChangeLogs : {
			AcDDTable.keyTableName : AcSyncTables.acSyncChangeLogs,
			AcDDTable.keyTableColumns : {
				TblAcSyncChangeLogs.syncChangeLogId : {
					AcDDTableColumn.keyColumnName : TblAcSyncChangeLogs.syncChangeLogId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Change Log Id"
						},
						AcEnumDDColumnProperty.primaryKey : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
							AcDDTableColumnProperty.keyPropertyValue : true
						}
					}
				},
				TblAcSyncChangeLogs.tableName : {
					AcDDTableColumn.keyColumnName : TblAcSyncChangeLogs.tableName,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Table Name"
						}
					}
				},
				TblAcSyncChangeLogs.rowId : {
					AcDDTableColumn.keyColumnName : TblAcSyncChangeLogs.rowId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Row Id"
						}
					}
				},
				TblAcSyncChangeLogs.rowOperation : {
					AcDDTableColumn.keyColumnName : TblAcSyncChangeLogs.rowOperation,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Row Operation"
						}
					}
				},
				TblAcSyncChangeLogs.operationTimestamp : {
					AcDDTableColumn.keyColumnName : TblAcSyncChangeLogs.operationTimestamp,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Operation Timestamp"
						}
					}
				},
				TblAcSyncChangeLogs.rowPayload : {
					AcDDTableColumn.keyColumnName : TblAcSyncChangeLogs.rowPayload,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.json,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Row Payload"
						},
						AcEnumDDColumnProperty.useForRowLikeFilter : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.useForRowLikeFilter,
							AcDDTableColumnProperty.keyPropertyValue : false
						}
					}
				}			
			},
			AcDDTable.keyTableProperties : {
				AcEnumDDTableProperty.pluralName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
					AcDDTableProperty.keyPropertyValue : "sync_change_logs"
				},
				AcEnumDDTableProperty.singularName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
					AcDDTableProperty.keyPropertyValue : "sync_change_log"
				}
			}
		},
		AcSyncTables.acSyncDetails : {
			AcDDTable.keyTableName : AcSyncTables.acSyncDetails,
			AcDDTable.keyTableColumns : {
				TblAcSyncDetails.syncDetailId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDetails.syncDetailId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Detail Id"
						},
						AcEnumDDColumnProperty.primaryKey : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
							AcDDTableColumnProperty.keyPropertyValue : true
						}
					}
				},
				TblAcSyncDetails.syncDetailKey : {
					AcDDTableColumn.keyColumnName : TblAcSyncDetails.syncDetailKey,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Detail Key"
						}
					}
				},
				TblAcSyncDetails.syncDetailStringValue : {
					AcDDTableColumn.keyColumnName : TblAcSyncDetails.syncDetailStringValue,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.text,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Detail String Value"
						}
					}
				},
				TblAcSyncDetails.syncDetailNumericValue : {
					AcDDTableColumn.keyColumnName : TblAcSyncDetails.syncDetailNumericValue,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.double_,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Detail Numeric Value"
						}
					}
				}			
			},
			AcDDTable.keyTableProperties : {
				AcEnumDDTableProperty.pluralName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
					AcDDTableProperty.keyPropertyValue : "sync_details"
				},
				AcEnumDDTableProperty.singularName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
					AcDDTableProperty.keyPropertyValue : "sync_detail"
				}
			}
		},
		AcSyncTables.acSyncDeviceLogs : {
			AcDDTable.keyTableName : AcSyncTables.acSyncDeviceLogs,
			AcDDTable.keyTableColumns : {
				TblAcSyncDeviceLogs.syncDeviceLogId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.syncDeviceLogId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.autoIncrement,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Device Log Id"
						},
						AcEnumDDColumnProperty.primaryKey : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
							AcDDTableColumnProperty.keyPropertyValue : true
						}
					}
				},
				TblAcSyncDeviceLogs.syncDeviceId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.syncDeviceId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.uuid,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Device Id"
						}
					}
				},
				TblAcSyncDeviceLogs.startTimestamp : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.startTimestamp,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Start Timestamp"
						}
					}
				},
				TblAcSyncDeviceLogs.endTimestamp : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.endTimestamp,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "End Timestamp"
						}
					}
				},
				TblAcSyncDeviceLogs.oldSyncChangeLogId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.oldSyncChangeLogId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Old Sync Change Log Id"
						}
					}
				},
				TblAcSyncDeviceLogs.newSyncChangeLogId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.newSyncChangeLogId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "New Sync Change Log Id"
						}
					}
				},
				TblAcSyncDeviceLogs.syncOperationResult : {
					AcDDTableColumn.keyColumnName : TblAcSyncDeviceLogs.syncOperationResult,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Operation Result"
						}
					}
				}			
			},
			AcDDTable.keyTableProperties : {
				AcEnumDDTableProperty.pluralName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
					AcDDTableProperty.keyPropertyValue : "sync_device_logs"
				},
				AcEnumDDTableProperty.singularName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
					AcDDTableProperty.keyPropertyValue : "sync_device_log"
				}
			}
		},
		AcSyncTables.acSyncDevices : {
			AcDDTable.keyTableName : AcSyncTables.acSyncDevices,
			AcDDTable.keyTableColumns : {
				TblAcSyncDevices.syncDeviceId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDevices.syncDeviceId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.uuid,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Device Id"
						},
						AcEnumDDColumnProperty.primaryKey : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
							AcDDTableColumnProperty.keyPropertyValue : true
						}
					}
				},
				TblAcSyncDevices.isSourceOfTruth : {
					AcDDTableColumn.keyColumnName : TblAcSyncDevices.isSourceOfTruth,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.yesNo,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Is Source of Truth?"
						}
					}
				},
				TblAcSyncDevices.lastSyncedOn : {
					AcDDTableColumn.keyColumnName : TblAcSyncDevices.lastSyncedOn,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Last Synced On"
						}
					}
				},
				TblAcSyncDevices.lastSyncChangeLogId : {
					AcDDTableColumn.keyColumnName : TblAcSyncDevices.lastSyncChangeLogId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Last Sync Change Log Id"
						}
					}
				}			
			},
			AcDDTable.keyTableProperties : {
				AcEnumDDTableProperty.pluralName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
					AcDDTableProperty.keyPropertyValue : "sync_devices"
				},
				AcEnumDDTableProperty.singularName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
					AcDDTableProperty.keyPropertyValue : "sync_device"
				}
			}
		},
		AcSyncTables.acSyncSessions : {
			AcDDTable.keyTableName : AcSyncTables.acSyncSessions,
			AcDDTable.keyTableColumns : {
				TblAcSyncSessions.syncSessionId : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.syncSessionId,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Sync Session Id"
						},
						AcEnumDDColumnProperty.primaryKey : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.primaryKey,
							AcDDTableColumnProperty.keyPropertyValue : true
						}
					}
				},
				TblAcSyncSessions.clientIdentifier : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.clientIdentifier,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Client Identifier"
						}
					}
				},
				TblAcSyncSessions.status : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.status,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.string,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Status"
						}
					}
				},
				TblAcSyncSessions.incomingCheckpoint : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.incomingCheckpoint,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Incoming Checkpoint"
						}
					}
				},
				TblAcSyncSessions.incomingTargetCheckpoint : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.incomingTargetCheckpoint,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Incoming Target Checkpoint"
						}
					}
				},
				TblAcSyncSessions.incomingCompleted : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.incomingCompleted,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.yesNo,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Incoming Completed"
						}
					}
				},
				TblAcSyncSessions.outgoingCheckpoint : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.outgoingCheckpoint,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Outgoing Checkpoint"
						}
					}
				},
				TblAcSyncSessions.outgoingTargetCheckpoint : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.outgoingTargetCheckpoint,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.integer,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Outgoing Target Checkpoint"
						}
					}
				},
				TblAcSyncSessions.outgoingCompleted : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.outgoingCompleted,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.yesNo,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Outgoing Completed"
						}
					}
				},
				TblAcSyncSessions.metadata : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.metadata,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.json,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Metadata"
						}
					}
				},
				TblAcSyncSessions.createdAt : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.createdAt,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Created At"
						}
					}
				},
				TblAcSyncSessions.updatedAt : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.updatedAt,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Updated At"
						}
					}
				},
				TblAcSyncSessions.lastActivityAt : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.lastActivityAt,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Last Activity At"
						}
					}
				},
				TblAcSyncSessions.expiresAt : {
					AcDDTableColumn.keyColumnName : TblAcSyncSessions.expiresAt,
					AcDDTableColumn.keyColumnType : AcEnumDDColumnType.datetime,
					AcDDTableColumn.keyColumnProperties : {
						AcEnumDDColumnProperty.columnTitle : {
							AcDDTableColumnProperty.keyPropertyName : AcEnumDDColumnProperty.columnTitle,
							AcDDTableColumnProperty.keyPropertyValue : "Expires At"
						}
					}
				}
			},
			AcDDTable.keyTableProperties : {
				AcEnumDDTableProperty.pluralName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.pluralName,
					AcDDTableProperty.keyPropertyValue : "sync_sessions"
				},
				AcEnumDDTableProperty.singularName : {
					AcDDTableProperty.keyPropertyName : AcEnumDDTableProperty.singularName,
					AcDDTableProperty.keyPropertyValue : "sync_session"
				}
			}
		}
	},
	AcDataDictionary.keyViews : {

	},
	AcDataDictionary.keyRelationships : [

	],
	AcDataDictionary.keyTriggers : {

	},
	AcDataDictionary.keyStoredProcedures : {

	},
	AcDataDictionary.keyFunctions : {

	}
};
