import 'dart:io';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:autocode/autocode.dart';
import 'package:ac_sync/ac_sync.dart';

class AcSyncOnWs {
  final String eventName;
  final AcWebSocket? socket;
  final AcSyncDestinationDatabase? syncDestinationDatabase;
  final AcSyncSourceDatabase? syncSourceDatabase;

  Future<void> Function({required AcSyncProgress progress})? onSyncProgress;
  List<int> _receivedSyncStream = [];
  Future<void> Function()? onSyncStart;
  Future<void> Function()? onSyncComplete;
  String? _destinationFilePath;

  AcSyncOnWs({
    this.socket,
    this.syncDestinationDatabase,
    this.syncSourceDatabase,
    this.eventName = 'acSync',
    this.onSyncStart,
    this.onSyncComplete,
    this.onSyncProgress,
  }) {
    _init();
  }

  Future<AcResult> sync() async {
    AcResult result = AcResult();
    if (socket != null && syncDestinationDatabase != null) {
      print("AcSyncOnWs: Initiating sync request from database...");
      result = await this.syncDestinationDatabase!.sync();
    } else {
      result.setFailure(message: "Socket not set");
    }
    return result;
  }

  Future<AcResult> getDatabaseFileFromSource({required String destinationFilePath}) async {
    AcResult result = AcResult();
    if (socket != null && syncDestinationDatabase != null) {
      this._destinationFilePath = destinationFilePath;
      Map<String,dynamic> data = {
        'syncAction':'getDatabaseFileForDestination',
        'syncData':{}
      };
      this.socket!.emit(event: eventName,data:data );
      print("AcSyncOnWs: Initiating sync request from database...");
      result = await this.syncDestinationDatabase!.sync();
    } else {
      result.setFailure(message: "Socket not set");
    }
    return result;
  }

