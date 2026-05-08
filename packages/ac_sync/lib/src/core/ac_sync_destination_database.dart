import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';

class AcSyncDestinationDatabase extends AcSyncDatabase{

  bool isDestination = true;
  
  Function(AcNotifyChangesToSourceFunArgs args)? notifyChangesToSourceFun;
  Function(AcNotifySyncSuccessToSourceFunArgs args)? notifySyncSuccessToSourceFun;

  AcSyncDestinationDatabase({super.dao,super.databaseType = AcEnumSqlDatabaseType.unknown}){
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

  Future<AcResult> sync({bool isNested = false}) async {
    logger.log("AcSyncDestinationDatabase: Starting sync (isNested: $isNested)...");
    final result = AcResult();
    String startTimestamp = DateTime.now().toIso8601String();
    if (isSyncing && !isNested) {
      logger.log("AcSyncDestinationDatabase: Sync already in progress, skipping.");
      return result.setFailure(message: "Synchronization already in progress");
    }
    if (dao == null) {
      logger.log("AcSyncDestinationDatabase: DAO not set, skipping sync.");
      return result.setFailure(message: "DAO not set");
    }

    if(!isNested){
      isSyncing = true;
      if (onSyncStart != null) onSyncStart!();
    }

    bool isWorking = true;
    try {
      if (isDestination && notifyChangesToSourceFun !=null) {
        // Step 01 & 02: Check changes and send to server along with last server ID
        logger.log("AcSyncDestinationDatabase: Getting last change log ID...");
        final lastChangeLogIdResult = await getLastChangeLogId();

        if(lastChangeLogIdResult.isFailure()){
          logger.log("AcSyncDestinationDatabase: Failed to get last change log ID: ${lastChangeLogIdResult.message}");
          result.setFromResult(result: lastChangeLogIdResult);
          return result;
        }

        int lastChangeLogId = lastChangeLogIdResult.value ?? 0;
        logger.log("AcSyncDestinationDatabase: Last change log ID: $lastChangeLogId");

        int lastSourceChangeLogId = 0;
        logger.log("AcSyncDestinationDatabase: Getting last source change log ID...");
        var sourceLastSyncIdResult = await dao!.getRows(
            statement: "SELECT ${TblAcSyncDevices.lastSyncChangeLogId} FROM ${AcSyncTables.acSyncDevices} WHERE ${TblAcSyncDevices.isSourceOfTruth} = 1;"
        );

        if (sourceLastSyncIdResult.isFailure()){
          logger.log("AcSyncDestinationDatabase: Failed to get last source change log ID: ${sourceLastSyncIdResult.message}");
          result.setFromResult(result: sourceLastSyncIdResult);
          return result;
        }
        lastSourceChangeLogId = sourceLastSyncIdResult.value ?? 0;
        logger.log("AcSyncDestinationDatabase: Last source change log ID: $lastSourceChangeLogId");

        logger.log("AcSyncDestinationDatabase: Saving device sync log (STARTED)...");
        var startSyncLogResult = await saveDeviceSyncLog(
            deviceId: deviceId!,
            startTimestamp: startTimestamp,
            oldSyncChangeLogId: lastSourceChangeLogId,
            syncOperationResult: 'STARTED'
        );

        logger.log("AcSyncDestinationDatabase: Extracting local changes...");
        final extractResult = await getSyncChanges(
          lastSyncId: lastChangeLogId,
        );

        if (!extractResult.isSuccess()) {
          logger.log("AcSyncDestinationDatabase: Failed to extract local changes: ${extractResult.message}");
          throw extractResult.message;
        }
        final localChanges = extractResult.value as AcSyncChanges;
        logger.log("AcSyncDestinationDatabase: Local changes extracted. Table count: ${localChanges.tableChanges.length}");

        Future<void> Function(AcNotifyChangesCallbackArgs callbackArgs) notifyCallback = (AcNotifyChangesCallbackArgs callbackArgs) async {
          logger.log("AcSyncDestinationDatabase: Received remote changes from source. Last sync log ID from source: ${callbackArgs.lastSyncChangeLogId}");
          int sourceLastSyncChangeLogId = callbackArgs.lastSyncChangeLogId!;
          
          logger.log("AcSyncDestinationDatabase: Applying remote changes...");
          var applyResult = await applySyncChanges(changes: callbackArgs.sourceChanges!);
          if(applyResult.isSuccess()){
            logger.log("AcSyncDestinationDatabase: Remote changes applied. Updating source sync ID...");
            var updateSourceSyncIdResult = await updateLastSyncChangeLogId(deviceId: callbackArgs.deviceId!,lastSyncChangeLogId: sourceLastSyncChangeLogId);
            if(updateSourceSyncIdResult.isSuccess()){
              logger.log("AcSyncDestinationDatabase: Source sync ID updated. Getting new last change log ID...");
              final newLastChangeLogIdResult = await getLastChangeLogId();

              if(newLastChangeLogIdResult.isFailure()){
                logger.log("AcSyncDestinationDatabase: Failed to get new last change log ID: ${newLastChangeLogIdResult.message}");
                result.setFromResult(result: newLastChangeLogIdResult);
              }

              int newLastChangeLogId = newLastChangeLogIdResult.value ?? 0;
              logger.log("AcSyncDestinationDatabase: New last change log ID: $newLastChangeLogId. Updating self sync ID...");
              var updateSelfSyncIdResult = await updateLastSyncChangeLogId(deviceId: deviceId!,lastSyncChangeLogId:newLastChangeLogId);
              if(updateSelfSyncIdResult.isSuccess()){
                logger.log("AcSyncDestinationDatabase: Self sync ID updated. Saving device sync log (COMPLETED)...");
                String endTimestamp = DateTime.now().toIso8601String();
                await saveDeviceSyncLog(
                  deviceId: deviceId!,
                  endTimestamp: endTimestamp,
                  newSyncChangeLogId: sourceLastSyncChangeLogId,
                  syncOperationResult: 'COMPLETED',
                  syncDeviceLogId: startSyncLogResult.value ?? 0
                );

                Future<void> Function(AcNotifySuccessCallbackArgs callbackArgs) notifySuccessCallback = (AcNotifySuccessCallbackArgs callbackArgs) async {
                  logger.log("AcSyncDestinationDatabase: Received sync success confirmation from source.");
                  result.setSuccess();
                  
                  // Delete rows that are marked to be deleted after successful sync (e.g. logs/queue)
                  await deleteSyncedRows(changes: localChanges);

                  if(callbackArgs.lastSyncChangeLogId! > newLastChangeLogId){
                    logger.log("AcSyncDestinationDatabase: Remote has more changes (${callbackArgs.lastSyncChangeLogId} > $newLastChangeLogId). Triggering nested sync...");
                    result.setFromResult(result:await sync(isNested: false));
                  }
                  isWorking = false;
                  logger.log("AcSyncDestinationDatabase: Sync cycle finished.");
                };
                var successArgs = AcNotifySyncSuccessToSourceFunArgs(
                  lastSyncChangeLogId: callbackArgs.lastSyncChangeLogId,
                  deviceId: deviceId,
                  notifyCallback: notifySuccessCallback,
                  endTimestamp: endTimestamp,
                );
                logger.log("AcSyncDestinationDatabase: Notifying sync success to source...");
                await notifySyncSuccessToSourceFun!(successArgs);
              }
              else{
                logger.log("AcSyncDestinationDatabase: Failed to update self sync ID: ${updateSelfSyncIdResult.message}");
                result.setFromResult(result: updateSelfSyncIdResult);
                isWorking = false;
              }
            }
            else{
              logger.log("AcSyncDestinationDatabase: Failed to update source sync ID: ${updateSourceSyncIdResult.message}");
              result.setFromResult(result: updateSourceSyncIdResult);
              isWorking = false;
            }
          }
          else{
            logger.log("AcSyncDestinationDatabase: Failed to apply remote changes: ${applyResult.message}");
            result.setFromResult(result: applyResult);
            isWorking = false;
          }
        };

        var changesArgs = AcNotifyChangesToSourceFunArgs(
          changes: localChanges,
          lastSyncChangeLogId: lastSourceChangeLogId,
          deviceId: deviceId,
          notifyCallback: notifyCallback,
          startTimestamp: startTimestamp
        );

        logger.log("AcSyncDestinationDatabase: Notifying local changes to source...");
        await notifyChangesToSourceFun!(changesArgs);

        logger.log("AcSyncDestinationDatabase: Waiting for source to process changes...");
        while(isWorking){
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
      else {
        logger.log("AcSyncDestinationDatabase: Notification function not set. notifyChangesToSourceFun: ${notifyChangesToSourceFun != null}, isDestination: $isDestination");
      }
    } catch (e, stack) {
      logger.log("AcSyncDestinationDatabase: Sync error: $e");
      result.setException(exception: e, stackTrace: stack);
    } finally {
      isSyncing = false;
      if (onSyncComplete != null) onSyncComplete!();
      logger.log("AcSyncDestinationDatabase: Sync process ended.");
    }
    return result;
  }

}