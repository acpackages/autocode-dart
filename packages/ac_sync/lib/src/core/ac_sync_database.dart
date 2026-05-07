import 'dart:convert';

import 'package:ac_data_dictionary/ac_data_dictionary.dart';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

class AcSyncDatabase {
  AcBaseSqlDao? dao;
  Map<String,AcSyncDefinition> syncDefinitions = {};
  AcEnumSqlDatabaseType databaseType = AcEnumSqlDatabaseType.unknown;
  String? deviceId;
  bool isSyncing = false;
  bool isDestination = false;
  void Function()? onSyncStart;
  void Function()? onSyncComplete;
  void Function({required AcSyncProgress progress})? onSyncProgress;
  static const int currentSyncVersion = 1;

  AcSyncDatabase({this.dao, this.databaseType = AcEnumSqlDatabaseType.unknown,}){
  }

  Future<AcResult> _initSchemaManager() async {
    print("AcSyncDatabase: Initializing Schema Manager...");
    var databaseManager = AcSyncDatabaseManager();
    databaseManager.dao = dao;
    databaseManager.databaseType = databaseType;
    var result = await databaseManager.initAcSyncDatabase();
    print("AcSyncDatabase: Schema Manager initialization ${result.isSuccess() ? 'successful' : 'failed: ' + result.message}");
    return result;
  }

  Future<AcResult> _initTriggers() async {
    print("AcSyncDatabase: Initializing Triggers...");
    AcResult result = AcResult();
    var databaseManager = AcSyncDatabaseManager();

    Map<String, AcSyncTableDefinition> tableDefinitionsMap = {};
    for(var definition in syncDefinitions.values){
      for(var tableDef in definition.tableDefinitions){
        tableDefinitionsMap.putIfAbsent(tableDef.tableName, () => tableDef);
      }
    }

    print("AcSyncDatabase: Creating triggers for tables: ${tableDefinitionsMap.keys.join(', ')}");

    await databaseManager.createSyncTriggers(
        dao: dao,
        tableDefinitions: tableDefinitionsMap.values.toList(),
        databaseType: databaseType
    );

    result.setSuccess();
    print("AcSyncDatabase: Triggers initialized.");
    return result;
  }

  Future<AcResult> applySyncChanges({required AcSyncChanges changes}) async {
    AcResult result = AcResult();
    print("AcSyncDatabase: Applying sync changes...");
    if (dao == null) {
      print("AcSyncDatabase: DAO not set, cannot apply changes.");
      result.setFailure(message: "DAO not set");
      return result;
    }

    try {
      await dao!.executeStatement(statement: "PRAGMA foreign_keys = OFF;");
      for (var tableName in changes.tableChanges.keys) {
        var tableChanges = changes.tableChanges[tableName]!;
        print("AcSyncDatabase: Table '$tableName' - Deletes: ${tableChanges.rowsToDelete.length}, Inserts: ${tableChanges.rowsToInsert.length}, Updates: ${tableChanges.rowsToUpdate.length}");

        // Find PK field from definitions
        String pkField = "id";
        for (var def in syncDefinitions.values) {
          for (var tDef in def.tableDefinitions) {
            if (tDef.tableName == tableName) {
              pkField = tDef.primaryKeyField;
              break;
            }
          }
        }

        // 1. Delete rows
        if (tableChanges.rowsToDelete.isNotEmpty) {
          for (var rowChange in tableChanges.rowsToDelete) {
            if (rowChange.rowId != null) {
              await dao!.deleteRows(
                tableName: tableName,
                condition: "$pkField = '${rowChange.rowId}'",
              );
            }
          }
        }

        // 2. Insert rows
        if (tableChanges.rowsToInsert.isNotEmpty) {
          for (var rowChange in tableChanges.rowsToInsert) {
            if (rowChange.row != null) {
              await dao!.insertRow(
                tableName: tableName,
                row: rowChange.row!,
              );
            }
          }
        }

        // 3. Update rows
        if (tableChanges.rowsToUpdate.isNotEmpty) {
          for (var rowChange in tableChanges.rowsToUpdate) {
            if (rowChange.row != null) {
              var rowId = rowChange.row![pkField];
              await dao!.updateRow(
                tableName: tableName,
                row: rowChange.row!,
                condition: "$pkField = '$rowId'",
              );
            }
          }
        }
      }
      await dao!.executeStatement(statement: "PRAGMA foreign_keys = ON;");
      result.setSuccess();
      print("AcSyncDatabase: Sync changes applied successfully.");
    } catch (e, stack) {
      print("AcSyncDatabase: Error applying sync changes: $e");
      result.setException(exception: e, stackTrace: stack);
    }
    return result;
  }
  Future<AcResult> deleteSyncedRows({required AcSyncChanges changes, String definitionName = 'default'}) async {
    AcResult result = AcResult();
    if (dao == null) return result.setFailure(message: "DAO not set");

    if (!syncDefinitions.containsKey(definitionName)) {
      return result.setFailure(message: "Definition not found");
    }

    final definition = syncDefinitions[definitionName]!;
    try {
      for (var tableName in changes.tableChanges.keys) {
        final tableDef = definition.tableDefinitions.firstWhere((t) => t.tableName == tableName);
        if (tableDef != null && tableDef.deleteAfterSyncFromDestination) {
          final tableChanges = changes.tableChanges[tableName]!;
          final pkField = tableDef.primaryKeyField.isNotEmpty ? tableDef.primaryKeyField : 'id';

          // Rows that were successfully sent (inserts and updates)
          final rowsToDelete = [...tableChanges.rowsToInsert, ...tableChanges.rowsToUpdate];
          
          if (rowsToDelete.isNotEmpty) {
            print("AcSyncDatabase: Deleting ${rowsToDelete.length} synced rows from '$tableName' as per deleteAfterSyncFromDestination flag.");
            for (var rowChange in rowsToDelete) {
              final rowId = rowChange.rowId ?? (rowChange.row != null ? rowChange.row![pkField] : null);
              if (rowId != null) {
                await dao!.deleteRows(
                  tableName: tableName,
                  condition: "$pkField = '$rowId'",
                );
              }
            }
          }
        }
      }
      result.setSuccess();
    } catch (e, stack) {
      print("AcSyncDatabase: Error deleting synced rows: $e");
      result.setException(exception: e, stackTrace: stack);
    }
    return result;
  }

