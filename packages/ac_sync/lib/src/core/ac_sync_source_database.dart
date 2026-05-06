import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

class AcSyncSourceDatabase extends AcSyncDatabase {

  int lastDeviceSyncLogId = 0;

  AcSyncSourceDatabase({super.dao,super.databaseType = AcEnumSqlDatabaseType.unknown,}){
  }

  Future<AcResult> createDatabaseFileForDestination({required String destinationPath,String definitionName = 'default'}) async {
    final result = AcResult();
    final definition = syncDefinitions[definitionName];
    if (definition == null) {
      return result.setFailure(message: "Definition not found");
    }

    String? sourcePath;
    if (dao is AcSqliteDao) {
      sourcePath = (dao as AcSqliteDao).sqlConnection.database;
    }

    if (sourcePath == null || sourcePath.isEmpty) {
      return result.setFailure(message: "Source database path not available");
    }

    try {
      print("AcSyncSourceDatabase: Creating database file for destination at '$destinationPath'...");
      final databaseManager = AcSyncDatabaseManager();
      await databaseManager.createDatabaseFileForDestination(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        tableDefinitions: definition.tableDefinitions,
      );

      print("AcSyncSourceDatabase: Database file created. Initializing destination database metadata...");
      AcSqliteDao destinationDao = AcSqliteDao();
      int lastChangeLogId = 0;
      AcResult getLastResult = await getLastChangeLogId();
      if(getLastResult.isSuccess()){
        if(getLastResult.value > 0){
          lastChangeLogId = getLastResult.value;
        }
      }
      print("AcSyncSourceDatabase: Current last change log ID: $lastChangeLogId");
      destinationDao.sqlConnection = AcSqlConnection(database: destinationPath);
      String destinationDeviceId = Autocode.uuid();
      print("AcSyncSourceDatabase: New destination device ID: $destinationDeviceId");
      await destinationDao.insertRow(tableName: AcSyncTables.acSyncDetails, row: {
        TblAcSyncDetails.syncDetailKey:AcSyncKeys.keyDeviceId,
        TblAcSyncDetails.syncDetailStringValue:destinationDeviceId,
      });
      await destinationDao.insertRow(tableName: AcSyncTables.acSyncDetails, row: {
        TblAcSyncDetails.syncDetailKey: AcSyncKeys.keyDeviceType,
        TblAcSyncDetails.syncDetailStringValue: 'DESTINATION'
      });
      await destinationDao.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
        TblAcSyncDevices.isSourceOfTruth: 1,
        TblAcSyncDevices.lastSyncChangeLogId: lastChangeLogId,
        TblAcSyncDevices.syncDeviceId: deviceId,
        TblAcSyncDevices.lastSyncedOn: DateTime.now().toIso8601String()
      });
      await destinationDao.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
        TblAcSyncDevices.isSourceOfTruth: 0,
        TblAcSyncDevices.lastSyncChangeLogId: lastChangeLogId,
        TblAcSyncDevices.syncDeviceId: destinationDeviceId,
        TblAcSyncDevices.lastSyncedOn: DateTime.now().toIso8601String()
      });
      print("AcSyncSourceDatabase: Registering new destination device in source database...");
      await dao!.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
        TblAcSyncDevices.isSourceOfTruth: 0,
        TblAcSyncDevices.lastSyncChangeLogId: lastChangeLogId,
        TblAcSyncDevices.syncDeviceId: destinationDeviceId,
        TblAcSyncDevices.lastSyncedOn: DateTime.now().toIso8601String()
      });
      result.setSuccess();
      print("AcSyncSourceDatabase: Destination database file creation complete.");
    } catch (e, stack) {
      print("AcSyncSourceDatabase: Error creating destination database: $e");
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }

  Future<AcResult> deleteSyncedChangeLogs() async {
    AcResult result = AcResult();
    if (dao == null) {
      result.setFailure(message: "DAO not set");
      return result;
    }

    try {
      print("AcSyncSourceDatabase: Pruning synced change logs...");
      // 1. Get the minimum last_sync_change_log_id from all devices
      var minIdResult = await dao!.getRows(
          statement: "SELECT MIN(${TblAcSyncDevices.lastSyncChangeLogId}) as min_id FROM ${AcSyncTables.acSyncDevices}"
      );

      if (minIdResult.isSuccess() && minIdResult.rows.isNotEmpty) {
        var minId = minIdResult.rows.first['min_id'];

        if (minId != null) {
          int id = int.parse(minId.toString());
          print("AcSyncSourceDatabase: Minimum synced ID across all devices: $id. Deleting older logs...");

          // 2. Delete logs that are already synced across all devices
          await dao!.deleteRows(
              tableName: AcSyncTables.acSyncChangeLogs,
              condition: "${TblAcSyncChangeLogs.syncChangeLogId} <= $id"
          );

          result.setSuccess(message: "Pruned logs up to ID $id");
          print("AcSyncSourceDatabase: Pruned logs up to ID $id");
        } else {
          print("AcSyncSourceDatabase: No logs to prune (min_id is null)");
          result.setSuccess(message: "No logs to prune (min_id is null)");
        }
      } else {
        print("AcSyncSourceDatabase: Failed to get minimum synced ID: ${minIdResult.message}");
        result.setFromResult(result: minIdResult);
      }
    } catch (e, stack) {
      print("AcSyncSourceDatabase: Error pruning logs: $e");
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }

  Future<AcResult> getDestinationLastChangeLogId(String destinationDeviceId) async {
    AcResult result = AcResult();
    final getResult = await dao!.getRows(
        statement: "SELECT ${TblAcSyncDevices.lastSyncChangeLogId} FROM ${AcSyncTables.acSyncDevices} WHERE ${TblAcSyncDevices.syncDeviceId} = @remoteDeviceId",
      parameters: {"@remoteDeviceId":destinationDeviceId}
    );
    if (getResult.isSuccess()) {
      if(getResult.rows.isNotEmpty){
        result.setSuccess(value:getResult.rows.first.getInt(TblAcSyncDevices.lastSyncChangeLogId));
      }
      else{
        result.setSuccess(value: 0);
      }
    }
    else{
      result.setFromResult(result: getResult);
    }
    return result;
  }

  Future<AcResult> handleNotifyChangesFromDestination({required AcNotifyChangesToSourceFunArgs destinationNotifyArgs})  async {
    AcResult result = AcResult();
    print("AcSyncSourceDatabase: Received notification of changes from destination (Device ID: ${destinationNotifyArgs.deviceId})...");
    
    print("AcSyncSourceDatabase: Saving device sync log (STARTED)...");
    var startSyncLogResult = await saveDeviceSyncLog(
        deviceId: destinationNotifyArgs.deviceId!,
        startTimestamp: destinationNotifyArgs.startTimestamp,
        oldSyncChangeLogId: destinationNotifyArgs.lastSyncChangeLogId,
        syncOperationResult: 'STARTED'
    );
    lastDeviceSyncLogId = startSyncLogResult.value ?? 0;
    
    print("AcSyncSourceDatabase: Extracting source changes for destination (since ID: ${destinationNotifyArgs.lastSyncChangeLogId})...");
    var getChangesResult = await getSyncChanges(lastSyncId: destinationNotifyArgs.lastSyncChangeLogId!);
    if(getChangesResult.isSuccess()){
      final changes = getChangesResult.value as AcSyncChanges;
      print("AcSyncSourceDatabase: Source changes extracted. Table count: ${changes.tableChanges.length}");

      AcNotifyChangesCallbackArgs callbackArgs = AcNotifyChangesCallbackArgs();
      callbackArgs.deviceId = deviceId;
      callbackArgs.sourceChanges = changes;

      print("AcSyncSourceDatabase: Getting current last change log ID...");
      final lastChangeLogIdResult = await getLastChangeLogId();
      if(lastChangeLogIdResult.isFailure()){
        print("AcSyncSourceDatabase: Failed to get last change log ID: ${lastChangeLogIdResult.message}");
        result.setFromResult(result: lastChangeLogIdResult);
        return result;
      }

      int lastChangeLogId = lastChangeLogIdResult.value ?? 0;
      callbackArgs.lastSyncChangeLogId = lastChangeLogId;
      print("AcSyncSourceDatabase: Current last change log ID: $lastChangeLogId. Sending response to destination.");

      result.setSuccess(value: callbackArgs);
    }
    else{
      print("AcSyncSourceDatabase: Failed to extract changes: ${getChangesResult.message}");
      result.setFromResult(result: getChangesResult);
    }
    return result;
  }

  Future<AcResult> handleNotifySyncSuccessFromSource({required AcNotifySyncSuccessToSourceFunArgs destinationNotifyArgs}) async {
    AcResult result = AcResult();
    print("AcSyncSourceDatabase: Received sync success notification from destination (Device ID: ${destinationNotifyArgs.deviceId})...");
    
    AcNotifySuccessCallbackArgs callbackArgs = AcNotifySuccessCallbackArgs();
    print("AcSyncSourceDatabase: Updating last sync ID for destination...");
    var updateSelfSyncIdResult = await updateLastSyncChangeLogId(deviceId: destinationNotifyArgs.deviceId!,lastSyncChangeLogId:destinationNotifyArgs.lastSyncChangeLogId!);
    if(updateSelfSyncIdResult.isSuccess()){
      print("AcSyncSourceDatabase: Last sync ID updated. Getting new last change log ID...");
      final lastChangeLogIdResult = await getLastChangeLogId();
      if(lastChangeLogIdResult.isFailure()){
        print("AcSyncSourceDatabase: Failed to get last change log ID: ${lastChangeLogIdResult.message}");
        result.setFromResult(result: lastChangeLogIdResult);
        return result;
      }

      int lastChangeLogId = lastChangeLogIdResult.value ?? 0;
      print("AcSyncSourceDatabase: New last change log ID: $lastChangeLogId. Updating sync log (COMPLETED)...");
      callbackArgs.lastSyncChangeLogId = lastChangeLogId;
      callbackArgs.deviceId = deviceId;
      await saveDeviceSyncLog(
          deviceId: destinationNotifyArgs.deviceId!,
          endTimestamp:destinationNotifyArgs.endTimestamp,
          newSyncChangeLogId: destinationNotifyArgs.lastSyncChangeLogId,
          syncOperationResult: 'COMPLETED',
          syncDeviceLogId: lastDeviceSyncLogId
      );
      print("AcSyncSourceDatabase: Sync cycle finished for destination.");
      result.setSuccess(value: callbackArgs);
    }
    else{
      print("AcSyncSourceDatabase: Failed to update last sync ID: ${updateSelfSyncIdResult.message}");
      result.setFromResult(result: updateSelfSyncIdResult);
    }
    return result;
  }
}