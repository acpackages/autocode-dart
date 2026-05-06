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
  void Function(AcSyncProgress progress)? onSyncProgress;

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

    List<String> tables = [];
    for(var definition in syncDefinitions.values){
      tables.addAll(definition.tableDefinitions.map((t) => t.tableName));
    }

    // Remove duplicates
    tables = tables.toSet().toList();
    print("AcSyncDatabase: Creating triggers for tables: ${tables.join(', ')}");

    await databaseManager.createSyncTriggers(
        dao: dao,
        tables: tables,
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
      var tablesResult = await dao!.getRows(
        statement: "SELECT DISTINCT ${TblAcSyncChangeLogs.tableName} FROM ${AcSyncTables.acSyncChangeLogs} "
            "WHERE ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId",
      );

      if (!tablesResult.isSuccess()){
        print("AcSyncDatabase: Failed to get tables with changes: ${tablesResult.message}");
        result.setFromResult(result: tablesResult);
        return result;
      }

      List<String> tablesWithChanges = List.empty(growable: true);
      for(var row in tablesResult.rows){
        tablesWithChanges.add(row.getString(TblAcSyncChangeLogs.tableName));
      }
      print("AcSyncDatabase: AcSyncTables with changes: ${tablesWithChanges.join(', ')}");

      AcSyncChanges changes = AcSyncChanges(tableChanges: {});
      changes.lastChangeLogId = lastSyncId;

      AcSyncDefinition definition = syncDefinitions[definitionName]!;
      for(var tableDefinition in definition.tableDefinitions){
        String tableName = tableDefinition.tableName;
        String primaryKeyField = tableDefinition.primaryKeyField;
        bool continueOperation = (tableDefinition.syncToSource && isDestination) || (tableDefinition.syncToDestination && !isDestination);
        if(continueOperation){
          var tableChanges = AcSyncTableChanges();

          if(tablesWithChanges.contains(tableName)){
            var deletedResult = await dao!.getRows(
              statement: "SELECT DISTINCT ${TblAcSyncChangeLogs.rowId} FROM ${AcSyncTables.acSyncChangeLogs} "
                  "WHERE ${TblAcSyncChangeLogs.tableName} = '$tableName' "
                  "AND ${TblAcSyncChangeLogs.rowOperation} = 'DELETE' "
                  "AND ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId",
            );
            tableChanges.rowsToDelete = deletedResult.rows.map((r) => AcSyncTableRowChange(operation: 'DELETE',rowId:r[TblAcSyncChangeLogs.rowId].toString())).toList();

            // Get all inserted row IDs for this table
            var insertedResult = await dao!.getRows(
              statement: "SELECT * FROM $tableName WHERE $primaryKeyField IN ("
                  "SELECT DISTINCT ${TblAcSyncChangeLogs.rowId} FROM ${AcSyncTables.acSyncChangeLogs} "
                  "WHERE ${TblAcSyncChangeLogs.tableName} = '$tableName' "
                  "AND ${TblAcSyncChangeLogs.rowOperation} = 'INSERT' "
                  "AND ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId)",
            );
            tableChanges.rowsToInsert = insertedResult.rows.map((r) => AcSyncTableRowChange(operation: 'INSERT',row:r)).toList();

            // Get all updated row IDs for this table
            var updatedResult = await dao!.getRows(
              statement: "SELECT * FROM $tableName WHERE $primaryKeyField IN ("
                  "SELECT DISTINCT ${TblAcSyncChangeLogs.rowId} FROM ${AcSyncTables.acSyncChangeLogs} "
                  "WHERE ${TblAcSyncChangeLogs.tableName} = '$tableName' "
                  "AND ${TblAcSyncChangeLogs.rowOperation} = 'UPDATE' "
                  "AND ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId"
                  ") AND  ${primaryKeyField} NOT IN ("
                  "SELECT DISTINCT ${TblAcSyncChangeLogs.rowId} FROM ${AcSyncTables.acSyncChangeLogs} "
                  "WHERE ${TblAcSyncChangeLogs.tableName} = '$tableName' "
                  "AND ${TblAcSyncChangeLogs.rowOperation} IN ('DELETE','INSERT' )"
                  "AND ${TblAcSyncChangeLogs.syncChangeLogId} > $lastSyncId"
                  ")",
            );
            tableChanges.rowsToUpdate = updatedResult.rows.map((r) => AcSyncTableRowChange(operation: 'UPDATE',row:r)).toList();

            if (tableChanges.rowsToDelete.isNotEmpty || tableChanges.rowsToInsert.isNotEmpty || tableChanges.rowsToUpdate.isNotEmpty) {
              print("AcSyncDatabase: Collected changes for '$tableName' - Del: ${tableChanges.rowsToDelete.length}, Ins: ${tableChanges.rowsToInsert.length}, Upd: ${tableChanges.rowsToUpdate.length}");
              changes.tableChanges[tableName] = tableChanges;
            }
          }
        }
      }
      result.setSuccess(value: changes);
    }
    else{
      print("AcSyncDatabase: Definition '$definitionName' does not exist.");
      result.setFailure(message: 'Definition does not exist');
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
      result = await _initTriggers();
    }
    if (result.isSuccess()) {
      print("AcSyncDatabase: Reading sync details...");
      AcSqlDaoResult selectResult = await dao!.getRows(statement:"SELECT ${TblAcSyncDetails.syncDetailKey}, ${TblAcSyncDetails.syncDetailStringValue} FROM ${AcSyncTables.acSyncDetails} WHERE ${TblAcSyncDetails.syncDetailKey} IN (@keys);",parameters: {
        "@keys":[AcSyncKeys.keyDeviceType,AcSyncKeys.keyDeviceId]
      });
      if(selectResult.isSuccess()){
        bool deviceSet = false, typeSet = false;
        for(var row in selectResult.rows){
          if(row.getString(TblAcSyncDetails.syncDetailKey) == AcSyncKeys.keyDeviceId){
            deviceSet = true;
            this.deviceId = row.getString(TblAcSyncDetails.syncDetailStringValue);
            print("AcSyncDatabase: Device ID: ${this.deviceId}");
          }
          else if(row.getString(TblAcSyncDetails.syncDetailKey) == AcSyncKeys.keyDeviceType){
            typeSet = true;
            print("AcSyncDatabase: Device Type: ${row.getString(TblAcSyncDetails.syncDetailStringValue)}");
          }
        }
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
        print("AcSyncDatabase: Failed to read sync details: ${selectResult.message}");
        result.setFromResult(result: selectResult);
      }
    }
    print("AcSyncDatabase: Initialization ${result.isSuccess() ? 'finished successfully.' : 'failed.'}");
    return result;
  }

  AcSyncDefinition registerDefinitionFromDataDictionary({required String dataDictionaryName,List<String> syncToSourceTables = const [],List<String> syncToDestinationTables = const [],String definitionName = 'default',}) {
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
        print("Definition Table : ${t}, Sync To Source : $syncToSource, Sync To Destination : $syncToDestination");
        return AcSyncTableDefinition(tableName: t, primaryKeyField: table.getPrimaryKeyColumnName(),syncToSource:syncToSource,syncToDestination: syncToDestination);
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