  Future<AcResult> getLastChangeLogId() async {
    AcResult result = AcResult();
    if (dao == null){
      result.setFailure(message: "DAO not set");
      return result;
    }
    var selectResult = await dao!.getRows(
      statement: "SELECT MAX(${TblAcSyncChangeLogs.syncChangeLogId}) AS ${TblAcSyncChangeLogs.syncChangeLogId} FROM ${AcSyncTables.acSyncChangeLogs}"
    );

    if (selectResult.isSuccess()){
      result.setSuccess();
      result.value = selectResult.rows.first[TblAcSyncChangeLogs.syncChangeLogId]??0;
    }
    else{
      result.setFromResult(result: selectResult);
    }
    return result;
  }

  Future<AcResult> getSyncChanges({int lastSyncId = 0, String definitionName = 'default',}) async {
    AcResult result = AcResult();
    print("AcSyncDatabase: Getting sync changes since ID: $lastSyncId for definition: $definitionName");
    if (dao == null){
      print("AcSyncDatabase: DAO not set, cannot get changes.");
      result.setFailure(message: "DAO not set");
      return result;
    }

    if(syncDefinitions.containsKey(definitionName)){
      // 1. Fetch all logs since lastSyncId
      var logsResult = await dao!.getRows(
        statement: "SELECT * FROM ${AcSyncTables.acSyncChangeLogs} "
            "WHERE ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId "
            "ORDER BY ${TblAcSyncChangeLogs.syncChangeLogId} ASC",
      );

      if (!logsResult.isSuccess()){
        print("AcSyncDatabase: Failed to get change logs: ${logsResult.message}");
        result.setFromResult(result: logsResult);
        return result;
      }

      AcSyncChanges changes = AcSyncChanges(tableChanges: {});
      int maxLogId = lastSyncId;

      // Group logs by table and rowId to merge changes
      Map<String, Map<String, List<Map<String,dynamic>>>> groupedLogs = {};

      for(var log in logsResult.rows){
        int logId = log.getInt(TblAcSyncChangeLogs.syncChangeLogId);
        if(logId > maxLogId) maxLogId = logId;

        String tableName = log.getString(TblAcSyncChangeLogs.tableName);
        String rowId = log.getString(TblAcSyncChangeLogs.rowId);

        groupedLogs.putIfAbsent(tableName, () => {});
        groupedLogs[tableName]!.putIfAbsent(rowId, () => []);
        groupedLogs[tableName]![rowId]!.add(log);
      }

      AcSyncDefinition definition = syncDefinitions[definitionName]!;
      for(var tableDefinition in definition.tableDefinitions){
        String tableName = tableDefinition.tableName;
        if(!groupedLogs.containsKey(tableName)) continue;

        bool continueOperation = (tableDefinition.syncToSource && isDestination) || (tableDefinition.syncToDestination && !isDestination);
        if(continueOperation){
          var tableChanges = AcSyncTableChanges();
          var rowsForTable = groupedLogs[tableName]!;

          for(var rowId in rowsForTable.keys){
            var logs = rowsForTable[rowId]!;
            
            String? finalOp;
            Map<String, dynamic> mergedPayload = {};
            bool wasInsertedInRange = false;

            for(var log in logs){
              String op = log.getString(TblAcSyncChangeLogs.rowOperation);
              String? payloadStr = log.getString(TblAcSyncChangeLogs.rowPayload);
              Map<String, dynamic> payload = {};
              if(payloadStr != null && payloadStr.isNotEmpty){
                try {
                  payload = jsonDecode(payloadStr);
                } catch (e) {
                  print("AcSyncDatabase: Error decoding payload for table $tableName row $rowId: $e");
                }
              }

              if(op == 'INSERT'){
                finalOp = 'INSERT';
                wasInsertedInRange = true;
                mergedPayload.addAll(payload);
              } else if(op == 'UPDATE'){
                if(finalOp == null || finalOp == 'UPDATE'){
                  finalOp = 'UPDATE';
                }
                mergedPayload.addAll(payload);
              } else if(op == 'DELETE'){
                finalOp = 'DELETE';
                mergedPayload = {};
              }
            }

            if(finalOp == 'DELETE'){
              if(!wasInsertedInRange){
                tableChanges.rowsToDelete.add(AcSyncTableRowChange(operation: 'DELETE', rowId: rowId));
              }
            } else if(finalOp == 'INSERT'){
              mergedPayload[tableDefinition.primaryKeyField] = rowId;
              tableChanges.rowsToInsert.add(AcSyncTableRowChange(operation: 'INSERT', row: mergedPayload, rowId: rowId));
            } else if(finalOp == 'UPDATE'){
              mergedPayload[tableDefinition.primaryKeyField] = rowId;
              tableChanges.rowsToUpdate.add(AcSyncTableRowChange(operation: 'UPDATE', row: mergedPayload, rowId: rowId));
            }
          }

          if (tableChanges.rowsToDelete.isNotEmpty || tableChanges.rowsToInsert.isNotEmpty || tableChanges.rowsToUpdate.isNotEmpty) {
            print("AcSyncDatabase: Collected merged changes for '$tableName' - Del: ${tableChanges.rowsToDelete.length}, Ins: ${tableChanges.rowsToInsert.length}, Upd: ${tableChanges.rowsToUpdate.length}");
            changes.tableChanges[tableName] = tableChanges;
          }
        }
      }
      changes.lastChangeLogId = maxLogId;
      result.setSuccess(value: changes);
    }
    else{
      print("AcSyncDatabase: Definition '$definitionName' does not exist.");
      result.setFailure(message: 'Definition does not exist');
    }
    return result;
  }

