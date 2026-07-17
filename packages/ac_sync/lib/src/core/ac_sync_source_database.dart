import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sql/ac_sql.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

class AcSyncSourceDatabase extends AcSyncDatabase {

  int lastDeviceSyncLogId = 0;
  Future<void> Function(AcSyncMessage message)? onSendMessage;

  @override
  Future<void> sendMessage(AcSyncMessage message) async {
    if (onSendMessage != null) {
      await onSendMessage!(message);
    } else {
      await super.sendMessage(message);
    }
  }

  AcSyncSourceDatabase({super.dao,super.databaseType = AcEnumSqlDatabaseType.unknown}){
  }

  Future<AcResult> createDatabaseFileForDestination({
    required String destinationPath,
    String definitionName = 'default',
    String? clientDeviceId,
  }) async {
    final result = AcResult();
    logger.log("[AcSyncSourceDatabase] Starting creation of destination database file. Definition: $definitionName");
    final definition = syncDefinitions[definitionName];

    String? sourcePath;
    if (dao is AcSqliteDao) {
      sourcePath = (dao as AcSqliteDao).sqlConnection.database;
    }

    if (sourcePath == null || sourcePath.isEmpty) {
      logger.error("[AcSyncSourceDatabase] Source database path not available, cannot create destination file.");
      return result.setFailure(message: "Source database path not available");
    }

    try {
      logger.log("[AcSyncSourceDatabase] Creating database file for destination at '$destinationPath'...");
      final databaseManager = AcSyncDatabaseManager();
      await databaseManager.createDatabaseFileForDestination(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        tableDefinitions: definition != null?definition.tableDefinitions:null,
      );

      logger.log("[AcSyncSourceDatabase] Database file created. Initializing destination database metadata...");
      int lastChangeLogId = 0;
      AcResult getLastResult = await getLastChangeLogId();
      if(getLastResult.isSuccess()){
        if(getLastResult.value > 0){
          lastChangeLogId = getLastResult.value;
        }
      }
      logger.log("[AcSyncSourceDatabase] Current last change log ID: $lastChangeLogId");

      if (clientDeviceId != null) {
        logger.log("[AcSyncSourceDatabase] Provisioning client database with ID: $clientDeviceId");
        await databaseManager.provisionClientDatabase(
          destinationPath: destinationPath,
          clientDeviceId: clientDeviceId,
          serverDeviceId: deviceId!,
          serverLastLogId: lastChangeLogId,
          serverDeviceDetails: {},
        );

        logger.log("[AcSyncSourceDatabase] Registering new destination device in source database...");
        await dao!.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
          TblAcSyncDevices.isSourceOfTruth: 0,
          TblAcSyncDevices.lastSyncChangeLogId: lastChangeLogId,
          TblAcSyncDevices.syncDeviceId: clientDeviceId,
          TblAcSyncDevices.lastSyncedOn: DateTime.now().toUtcIso8601String()
        });
      } else {
        AcSqliteDao destinationDao = AcSqliteDao();
        destinationDao.sqlConnection = AcSqlConnection(database: destinationPath);
        String destinationDeviceId = Autocode.uuid();
        logger.log("[AcSyncSourceDatabase] New destination device ID: $destinationDeviceId");
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
          TblAcSyncDevices.lastSyncedOn: DateTime.now().toUtcIso8601String()
        });
        logger.log("[AcSyncSourceDatabase] Destination metadata: Registered Source Device $deviceId with last ID $lastChangeLogId");
        await destinationDao.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
          TblAcSyncDevices.isSourceOfTruth: 0,
          TblAcSyncDevices.lastSyncChangeLogId: lastChangeLogId,
          TblAcSyncDevices.syncDeviceId: destinationDeviceId,
          TblAcSyncDevices.lastSyncedOn: DateTime.now().toUtcIso8601String()
        });
        logger.log("[AcSyncSourceDatabase] Destination metadata: Registered Destination Device $destinationDeviceId with last ID $lastChangeLogId");
        logger.log("[AcSyncSourceDatabase] Registering new destination device in source database...");
        await dao!.insertRow(tableName: AcSyncTables.acSyncDevices, row: {
          TblAcSyncDevices.isSourceOfTruth: 0,
          TblAcSyncDevices.lastSyncChangeLogId: lastChangeLogId,
          TblAcSyncDevices.syncDeviceId: destinationDeviceId,
          TblAcSyncDevices.lastSyncedOn: DateTime.now().toUtcIso8601String()
        });
      }
      result.setSuccess();
      logger.log("[AcSyncSourceDatabase] Destination database file creation complete.");
    } catch (e, stack) {
      logger.log("[AcSyncSourceDatabase] Error creating destination database: $e");
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
      logger.log("[AcSyncSourceDatabase] Pruning synced change logs...");
      // 1. Get the minimum last_sync_change_log_id from all devices
      var minIdResult = await dao!.getRows(
          statement: "SELECT MIN(${TblAcSyncDevices.lastSyncChangeLogId}) as min_id FROM ${AcSyncTables.acSyncDevices}"
      );

      if (minIdResult.isSuccess() && minIdResult.rows.isNotEmpty) {
        var minId = minIdResult.rows.first['min_id'];

        if (minId != null) {
          int id = int.parse(minId.toString());
          logger.log("[AcSyncSourceDatabase] Minimum synced ID across all devices: $id. Deleting older logs...");

          // 2. Delete logs that are already synced across all devices
          await dao!.deleteRows(
              tableName: AcSyncTables.acSyncChangeLogs,
              condition: "${TblAcSyncChangeLogs.syncChangeLogId} <= $id"
          );

          result.setSuccess(message: "Pruned logs up to ID $id");
          logger.log("[AcSyncSourceDatabase] Pruned logs up to ID $id");
        } else {
          logger.log("[AcSyncSourceDatabase] No logs to prune (min_id is null)");
          result.setSuccess(message: "No logs to prune (min_id is null)");
        }
      } else {
        logger.log("[AcSyncSourceDatabase] Failed to get minimum synced ID: ${minIdResult.message}");
        result.setFromResult(result: minIdResult);
      }
    } catch (e, stack) {
      logger.log("[AcSyncSourceDatabase] Error pruning logs: $e");
      result.setException(exception: e, stackTrace: stack);
    }

    return result;
  }

  Future<AcResult> getDestinationLastChangeLogId(String destinationDeviceId) async {
    AcResult result = AcResult();
    logger.log("[AcSyncSourceDatabase] Getting last sync change log ID for destination device: $destinationDeviceId");
    final getResult = await dao!.getRows(
        statement: "SELECT ${TblAcSyncDevices.lastSyncChangeLogId} FROM ${AcSyncTables.acSyncDevices} WHERE ${TblAcSyncDevices.syncDeviceId} = @remoteDeviceId",
      parameters: {"@remoteDeviceId":destinationDeviceId}
    );
    if (getResult.isSuccess()) {
      if(getResult.rows.isNotEmpty){
        int id = getResult.rows.first.getInt(TblAcSyncDevices.lastSyncChangeLogId);
        logger.log("[AcSyncSourceDatabase] Destination device '$destinationDeviceId' last sync ID: $id");
        result.setSuccess(value: id);
      }
      else{
        logger.log("[AcSyncSourceDatabase] Destination device '$destinationDeviceId' not found, defaulting to 0.");
        result.setSuccess(value: 0);
      }
    }
    else{
      logger.error("[AcSyncSourceDatabase] Failed to get last sync ID for destination device '$destinationDeviceId': ${getResult.message}");
      result.setFromResult(result: getResult);
    }
    return result;
  }

  Future<AcResult> handleNotifyChangesFromDestination({required AcNotifyChangesToSourceFunArgs destinationNotifyArgs})  async {
    AcResult result = AcResult();
    logger.log("[AcSyncSourceDatabase] Received notification of changes from destination (Device ID: ${destinationNotifyArgs.deviceId})...");
    logger.log("[AcSyncSourceDatabase] Tables with changes : ${destinationNotifyArgs.changes!.tableChanges.length}");
    logger.log("[AcSyncSourceDatabase] Saving device sync log (STARTED)...");
    var startSyncLogResult = await saveDeviceSyncLog(
        deviceId: destinationNotifyArgs.deviceId!,
        startTimestamp: destinationNotifyArgs.startTimestamp,
        oldSyncChangeLogId: destinationNotifyArgs.lastSyncChangeLogId,
        syncOperationResult: 'STARTED'
    );
    lastDeviceSyncLogId = startSyncLogResult.value ?? 0;
    
    logger.log("[AcSyncSourceDatabase] Extracting source changes for destination (since ID: ${destinationNotifyArgs.lastSyncChangeLogId})...");
    var getChangesResult = await getSyncChanges(lastSyncId: destinationNotifyArgs.lastSyncChangeLogId!);
    if(getChangesResult.isSuccess()){
      final changes = getChangesResult.value as AcSyncChanges;
      logger.log("[AcSyncSourceDatabase] Source changes extracted. Table count: ${changes.tableChanges.length}");

      bool continueOperation = true;
      if(destinationNotifyArgs.changes != null){
        AcResult applyChangesResult = await applySyncChanges(changes: destinationNotifyArgs.changes!);
        if(applyChangesResult.isFailure()){
          continueOperation = false;
          result.setFromResult(result: applyChangesResult);
        }
      }
      if(continueOperation){
        AcNotifyChangesCallbackArgs callbackArgs = AcNotifyChangesCallbackArgs();
        callbackArgs.deviceId = deviceId;
        callbackArgs.sourceChanges = changes;

        logger.log("[AcSyncSourceDatabase] Getting current last change log ID...");
        final lastChangeLogIdResult = await getLastChangeLogId();
        if(lastChangeLogIdResult.isFailure()){
          logger.log("[AcSyncSourceDatabase] Failed to get last change log ID: ${lastChangeLogIdResult.message}");
          result.setFromResult(result: lastChangeLogIdResult);
          return result;
        }

        int lastChangeLogId = lastChangeLogIdResult.value ?? 0;
        callbackArgs.lastSyncChangeLogId = lastChangeLogId;
        logger.log("[AcSyncSourceDatabase] Current last change log ID: $lastChangeLogId. Sending response to destination.");

        result.setSuccess(value: callbackArgs);
      }
    }
    else{
      logger.log("[AcSyncSourceDatabase] Failed to extract changes: ${getChangesResult.message}");
      result.setFromResult(result: getChangesResult);
    }
    return result;
  }

  Future<AcResult> handleNotifySyncSuccessFromSource({required AcNotifySyncSuccessToSourceFunArgs destinationNotifyArgs}) async {
    AcResult result = AcResult();
    logger.log("[AcSyncSourceDatabase] Received sync success notification from destination (Device ID: ${destinationNotifyArgs.deviceId})...");
    
    AcNotifySuccessCallbackArgs callbackArgs = AcNotifySuccessCallbackArgs();
    logger.log("[AcSyncSourceDatabase] Updating last sync ID for destination...");
    var updateSelfSyncIdResult = await updateLastSyncChangeLogId(deviceId: destinationNotifyArgs.deviceId!,lastSyncChangeLogId:destinationNotifyArgs.lastSyncChangeLogId!);
    if(updateSelfSyncIdResult.isSuccess()){
      logger.log("[AcSyncSourceDatabase] Last sync ID updated. Getting new last change log ID...");
      final lastChangeLogIdResult = await getLastChangeLogId();
      if(lastChangeLogIdResult.isFailure()){
        logger.log("[AcSyncSourceDatabase] Failed to get last change log ID: ${lastChangeLogIdResult.message}");
        result.setFromResult(result: lastChangeLogIdResult);
        return result;
      }

      int lastChangeLogId = lastChangeLogIdResult.value ?? 0;
      logger.log("[AcSyncSourceDatabase] New last change log ID: $lastChangeLogId. Updating sync log (COMPLETED)...");
      callbackArgs.lastSyncChangeLogId = lastChangeLogId;
      callbackArgs.deviceId = deviceId;
      await saveDeviceSyncLog(
          deviceId: destinationNotifyArgs.deviceId!,
          endTimestamp:destinationNotifyArgs.endTimestamp,
          newSyncChangeLogId: destinationNotifyArgs.lastSyncChangeLogId,
          syncOperationResult: 'COMPLETED',
          syncDeviceLogId: lastDeviceSyncLogId
      );
      logger.log("[AcSyncSourceDatabase] Sync cycle finished for destination.");
      result.setSuccess(value: callbackArgs);
    }
    else{
      logger.log("[AcSyncSourceDatabase] Failed to update last sync ID: ${updateSelfSyncIdResult.message}");
      result.setFromResult(result: updateSelfSyncIdResult);
    }
    return result;
  }
}