import 'package:ac_data_dictionary/ac_data_dictionary.dart';
/* Keys Start */
/* Table Keys Start */

class Tables {
	static const String acSyncChangeLogs = "_ac_sync_change_logs";
	static const String acSyncDetails = "_ac_sync_details";
	static const String acSyncDeviceLogs = "_ac_sync_device_logs";
	static const String acSyncDevices = "_ac_sync_devices";
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

/* Table Keys End */
/* Keys End */


const Map<String,dynamic> DATA_DICTIONARY = {
	AcDataDictionary.keyName : "Autocode Sync",
	AcDataDictionary.keyVersion : 0,
	AcDataDictionary.keyTables : {
		Tables.acSyncChangeLogs : {
			AcDDTable.keyTableName : Tables.acSyncChangeLogs,
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
		Tables.acSyncDetails : {
			AcDDTable.keyTableName : Tables.acSyncDetails,
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
		Tables.acSyncDeviceLogs : {
			AcDDTable.keyTableName : Tables.acSyncDeviceLogs,
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
		Tables.acSyncDevices : {
			AcDDTable.keyTableName : Tables.acSyncDevices,
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
