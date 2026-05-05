import 'package:ac_sync/src/models/ac_notify_changes_to_source_fun_args.dart';
import 'package:ac_sync/src/models/ac_notify_success_callback_args.dart';
import 'package:ac_sync/src/models/ac_notify_sync_success_to_source_fun_args.dart';
import 'package:autocode/autocode.dart';
import '../../ac_sync.dart';
import '../models/ac_notify_changes_callback_args.dart';

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
      statement: "SELECT MAX(${TblAcSyncChangeLogs.syncChangeLogId}) AS ${TblAcSyncChangeLogs.syncChangeLogId} FROM ${Tables.acSyncChangeLogs}"
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
    print("AcSyncDestinationDatabase: Starting sync (isNested: $isNested)...");
    final result = AcResult();
    String startTimestamp = DateTime.now().toIso8601String();
    if (isSyncing && !isNested) {
      print("AcSyncDestinationDatabase: Sync already in progress, skipping.");
      return result.setFailure(message: "Synchronization already in progress");
    }
    if (dao == null) {
      print("AcSyncDestinationDatabase: DAO not set, skipping sync.");
      return result.setFailure(message: "DAO not set");
    }

    if(!isNested){
      isSyncing = true;
    }

    bool isWorking = true;
    try {
      if (isDestination && notifyChangesToSourceFun !=null) {
        // Step 01 & 02: Check changes and send to server along with last server ID
        print("AcSyncDestinationDatabase: Getting last change log ID...");
        final lastChangeLogIdResult = await getLastChangeLogId();

        if(lastChangeLogIdResult.isFailure()){
          print("AcSyncDestinationDatabase: Failed to get last change log ID: ${lastChangeLogIdResult.message}");
          result.setFromResult(result: lastChangeLogIdResult);
          return result;
        }

        int lastChangeLogId = lastChangeLogIdResult.value ?? 0;
        print("AcSyncDestinationDatabase: Last change log ID: $lastChangeLogId");

        int lastSourceChangeLogId = 0;
        print("AcSyncDestinationDatabase: Getting last source change log ID...");
        var sourceLastSyncIdResult = await dao!.getRows(
            statement: "SELECT ${TblAcSyncDevices.lastSyncChangeLogId} FROM ${Tables.acSyncDevices} WHERE ${TblAcSyncDevices.isSourceOfTruth} = 1;"
        );

        if (sourceLastSyncIdResult.isFailure()){
          print("AcSyncDestinationDatabase: Failed to get last source change log ID: ${sourceLastSyncIdResult.message}");
          result.setFromResult(result: sourceLastSyncIdResult);
          return result;
        }
        lastSourceChangeLogId = sourceLastSyncIdResult.value ?? 0;
        print("AcSyncDestinationDatabase: Last source change log ID: $lastSourceChangeLogId");

        print("AcSyncDestinationDatabase: Saving device sync log (STARTED)...");
        var startSyncLogResult = await saveDeviceSyncLog(
            deviceId: deviceId!,
            startTimestamp: startTimestamp,
            oldSyncChangeLogId: lastSourceChangeLogId,
            syncOperationResult: 'STARTED'
        );

        print("AcSyncDestinationDatabase: Extracting local changes...");
        final extractResult = await getSyncChanges(
          lastSyncId: lastChangeLogId,
        );

        if (!extractResult.isSuccess()) {
          print("AcSyncDestinationDatabase: Failed to extract local changes: ${extractResult.message}");
          throw extractResult.message;
        }
        final localChanges = extractResult.value as AcSyncChanges;
        print("AcSyncDestinationDatabase: Local changes extracted. Table count: ${localChanges.tableChanges.length}");

        Future<void> Function(AcNotifyChangesCallbackArgs callbackArgs) notifyCallback = (AcNotifyChangesCallbackArgs callbackArgs) async {
          print("AcSyncDestinationDatabase: Received remote changes from source. Last sync log ID from source: ${callbackArgs.lastSyncChangeLogId}");
          int sourceLastSyncChangeLogId = callbackArgs.lastSyncChangeLogId!;
          
          print("AcSyncDestinationDatabase: Applying remote changes...");
          var applyResult = await applySyncChanges(changes: callbackArgs.sourceChanges!);
          if(applyResult.isSuccess()){
            print("AcSyncDestinationDatabase: Remote changes applied. Updating source sync ID...");
            var updateSourceSyncIdResult = await updateLastSyncChangeLogId(deviceId: callbackArgs.deviceId!,lastSyncChangeLogId: sourceLastSyncChangeLogId);
            if(updateSourceSyncIdResult.isSuccess()){
              print("AcSyncDestinationDatabase: Source sync ID updated. Getting new last change log ID...");
              final newLastChangeLogIdResult = await getLastChangeLogId();

              if(newLastChangeLogIdResult.isFailure()){
                print("AcSyncDestinationDatabase: Failed to get new last change log ID: ${newLastChangeLogIdResult.message}");
                result.setFromResult(result: newLastChangeLogIdResult);
              }

              int newLastChangeLogId = newLastChangeLogIdResult.value ?? 0;
              print("AcSyncDestinationDatabase: New last change log ID: $newLastChangeLogId. Updating self sync ID...");
              var updateSelfSyncIdResult = await updateLastSyncChangeLogId(deviceId: deviceId!,lastSyncChangeLogId:newLastChangeLogId);
              if(updateSelfSyncIdResult.isSuccess()){
                print("AcSyncDestinationDatabase: Self sync ID updated. Saving device sync log (COMPLETED)...");
                String endTimestamp = DateTime.now().toIso8601String();
                await saveDeviceSyncLog(
                  deviceId: deviceId!,
                  endTimestamp: endTimestamp,
                  newSyncChangeLogId: sourceLastSyncChangeLogId,
                  syncOperationResult: 'COMPLETED',
                  syncDeviceLogId: startSyncLogResult.value ?? 0
                );

                Future<void> Function(AcNotifySuccessCallbackArgs callbackArgs) notifySuccessCallback = (AcNotifySuccessCallbackArgs callbackArgs) async {
                  print("AcSyncDestinationDatabase: Received sync success confirmation from source.");
                  result.setSuccess();
                  if(callbackArgs.lastSyncChangeLogId! > newLastChangeLogId){
                    print("AcSyncDestinationDatabase: Remote has more changes (${callbackArgs.lastSyncChangeLogId} > $newLastChangeLogId). Triggering nested sync...");
                    result.setFromResult(result:await sync(isNested: false));
                  }
                  isWorking = false;
                  print("AcSyncDestinationDatabase: Sync cycle finished.");
                };
                var successArgs = AcNotifySyncSuccessToSourceFunArgs(
                  lastSyncChangeLogId: callbackArgs.lastSyncChangeLogId,
                  deviceId: deviceId,
                  notifyCallback: notifySuccessCallback,
                  endTimestamp: endTimestamp,
                );
                print("AcSyncDestinationDatabase: Notifying sync success to source...");
                await notifySyncSuccessToSourceFun!(successArgs);
              }
              else{
                print("AcSyncDestinationDatabase: Failed to update self sync ID: ${updateSelfSyncIdResult.message}");
                result.setFromResult(result: updateSelfSyncIdResult);
                isWorking = false;
              }
            }
            else{
              print("AcSyncDestinationDatabase: Failed to update source sync ID: ${updateSourceSyncIdResult.message}");
              result.setFromResult(result: updateSourceSyncIdResult);
              isWorking = false;
            }
          }
          else{
            print("AcSyncDestinationDatabase: Failed to apply remote changes: ${applyResult.message}");
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

        print("AcSyncDestinationDatabase: Notifying local changes to source...");
        await notifyChangesToSourceFun!(changesArgs);

        print("AcSyncDestinationDatabase: Waiting for source to process changes...");
        while(isWorking){
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
      else {
        print("AcSyncDestinationDatabase: Notification function not set. notifyChangesToSourceFun: ${notifyChangesToSourceFun != null}, isDestination: $isDestination");
      }
    } catch (e, stack) {
      print("AcSyncDestinationDatabase: Sync error: $e");
      result.setException(exception: e, stackTrace: stack);
    } finally {
      isSyncing = false;
      print("AcSyncDestinationDatabase: Sync process ended.");
    }
    return result;
  }

}