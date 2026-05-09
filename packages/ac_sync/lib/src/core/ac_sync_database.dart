import 'dart:convert';

import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

class AcSyncDatabase {
  AcBaseSqlDao? dao;
  Map<String, AcSyncDefinition> syncDefinitions = {};
  AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;
  String? deviceId;
  bool isSyncing = false;
  bool isDestination = false;
  void Function()? onSyncStart;
  void Function()? onSyncComplete;
  void Function({required AcSyncProgress progress})? onSyncProgress;
  AcLogger logger = AcLogger(logType: AcEnumLogType.console, logMessages: true);

  AcSyncDatabase(
      {this.dao, this.databaseType = AcEnumSqlDatabaseType.unknown,}) {
  }

  Future<AcResult> _initSchemaManager() async {
    logger.log("[AcSyncDatabase|$isDestination]   Initializing Schema Manager...");
    var databaseManager = AcSyncDatabaseManager();
    databaseManager.dao = dao;
    databaseManager.databaseType = databaseType;
    var result = await databaseManager.initAcSyncDatabase();
    logger.log(
        "[AcSyncDatabase|$isDestination]  Schema Manager initialization ${result.isSuccess()
            ? 'successful'
            : 'failed: ' + result.message}");
    return result;
  }

  Future<AcResult> _initTriggers() async {
    logger.log("[AcSyncDatabase|$isDestination]   Initializing Triggers...");
    AcResult result = AcResult();
    var databaseManager = AcSyncDatabaseManager();

    Map<String, AcSyncTableDefinition> tableDefinitionsMap = {};
    for (var definition in syncDefinitions.values) {
      for (var tableDef in definition.tableDefinitions) {
        tableDefinitionsMap.putIfAbsent(tableDef.tableName, () => tableDef);
      }
    }

    logger.log(
        "[AcSyncDatabase|$isDestination]  Creating triggers for tables: ${tableDefinitionsMap
            .keys.join(', ')}");

    await databaseManager.createSyncTriggers(
        dao: dao,
        tableDefinitions: tableDefinitionsMap.values.toList(),
        databaseType: databaseType
    );

    result.setSuccess();
    logger.log("[AcSyncDatabase|$isDestination]   Triggers initialized.");
    return result;
  }