  Future<AcResult> reinitialize() async {
    print("AcSyncDatabase: Reinitializing database (dropping and recreating triggers)...");
    AcResult result = AcResult();

    if (dao == null) {
      print("AcSyncDatabase: DAO not set, cannot reinitialize.");
      result.setFailure(message: "DAO not set");
      return result;
    }

    var databaseManager = AcSyncDatabaseManager();

    Map<String, AcSyncTableDefinition> tableDefinitionsMap = {};
    for(var definition in syncDefinitions.values){
      for(var tableDef in definition.tableDefinitions){
        tableDefinitionsMap.putIfAbsent(tableDef.tableName, () => tableDef);
      }
    }

    try {
      // 1. Drop Triggers
      print("AcSyncDatabase: Dropping triggers for tables: ${tableDefinitionsMap.keys.join(', ')}");
      await databaseManager.dropSyncTriggers(
          dao: dao,
          tableDefinitions: tableDefinitionsMap.values.toList(),
          databaseType: databaseType
      );

      // 2. Recreate Triggers
      result = await _initTriggers();
      
      if(result.isSuccess()){
        print("AcSyncDatabase: Reinitialization successful.");
      }
    } catch (e, stack) {
      print("AcSyncDatabase: Error during reinitialization: $e");
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }

  Future<AcResult> initialize() async {
    print("AcSyncDatabase: Initializing database...");
    // Register sync data dictionary
    AcDataDictionary.registerDataDictionary(
      jsonData: AC_SYNC_DATA_DICTIONARY,
      dataDictionaryName: AcSyncDatabaseManager.dataDictionaryName,
    );

    AcResult result = await _initSchemaManager();
    if (result.isSuccess()) {
      print("AcSyncDatabase: Reading sync details...");
      AcSqlDaoResult selectResult = await dao!.getRows(statement:"SELECT ${TblAcSyncDetails.syncDetailKey}, ${TblAcSyncDetails.syncDetailStringValue} FROM ${AcSyncTables.acSyncDetails} WHERE ${TblAcSyncDetails.syncDetailKey} IN (@keys);",parameters: {
        "@keys":[AcSyncKeys.keyDeviceType,AcSyncKeys.keyDeviceId, AcSyncKeys.keySyncVersion]
      });

      int dbVersion = 0;
      bool deviceSet = false, typeSet = false, versionSet = false;

      if(selectResult.isSuccess()){
        for(var row in selectResult.rows){
          String key = row.getString(TblAcSyncDetails.syncDetailKey);
          String val = row.getString(TblAcSyncDetails.syncDetailStringValue);
          if(key == AcSyncKeys.keyDeviceId){
            deviceSet = true;
            this.deviceId = val;
            print("AcSyncDatabase: Device ID: ${this.deviceId}");
          }
          else if(key == AcSyncKeys.keyDeviceType){
            typeSet = true;
            print("AcSyncDatabase: Device Type: $val");
          }
          else if(key == AcSyncKeys.keySyncVersion){
            versionSet = true;
            dbVersion = int.tryParse(val) ?? 0;
            print("AcSyncDatabase: DB Sync Version: $dbVersion");
          }
        }
      }

      if (dbVersion < currentSyncVersion) {
        print("AcSyncDatabase: Version mismatch (DB: $dbVersion, Current: $currentSyncVersion). Reinitializing...");
        result = await reinitialize();
        if (result.isSuccess()) {
          if (versionSet) {
            await dao!.updateRow(
                tableName: AcSyncTables.acSyncDetails,
                row: {TblAcSyncDetails.syncDetailStringValue: currentSyncVersion.toString()},
                condition: "${TblAcSyncDetails.syncDetailKey} = '${AcSyncKeys.keySyncVersion}'"
            );
          } else {
            await dao!.insertRow(
                tableName: AcSyncTables.acSyncDetails,
                row: {
                  TblAcSyncDetails.syncDetailKey: AcSyncKeys.keySyncVersion,
                  TblAcSyncDetails.syncDetailStringValue: currentSyncVersion.toString()
                }
            );
          }
        }
      } else {
        result = await _initTriggers();
      }

      if (result.isSuccess()) {
        if(!deviceSet){
          this.deviceId = Autocode.uuid();
          print("AcSyncDatabase: Generating new Device ID: ${this.deviceId}");
          await dao!.insertRow(tableName: AcSyncTables.acSyncDetails, row: {
            TblAcSyncDetails.syncDetailKey:AcSyncKeys.keyDeviceId,
            TblAcSyncDetails.syncDetailStringValue:deviceId,
          });
          await dao!.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
            TblAcSyncDevices.isSourceOfTruth: isDestination?0:1,
            TblAcSyncDevices.lastSyncChangeLogId: 0,
            TblAcSyncDevices.syncDeviceId: deviceId,
            TblAcSyncDevices.lastSyncedOn: DateTime.now().toIso8601String()
          });
        }
        if(!typeSet){
          String type = isDestination?'DESTINATION':'SOURCE';
          print("AcSyncDatabase: Setting Device Type: $type");
          await dao!.insertRow(tableName: AcSyncTables.acSyncDetails, row: {
            TblAcSyncDetails.syncDetailKey:AcSyncKeys.keyDeviceType,
            TblAcSyncDetails.syncDetailStringValue:type,
          });
        }
      }
      else{
        print("AcSyncDatabase: Failed to read sync details or initialize triggers: ${selectResult.message}");
        result.setFromResult(result: selectResult);
      }
    }
    print("AcSyncDatabase: Initialization ${result.isSuccess() ? 'finished successfully.' : 'failed.'}");
    return result;
  }

  AcSyncDefinition registerDefinitionFromDataDictionary({
    required String dataDictionaryName,
    List<String> syncToSourceTables = const [],
    List<String> syncToDestinationTables = const [],
    Map<String, List<String>> columnsToSyncMap = const {},
    List<String> deleteAfterSyncTables = const [],
    String definitionName = 'default',
  }) {
    final dd = AcDataDictionary.getInstance(dataDictionaryName: dataDictionaryName);
    List<String> allTables = dd.tables.keys.toList();

    var definition = AcSyncDefinition(
      definitionName: definitionName,
      tableDefinitions: allTables.map((t) {
        final table = AcDDTable.getInstance(tableName: t,dataDictionaryName: dataDictionaryName);
        bool syncToDestination = true;
        if(syncToDestinationTables.isNotEmpty){
          syncToDestination = false;
          if(syncToDestinationTables.contains(t)){
            syncToDestination = true;
          }
        }
        bool syncToSource = false;
        if(syncToSourceTables.isNotEmpty){
          syncToSource = false;
          if(syncToSourceTables.contains(t)){
            syncToSource = true;
          }
        }
        
        List<String> columnsToSync = List.empty(growable: true);
        if(columnsToSyncMap.containsKey(table.tableName)){
          columnsToSync.addAll(columnsToSyncMap[t]!);
        }
        else{
          for(var tableColumn in table.tableColumns){
            columnsToSync.add(tableColumn.columnName);
          }
        }
        bool deleteAfterSync = deleteAfterSyncTables.contains(t);

        print("Definition Table : ${t}, Sync To Source : $syncToSource, Sync To Destination : $syncToDestination, Columns To Sync : ${columnsToSync.length}, Delete After Sync : $deleteAfterSync");
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

  Future<AcResult> registerSyncDefinition({required AcSyncDefinition definition}) async {
    AcResult result = AcResult();
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
    Map<String,dynamic> row = {TblAcSyncDeviceLogs.syncDeviceId:deviceId};
    if(newSyncChangeLogId != null){
      row[TblAcSyncDeviceLogs.newSyncChangeLogId] = newSyncChangeLogId;
    }
    if(oldSyncChangeLogId != null){
      row[TblAcSyncDeviceLogs.oldSyncChangeLogId] = oldSyncChangeLogId;
    }
    if(startTimestamp != null){
      row[TblAcSyncDeviceLogs.startTimestamp] = startTimestamp;
    }
    if(endTimestamp != null){
      row[TblAcSyncDeviceLogs.endTimestamp] = endTimestamp;
    }
    if(syncOperationResult != null){
      row[TblAcSyncDeviceLogs.syncOperationResult] = syncOperationResult;
    }
    if(syncDeviceLogId > 0){
      result.setFromResult(result: await dao!.updateRow(
        tableName: AcSyncTables.acSyncDeviceLogs,
        row: row,
        condition: "${TblAcSyncDeviceLogs.syncDeviceLogId} = @syncDeviceLogId",
        parameters: {
          "@syncDeviceLogId":syncDeviceLogId
        }
      ));
    }
    else{
      AcSqlDaoResult insertResult = await dao!.insertRow(tableName: AcSyncTables.acSyncDeviceLogs, row: row);
      if(insertResult.isSuccess()){
        syncDeviceLogId = insertResult.lastInsertedId;
      }
      result.setFromResult(result: insertResult);
    }
    result.value = syncDeviceLogId;
    return result;
  }

  Future<AcResult> updateLastSyncChangeLogId({required String deviceId, required int lastSyncChangeLogId}) async {
    AcResult result = AcResult();
    result.setFromResult(result: await dao!.updateRow(
      tableName: AcSyncTables.acSyncDevices,
      row: {TblAcSyncDevices.lastSyncChangeLogId: lastSyncChangeLogId, TblAcSyncDevices.lastSyncedOn: DateTime.now()},
      condition: "${TblAcSyncDevices.syncDeviceId} = '$deviceId'",
    ));
    return result;
  }

}