  void _init() {

    if(syncDestinationDatabase != null){
      Future<void> Function(AcNotifyChangesToSourceFunArgs callbackArgs) notifyChangesCallback = (AcNotifyChangesToSourceFunArgs callbackArgs) async {
        Map<String,dynamic> data = {
          'syncAction':'notifyChangesFromDestination',
          'syncData':callbackArgs.toJson()
        };
        socket!.emit(event: eventName,data:data, callback: ({response}){
          AcResult result = AcResult.instanceFromJson(jsonData: response);
          if(result.isSuccess()){
            AcNotifyChangesCallbackArgs resultCallbackArgs = AcNotifyChangesCallbackArgs.instanceFromJson(jsonData: result.value);
            callbackArgs.notifyCallback!(resultCallbackArgs);
          }
        } );

      };
      Future<void> Function(AcNotifySyncSuccessToSourceFunArgs callbackArgs) notifySuccessCallback = (AcNotifySyncSuccessToSourceFunArgs callbackArgs) async {
        print("Test: Destination notifying sync success to source...");
        Map<String,dynamic> data = {
          'syncAction':'notifySyncSuccessToSource',
          'syncData':callbackArgs.toJson()
        };
        socket!.emit(event: eventName,data:data, callback: ({response}){
          AcResult result = AcResult.instanceFromJson(jsonData: response);
          if(result.isSuccess()){
            AcNotifySuccessCallbackArgs resultCallbackArgs = AcNotifySuccessCallbackArgs.instanceFromJson(jsonData: result.value);
            callbackArgs.notifyCallback!(resultCallbackArgs);
          }
        } );
      };
      syncDestinationDatabase!.notifyChangesToSourceFun = notifyChangesCallback;
      syncDestinationDatabase!.notifySyncSuccessToSourceFun = notifySuccessCallback;

      socket!.onFile(event: "${eventName}DestinationFile", handler: ({required transferId, required name, required totalSize, required stream, metadata}) async {
          print("AcSyncOnWs: Receiving sync stream start. Total size: $totalSize");
          if (onSyncStart != null) onSyncStart!();
          File destinationFile = File(_destinationFilePath!);
          String tempFilePath = "${destinationFile.parent}/-ac-sync-temp-file-${Autocode.uuid()}";
          File tempDestinationFile = File(tempFilePath);
          if(!tempDestinationFile.existsSync()){
            tempDestinationFile.createSync(recursive: true);
          }

          int received = 0;
          await for (final chunk in stream) {
            tempDestinationFile.writeAsBytesSync(chunk,mode: FileMode.append,flush: true);
            received += chunk.length;
            if (onSyncProgress != null) {
              onSyncProgress!(progress: AcSyncProgress(
                title: 'Receiving Database',
                description: 'Downloading synchronization data...',
                total: totalSize,
                progress: received / totalSize,
                pendingCount: 1,
              ));
            }
          }
          await tempDestinationFile.rename(destinationFile.fileName);
          print("AcSyncOnWs: Sync stream received. Total bytes: ${_receivedSyncStream.length}");
          if (onSyncComplete != null) {
            await onSyncComplete!();
          }
          _receivedSyncStream = [];
      });
    }
    else{
      socket!.on(event: eventName, handler: ({data,callback}) async {
        Map<String,dynamic> eventData = Map.from(data);
        if(eventData.containsKey("syncAction")){
          String syncAction = eventData.getString("syncAction");
          Map<String,dynamic> syncData = Map.from(eventData.getMap("syncData"));
          if(syncAction.equalsIgnoreCase("notifyChangesFromDestination")){
            AcResult result = AcResult();
            if(syncSourceDatabase!= null){
              AcNotifyChangesToSourceFunArgs callbackArgs = AcNotifyChangesToSourceFunArgs.instanceFromJson(jsonData: syncData);
              result = await syncSourceDatabase!.handleNotifyChangesFromDestination(destinationNotifyArgs: callbackArgs);
            }
            else{
              result.setFailure(message: "Destination database for sync not set");
            }
            callback!(response: result);
          }
          else if(syncAction.equalsIgnoreCase("notifySyncSuccessToSource")){
            AcResult result = AcResult();
            if(syncSourceDatabase!= null){
              AcNotifySyncSuccessToSourceFunArgs callbackArgs = AcNotifySyncSuccessToSourceFunArgs.instanceFromJson(jsonData: syncData);
              result = await syncSourceDatabase!.handleNotifySyncSuccessFromSource(destinationNotifyArgs: callbackArgs);
            }
            else{
              result.setFailure(message: "Destination database for sync not set");
            }
            callback!(response: result);
          }
          else if(syncAction.equalsIgnoreCase("getDatabaseFileForDestination")){
            AcResult result = AcResult();
            if(syncSourceDatabase != null){
              String tempPath = "temp_sync_${Autocode.uuid()}.db";
              File tempFile = File(tempPath);

              try {
                // 1. Create temporary destination copy
                tempFile.createSync(recursive: true);
                print("AcSyncOnWs: Creating temporary destination copy for sync...");
                await syncSourceDatabase!.createDatabaseFileForDestination(destinationPath: tempPath);
                
                // 2. Send the data via stream from source to destination
                print("AcSyncOnWs: Streaming database content to client...");
                if (onSyncStart != null) onSyncStart!();
                final int totalSize = await tempFile.length();
                await socket!.sendFile(
                  file: tempFile, 
                  event: "${eventName}DestinationFile",
                  onProgress: (progress) {
                    if (onSyncProgress != null) {
                      onSyncProgress!(progress: AcSyncProgress(
                        title: 'Sending Database',
                        description: 'Uploading synchronization data...',
                        total: totalSize,
                        progress: progress,
                        pendingCount: 1,
                      ));
                    }
                    print("AcSyncOnWs: Sync upload progress: ${(progress * 100).toStringAsFixed(1)}%");
                  },
                );
                if (onSyncComplete != null) onSyncComplete!();
                tempFile.delete();
                result.setSuccess(message: "Sync stream completed successfully");
                print("AcSyncOnWs: Sync stream complete.");
              } catch (e, stack) {
                print("AcSyncOnWs: Error during sync action: $e");
                result.setException(exception: e, stackTrace: stack);
              } finally {
                // 3. Remove the copy once done
                if (await tempFile.exists()) {
                  print("AcSyncOnWs: Removing temporary sync file...");
                  await tempFile.delete();
                }
              }
            }
            else{
              result.setFailure(message: "Source database for sync not set");
            }
            if (callback != null) {
              callback(response: result);
            }
          }
        }
      });
    }
  }
}