  Future<AcResult> applySyncChanges({required AcSyncChanges changes}) async {
    AcResult result = AcResult();
    logger.log("[AcSyncDatabase|$isDestination]   Applying sync changes...");
    if (dao == null) {
      logger.log("[AcSyncDatabase|$isDestination]   DAO not set, cannot apply changes.");
      result.setFailure(message: "DAO not set");
      return result;
    }

    try {
      logger.log(
          "[AcSyncDatabase|$isDestination]  Disabling foreign keys for sync application...");
      await dao!.executeStatement(statement: "PRAGMA foreign_keys = OFF;");
      for (var tableName in changes.tableChanges.keys) {
        var tableChanges = changes.tableChanges[tableName]!;
        logger.log(
            "[AcSyncDatabase|$isDestination]  Table '$tableName' - Deletes: ${tableChanges
                .rowsToDelete.length}, Inserts: ${tableChanges.rowsToInsert
                .length}, Updates: ${tableChanges.rowsToUpdate.length}");

        // Find PK field from definitions
        String pkField = "id";
        bool pkFound = false;
        for (var def in syncDefinitions.values) {
          for (var tDef in def.tableDefinitions) {
            if (tDef.tableName == tableName) {
              pkField = tDef.primaryKeyField;
              pkFound = true;
              break;
            }
          }
          if (pkFound) break;
        }
        logger.log(
            "[AcSyncDatabase|$isDestination]  Table '$tableName' - Primary key field used: $pkField ${pkFound
                ? ''
                : '(Defaulted)'}");

        // 1. Delete rows
        if (tableChanges.rowsToDelete.isNotEmpty) {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Table '$tableName' - Executing ${tableChanges
                  .rowsToDelete.length} deletes...");
          for (var rowChange in tableChanges.rowsToDelete) {
            if (rowChange.rowId != null) {
              logger.log(
                  "[AcSyncDatabase|$isDestination]  Table '$tableName' - Deleting row ID: ${rowChange
                      .rowId}");
              await dao!.deleteRows(
                tableName: tableName,
                condition: "$pkField = '${rowChange.rowId}'",
              );
            } else {
              logger.warn(
                  "[AcSyncDatabase|$isDestination]  Table '$tableName' - Row ID is null during delete operation, skipping.");
            }
          }
        }

        // 2. Insert rows
        if (tableChanges.rowsToInsert.isNotEmpty) {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Table '$tableName' - Executing ${tableChanges
                  .rowsToInsert.length} inserts...");
          for (var rowChange in tableChanges.rowsToInsert) {
            if (rowChange.row != null) {
              logger.log(
                  "[AcSyncDatabase|$isDestination]  Table '$tableName' - Inserting row ID: ${rowChange
                      .rowId ?? 'unknown'}");
              await dao!.insertRow(
                tableName: tableName,
                row: rowChange.row!,
              );
            } else {
              logger.warn(
                  "[AcSyncDatabase|$isDestination]  Table '$tableName' - Row data is null during insert operation, skipping.");
            }
          }
        }

        // 3. Update rows
        if (tableChanges.rowsToUpdate.isNotEmpty) {
          for (var rowChange in tableChanges.rowsToUpdate) {
            if (rowChange.row != null) {
              var rowId = rowChange.row![pkField];
              logger.log(
                  "[AcSyncDatabase|$isDestination]  Table '$tableName' - Updating row ID: $rowId");
              await dao!.updateRow(
                tableName: tableName,
                row: rowChange.row!,
                condition: "$pkField = '$rowId'",
              );
            } else {
              logger.warn(
                  "[AcSyncDatabase|$isDestination]  Table '$tableName' - Row data is null during update operation, skipping.");
            }
          }
        }
      }
      logger.log("[AcSyncDatabase|$isDestination]   Re-enabling foreign keys...");
      await dao!.executeStatement(statement: "PRAGMA foreign_keys = ON;");
      result.setSuccess();
      logger.log("[AcSyncDatabase|$isDestination]   Sync changes applied successfully.");
    } catch (e, stack) {
      logger.log("[AcSyncDatabase|$isDestination]   Error applying sync changes: $e");
      result.setException(exception: e, stackTrace: stack);
    }
    return result;
  }

  Future<AcResult> deleteSyncedRows({required AcSyncChanges changes, String definitionName = 'default'}) async {
    AcResult result = AcResult();
    logger.log(
        "[AcSyncDatabase|$isDestination]  Deleting synced rows for definition: $definitionName");
    if (dao == null) {
      logger.error("[AcSyncDatabase|$isDestination]  DAO not set, cannot delete synced rows.");
      return result.setFailure(message: "DAO not set");
    }

    if (!syncDefinitions.containsKey(definitionName)) {
      logger.error("[AcSyncDatabase|$isDestination]  Definition '$definitionName' not found.");
      return result.setFailure(message: "Definition not found");
    }

    final definition = syncDefinitions[definitionName]!;
    try {
      for (var tableName in changes.tableChanges.keys) {
        final tableDef = definition.tableDefinitions.firstWhere((t) =>
        t.tableName == tableName);
        if (tableDef != null && tableDef.deleteAfterSyncFromDestination) {
          final tableChanges = changes.tableChanges[tableName]!;
          final pkField = tableDef.primaryKeyField.isNotEmpty ? tableDef
              .primaryKeyField : 'id';

          // Rows that were successfully sent (inserts and updates)
          final rowsToDelete = [
            ...tableChanges.rowsToInsert,
            ...tableChanges.rowsToUpdate
          ];

          if (rowsToDelete.isNotEmpty) {
            logger.log("[AcSyncDatabase|$isDestination]   Deleting ${rowsToDelete
                .length} synced rows from '$tableName' as per deleteAfterSyncFromDestination flag.");
            for (var rowChange in rowsToDelete) {
              final rowId = rowChange.rowId ??
                  (rowChange.row != null ? rowChange.row![pkField] : null);
              if (rowId != null) {
                logger.log(
                    "[AcSyncDatabase|$isDestination]  Table '$tableName' - Deleting synced row ID: $rowId");
                await dao!.deleteRows(
                  tableName: tableName,
                  condition: "$pkField = '$rowId'",
                );
              } else {
                logger.warn(
                    "[AcSyncDatabase|$isDestination]  Table '$tableName' - Row ID is null during synced row deletion, skipping.");
              }
            }
          } else {
            logger.log(
                "[AcSyncDatabase|$isDestination]  Table '$tableName' - No synced rows to delete.");
          }
        }
        else {
          logger.warn("[AcSyncDatabase|$isDestination]  Table '$tableName' not found in definition, skipping synced row deletion.");
        }
      }
      result.setSuccess();
      logger.log("[AcSyncDatabase|$isDestination]   Finished deleting synced rows.");
    } catch (e, stack) {
    logger.log("[AcSyncDatabase|$isDestination]   Error deleting synced rows: $e");
    result.setException(exception: e, stackTrace: stack);
    }
    return
    result;
  }

  Future<AcResult> getLastChangeLogId() async {
    AcResult result = AcResult();
    if (dao == null) {
      logger.error(
          "[AcSyncDatabase|$isDestination]  DAO not set, cannot get last change log ID.");
      result.setFailure(message: "DAO not set");
      return result;
    }
    var selectResult = await dao!.getRows(
        statement: "SELECT MAX(${TblAcSyncChangeLogs
            .syncChangeLogId}) AS ${TblAcSyncChangeLogs
            .syncChangeLogId} FROM ${AcSyncTables.acSyncChangeLogs}"
    );
    if (selectResult.isSuccess()) {
      result.setSuccess();
      result.value =
          selectResult.rows.first[TblAcSyncChangeLogs.syncChangeLogId] ?? 0;
      logger.log("[AcSyncDatabase|$isDestination]   Last change log ID: ${result.value}");
    }
    else {
      logger.error(
          "[AcSyncDatabase|$isDestination]  Failed to get last change log ID: ${selectResult
              .message}");
      result.setFromResult(result: selectResult);
    }
    return result;
  }

  Future<AcResult> getSyncChanges(
      {int lastSyncId = -1, String definitionName = 'default',}) async {
    AcResult result = AcResult();
    logger.log(
        "[AcSyncDatabase|$isDestination]  Getting sync changes since ID: $lastSyncId for definition: $definitionName");
    if (dao == null) {
      logger.log("[AcSyncDatabase|$isDestination]   DAO not set, cannot get changes.");
      result.setFailure(message: "DAO not set");
      return result;
    }

    if (syncDefinitions.containsKey(definitionName)) {
      logger.log(
          "[AcSyncDatabase|$isDestination]  Definition '$definitionName' found. Fetching change logs...");
      // 1. Fetch all logs since lastSyncId
      var logsResult = await dao!.getRows(
        statement: "SELECT * FROM ${AcSyncTables.acSyncChangeLogs} "
            "WHERE ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId "
            "ORDER BY ${TblAcSyncChangeLogs.syncChangeLogId} ASC",
      );

      if (!logsResult.isSuccess()) {
        logger.log("[AcSyncDatabase|$isDestination]   Failed to get change logs: ${logsResult
            .message}");
        result.setFromResult(result: logsResult);
        return result;
      }

      logger.log(
          "[AcSyncDatabase|$isDestination]  Change logs rows count :${logsResult.rows.length}");

      AcSyncChanges changes = AcSyncChanges(tableChanges: {});
      int maxLogId = lastSyncId;

      // Group logs by table and rowId to merge changes
      Map<String, Map<String, List<Map<String, dynamic>>>> groupedLogs = {};

      for (var log in logsResult.rows) {
        int logId = log.getInt(TblAcSyncChangeLogs.syncChangeLogId);
        if (logId > maxLogId) maxLogId = logId;

        String tableName = log.getString(TblAcSyncChangeLogs.tableName);
        String rowId = log.getString(TblAcSyncChangeLogs.rowId);
        String operation = log.getString(TblAcSyncChangeLogs.rowOperation);

        logger.log(
            "[AcSyncDatabase|$isDestination]  Processing log ID: $logId - Table: $tableName - Row: $rowId - Op: $operation");

        groupedLogs.putIfAbsent(tableName, () => {});
        groupedLogs[tableName]!.putIfAbsent(rowId, () => []);
        groupedLogs[tableName]![rowId]!.add(log);
      }

      AcSyncDefinition definition = syncDefinitions[definitionName]!;
      for (var tableDefinition in definition.tableDefinitions) {
        String tableName = tableDefinition.tableName;
        if (!groupedLogs.containsKey(tableName)) {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Table '$tableName' has no new change logs, skipping.");
          continue;
        }

        bool continueOperation = (tableDefinition.syncToSource &&
            isDestination) ||
            (tableDefinition.syncToDestination && !isDestination);
        if (continueOperation) {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Processing table '$tableName' for definition '$definitionName'...");
          var tableChanges = AcSyncTableChanges();
          var rowsForTable = groupedLogs[tableName]!;

          for (var rowId in rowsForTable.keys) {
            var logs = rowsForTable[rowId]!;

            String? finalOp;
            Map<String, dynamic> mergedPayload = {};
            bool wasInsertedInRange = false;

            for (var log in logs) {
              String op = log.getString(TblAcSyncChangeLogs.rowOperation);
              String? payloadStr = log.getString(
                  TblAcSyncChangeLogs.rowPayload);
              Map<String, dynamic> payload = {};
              if (payloadStr != null && payloadStr.isNotEmpty) {
                try {
                  payload = jsonDecode(payloadStr);
                } catch (e) {
                  logger.log(
                      "[AcSyncDatabase|$isDestination]  Error decoding payload for table $tableName row $rowId: $e");
                }
              }

              if (op == 'INSERT') {
                logger.log(
                    "[AcSyncDatabase|$isDestination]  Table '$tableName' Row '$rowId' - Merging INSERT");
                finalOp = 'INSERT';
                wasInsertedInRange = true;
                mergedPayload.addAll(payload);
              } else if (op == 'UPDATE') {
                logger.log(
                    "[AcSyncDatabase|$isDestination]  Table '$tableName' Row '$rowId' - Merging UPDATE");
                if (finalOp == null || finalOp == 'UPDATE') {
                  finalOp = 'UPDATE';
                }
                mergedPayload.addAll(payload);
              } else if (op == 'DELETE') {
                logger.log(
                    "[AcSyncDatabase|$isDestination]  Table '$tableName' Row '$rowId' - Merging DELETE");
                finalOp = 'DELETE';
                mergedPayload = {};
              }
            }

            if (finalOp == 'DELETE') {
              if (!wasInsertedInRange) {
                tableChanges.rowsToDelete.add(
                    AcSyncTableRowChange(operation: 'DELETE', rowId: rowId));
              } else {
                logger.log(
                    "[AcSyncDatabase|$isDestination]  Table '$tableName' Row '$rowId' - Row was inserted and deleted in the same range, skipping.");
              }
            } else if (finalOp == 'INSERT') {
              mergedPayload[tableDefinition.primaryKeyField] = rowId;
              tableChanges.rowsToInsert.add(AcSyncTableRowChange(
                  operation: 'INSERT', row: mergedPayload, rowId: rowId));
            } else if (finalOp == 'UPDATE') {
              mergedPayload[tableDefinition.primaryKeyField] = rowId;
              tableChanges.rowsToUpdate.add(AcSyncTableRowChange(
                  operation: 'UPDATE', row: mergedPayload, rowId: rowId));
            }
          }

          if (tableChanges.rowsToDelete.isNotEmpty ||
              tableChanges.rowsToInsert.isNotEmpty ||
              tableChanges.rowsToUpdate.isNotEmpty) {
            logger.log(
                "[AcSyncDatabase|$isDestination]  Collected merged changes for '$tableName' - Del: ${tableChanges
                    .rowsToDelete.length}, Ins: ${tableChanges.rowsToInsert
                    .length}, Upd: ${tableChanges.rowsToUpdate.length}");
            changes.tableChanges[tableName] = tableChanges;
          }
        } else {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Skipping table '$tableName' because sync direction is not applicable (syncToSource: ${tableDefinition
                  .syncToSource}, syncToDestination: ${tableDefinition
                  .syncToDestination}, isDestination: $isDestination)");
        }
      }
      changes.lastChangeLogId = maxLogId;
      result.setSuccess(value: changes);
    }
    else {
      logger.log(
          "[AcSyncDatabase|$isDestination]  Definition '$definitionName' does not exist.");
      result.setFailure(message: 'Definition does not exist');
    }
    return result;
  }

  Future<AcResult> reinitialize() async {
    logger.log(
        "[AcSyncDatabase|$isDestination]  Reinitializing database (dropping and recreating triggers)...");
    AcResult result = AcResult();

    if (dao == null) {
      logger.log("[AcSyncDatabase|$isDestination]   DAO not set, cannot reinitialize.");
      result.setFailure(message: "DAO not set");
      return result;
    }

    var databaseManager = AcSyncDatabaseManager();

    Map<String, AcSyncTableDefinition> tableDefinitionsMap = {};
    for (var definition in syncDefinitions.values) {
      for (var tableDef in definition.tableDefinitions) {
        tableDefinitionsMap.putIfAbsent(tableDef.tableName, () => tableDef);
      }
    }

    try {
      // 1. Drop Triggers
      logger.log(
          "[AcSyncDatabase|$isDestination]  Dropping triggers for tables: ${tableDefinitionsMap
              .keys.join(', ')}");
      await databaseManager.dropSyncTriggers(
          dao: dao,
          tableDefinitions: tableDefinitionsMap.values.toList(),
          databaseType: databaseType
      );

      // 2. Recreate Triggers
      result = await _initTriggers();

      if (result.isSuccess()) {
        logger.log("[AcSyncDatabase|$isDestination]   Reinitialization successful.");
      }
    } catch (e, stack) {
      logger.log("[AcSyncDatabase|$isDestination]   Error during reinitialization: $e");
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }

  Future<AcResult> initialize({int syncVersion = 0}) async {
    logger.log("[AcSyncDatabase|$isDestination]   Initializing database...");
    AcResult result = AcResult();
    try {
      // Register sync data dictionary
      AcDataDictionary.registerDataDictionary(
        jsonData: AC_SYNC_DATA_DICTIONARY,
        dataDictionaryName: AcSyncDatabaseManager.dataDictionaryName,
      );

      result = await _initSchemaManager();
      if (result.isSuccess()) {
        logger.log("[AcSyncDatabase|$isDestination]   Reading sync details...");
        AcSqlDaoResult selectResult = await dao!.getRows(
            statement: "SELECT ${TblAcSyncDetails
                .syncDetailKey}, ${TblAcSyncDetails
                .syncDetailStringValue} FROM ${AcSyncTables
                .acSyncDetails} WHERE ${TblAcSyncDetails
                .syncDetailKey} IN (@keys);", parameters: {
          "@keys": [
            AcSyncKeys.keyDeviceType,
            AcSyncKeys.keyDeviceId,
            AcSyncKeys.keySyncVersion
          ]
        });

        int dbVersion = 0;
        bool deviceSet = false,
            typeSet = false,
            versionSet = false;

        if (selectResult.isSuccess()) {
          for (var row in selectResult.rows) {
            String key = row.getString(TblAcSyncDetails.syncDetailKey);
            String val = row.getString(TblAcSyncDetails.syncDetailStringValue);
            if (key == AcSyncKeys.keyDeviceId) {
              deviceSet = true;
              this.deviceId = val;
              logger.log("[AcSyncDatabase|$isDestination]   Device ID: ${this.deviceId}");
            }
            else if (key == AcSyncKeys.keyDeviceType) {
              typeSet = true;
              logger.log("[AcSyncDatabase|$isDestination]   Device Type: $val");
            }
            else if (key == AcSyncKeys.keySyncVersion) {
              versionSet = true;
              dbVersion = int.tryParse(
                  row.getString(TblAcSyncDetails.syncDetailNumericValue)) ?? 0;
              logger.log("[AcSyncDatabase|$isDestination]   DB Sync Version: $dbVersion");
            }
          }
        }

        if (dbVersion < syncVersion) {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Version mismatch (DB: $dbVersion, Current: $syncVersion). Reinitializing...");
          result = await reinitialize();
          if (result.isSuccess()) {
            if (versionSet) {
              await dao!.updateRow(
                  tableName: AcSyncTables.acSyncDetails,
                  row: {TblAcSyncDetails.syncDetailNumericValue: syncVersion},
                  condition: "${TblAcSyncDetails.syncDetailKey} = '${AcSyncKeys
                      .keySyncVersion}'"
              );
            } else {
              await dao!.insertRow(
                  tableName: AcSyncTables.acSyncDetails,
                  row: {
                    TblAcSyncDetails.syncDetailKey: AcSyncKeys.keySyncVersion,
                    TblAcSyncDetails.syncDetailNumericValue: syncVersion
                  }
              );
            }
          }
        } else {
          result = await _initTriggers();
        }

        if (result.isSuccess()) {
          if (!deviceSet) {
            this.deviceId = Autocode.uuid();
            logger.log(
                "[AcSyncDatabase|$isDestination]  Generating new Device ID: ${this.deviceId}");
            await dao!.insertRow(tableName: AcSyncTables.acSyncDetails, row: {
              TblAcSyncDetails.syncDetailKey: AcSyncKeys.keyDeviceId,
              TblAcSyncDetails.syncDetailStringValue: deviceId,
            });
            await dao!.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
              TblAcSyncDevices.isSourceOfTruth: isDestination ? 0 : 1,
              TblAcSyncDevices.lastSyncChangeLogId: 0,
              TblAcSyncDevices.syncDeviceId: deviceId,
              TblAcSyncDevices.lastSyncedOn: DateTime.now().toIso8601String()
            });
          }
          if (!typeSet) {
            String type = isDestination ? 'DESTINATION' : 'SOURCE';
            logger.log("[AcSyncDatabase|$isDestination]   Setting Device Type: $type");
            await dao!.insertRow(tableName: AcSyncTables.acSyncDetails, row: {
              TblAcSyncDetails.syncDetailKey: AcSyncKeys.keyDeviceType,
              TblAcSyncDetails.syncDetailStringValue: type,
            });
          }
        }
        else {
          logger.log(
              "[AcSyncDatabase|$isDestination]  Failed to read sync details or initialize triggers: ${selectResult
                  .message}");
          result.setFromResult(result: selectResult);
        }
      }
    } catch (e, stack) {
      logger.log("[AcSyncDatabase|$isDestination]   Unexpected error during initialization: $e");
      result.setException(exception: e, stackTrace: stack);
    }
    logger.log("[AcSyncDatabase|$isDestination]   Initialization ${result.isSuccess()
        ? 'finished successfully.'
        : 'failed.'}");
    return result;
  }

  AcSyncDefinition registerDefinitionFromDataDictionary({
    String dataDictionaryName = 'default',
    List<String> syncToSourceTables = const [],
    List<String> syncToDestinationTables = const [],
    Map<String, List<String>> columnsToSyncMap = const {},
    List<String> deleteAfterSyncTables = const [],
    String definitionName = 'default',
  }) {
    final dd = AcDataDictionary.getInstance(
        dataDictionaryName: dataDictionaryName);
    List<String> allTables = dd.tables.keys.toList();

    var definition = AcSyncDefinition(
      definitionName: definitionName,
      tableDefinitions: allTables.map((t) {
        final table = AcDDTable.getInstance(
            tableName: t, dataDictionaryName: dataDictionaryName);
        bool syncToDestination = true;
        if (syncToDestinationTables.isNotEmpty) {
          syncToDestination = false;
          if (syncToDestinationTables.contains(t)) {
            syncToDestination = true;
          }
        }
        bool syncToSource = true;
        if (syncToSourceTables.isNotEmpty) {
          syncToSource = false;
          if (syncToSourceTables.contains(t)) {
            syncToSource = true;
          }
        }

        List<String> columnsToSync = List.empty(growable: true);
        if (columnsToSyncMap.containsKey(table.tableName)) {
          columnsToSync.addAll(columnsToSyncMap[t]!);
        }
        else {
          for (var tableColumn in table.tableColumns) {
            columnsToSync.add(tableColumn.columnName);
          }
        }
        bool deleteAfterSync = deleteAfterSyncTables.contains(t);

        logger.log(
            "[AcSyncDatabase|$isDestination]  Definition Table : ${t}, Sync To Source : $syncToSource, Sync To Destination : $syncToDestination, Columns To Sync : ${columnsToSync
                .length}, Delete After Sync : $deleteAfterSync");
        return AcSyncTableDefinition(
            tableName: t,
            primaryKeyField: table.getPrimaryKeyColumnName(),
            syncToSource: syncToSource,
            syncToDestination: syncToDestination,
            columnsToSync: columnsToSync,
            deleteAfterSyncFromDestination: deleteAfterSync
        );
      }).toList(),
    );

    registerSyncDefinition(definition: definition);
    return definition;
  }

  Future<AcResult> registerSyncDefinition(
      {required AcSyncDefinition definition}) async {
    AcResult result = AcResult();
    logger.log("[AcSyncDatabase|$isDestination]   Registering sync definition: ${definition
        .definitionName} with ${definition.tableDefinitions.length} tables.");
    syncDefinitions[definition.definitionName] = definition;
    result.setSuccess();
    return result;
  }

  Future<AcResult> saveDeviceSyncLog({
    required String deviceId,
    int syncDeviceLogId = 0,
    int? newSyncChangeLogId,
    int? oldSyncChangeLogId,
    String? startTimestamp,
    String? endTimestamp,
    String? syncOperationResult
  }) async {
    AcResult result = AcResult();
    logger.log(
        "[AcSyncDatabase|$isDestination]  Saving device sync log for device: $deviceId, operationResult: $syncOperationResult");
    Map<String, dynamic> row = {TblAcSyncDeviceLogs.syncDeviceId: deviceId};
    if (newSyncChangeLogId != null) {
      row[TblAcSyncDeviceLogs.newSyncChangeLogId] = newSyncChangeLogId;
    }
    if (oldSyncChangeLogId != null) {
      row[TblAcSyncDeviceLogs.oldSyncChangeLogId] = oldSyncChangeLogId;
    }
    if (startTimestamp != null) {
      row[TblAcSyncDeviceLogs.startTimestamp] = startTimestamp;
    }
    if (endTimestamp != null) {
      row[TblAcSyncDeviceLogs.endTimestamp] = endTimestamp;
    }
    if (syncOperationResult != null) {
      row[TblAcSyncDeviceLogs.syncOperationResult] = syncOperationResult;
    }
    if (syncDeviceLogId > 0) {
      result.setFromResult(result: await dao!.updateRow(
          tableName: AcSyncTables.acSyncDeviceLogs,
          row: row,
          condition: "${TblAcSyncDeviceLogs
              .syncDeviceLogId} = @syncDeviceLogId",
          parameters: {
            "@syncDeviceLogId": syncDeviceLogId
          }
      ));
    }
    else {
      AcSqlDaoResult insertResult = await dao!.insertRow(
          tableName: AcSyncTables.acSyncDeviceLogs, row: row);
      if (insertResult.isSuccess()) {
        syncDeviceLogId = insertResult.lastInsertedId;
      }
      result.setFromResult(result: insertResult);
    }
    result.value = syncDeviceLogId;
    return result;
  }

  Future<AcResult> updateLastSyncChangeLogId(
      {required String deviceId, required int lastSyncChangeLogId}) async {
    AcResult result = AcResult();
    logger.log(
        "[AcSyncDatabase|$isDestination]  Updating last sync change log ID for device $deviceId to $lastSyncChangeLogId");
    result.setFromResult(result: await dao!.updateRow(
      tableName: AcSyncTables.acSyncDevices,
      row: {
        TblAcSyncDevices.lastSyncChangeLogId: lastSyncChangeLogId,
        TblAcSyncDevices.lastSyncedOn: DateTime.now()
      },
      condition: "${TblAcSyncDevices.syncDeviceId} = '$deviceId'",
    ));
    if (result.isSuccess()) {
      logger.log(
          "[AcSyncDatabase|$isDestination]  Successfully updated last sync change log ID for device $deviceId.");
    } else {
      logger.error(
          "[AcSyncDatabase|$isDestination]  Failed to update last sync change log ID for device $deviceId: ${result
              .message}");
    }
    return result;
  }

}