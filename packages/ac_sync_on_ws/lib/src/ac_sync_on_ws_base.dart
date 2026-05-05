import 'dart:convert';
import 'dart:io';
import 'package:ac_extensions/ac_extensions.dart';
import 'package:ac_sync/src/core/ac_sync_destination_database.dart';
import 'package:ac_sync/src/core/ac_sync_source_database.dart';
import 'package:ac_sync/src/models/ac_notify_changes_callback_args.dart';
import 'package:ac_sync/src/models/ac_notify_changes_to_source_fun_args.dart';
import 'package:ac_sync/src/models/ac_notify_sync_success_to_source_fun_args.dart';
import 'package:ac_sync/src/models/ac_notify_success_callback_args.dart';
import 'package:ac_web_socket/ac_web_socket.dart';
import 'package:autocode/autocode.dart';

class AcSyncOnWs {
  final String eventName;
  final AcWebSocket? socket;
  final AcSyncDestinationDatabase? syncDestinationDatabase;
  final AcSyncSourceDatabase? syncSourceDatabase;
  
  List<int> _receivedSyncStream = [];
  Future<void> Function(List<int> bytes)? onSyncStreamComplete;

  AcSyncOnWs({
    this.socket,
    this.syncDestinationDatabase,
    this.syncSourceDatabase,
    this.eventName = 'acSync',
    this.onSyncStreamComplete,
  }) {
    _init();
  }

  Future<AcResult> sync() async {
    AcResult result = AcResult();
    if (socket != null) {
      print("AcSyncOnWs: Initiating sync request...");
      await socket!.emit(
        event: eventName,
        data: {
          'syncAction': 'sync',
          'syncData': {},
        },
        callback: ({response}) {
          if (response != null) {
            result = AcResult.instanceFromJson(jsonData: response);
            print("AcSyncOnWs: Sync request response: ${result.isSuccess() ? 'Success' : 'Failure - ' + result.message}");
          }
        },
      );
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

      socket!.on(event: eventName, handler: ({data, callback}) async {
        Map<String, dynamic> eventData = Map.from(data);
        if (eventData.containsKey("syncAction")) {
          String syncAction = eventData.getString("syncAction");
          Map<String, dynamic> syncData = Map.from(eventData.getMap("syncData"));

          if (syncAction.equalsIgnoreCase("streamStart")) {
            print("AcSyncOnWs: Receiving sync stream start. Total size: ${syncData['totalSize']}");
            _receivedSyncStream = [];
          } else if (syncAction.equalsIgnoreCase("streamChunk")) {
            String chunkBase64 = syncData.getString("chunk");
            _receivedSyncStream.addAll(base64Decode(chunkBase64));
          } else if (syncAction.equalsIgnoreCase("streamEnd")) {
            print("AcSyncOnWs: Sync stream received. Total bytes: ${_receivedSyncStream.length}");
            if (onSyncStreamComplete != null) {
              await onSyncStreamComplete!(_receivedSyncStream);
            }
            _receivedSyncStream = [];
          }
        }
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
          else if(syncAction.equalsIgnoreCase("sync")){
            AcResult result = AcResult();
            if(syncSourceDatabase != null){
              String tempPath = "temp_sync_${Autocode.uuid()}.db";
              File tempFile = File(tempPath);
              try {
                // 1. Create temporary destination copy
                print("AcSyncOnWs: Creating temporary destination copy for sync...");
                await syncSourceDatabase!.createDatabaseFileForDestination(destinationPath: tempPath);
                
                // 2. Send the data via stream from source to destination
                print("AcSyncOnWs: Streaming database content to client...");
                Stream<List<int>> fileStream = tempFile.openRead();
                
                // Send stream start
                socket!.emit(event: eventName, data: {
                  'syncAction': 'streamStart',
                  'syncData': {
                    'totalSize': await tempFile.length(),
                  }
                });

                await for (List<int> chunk in fileStream) {
                  socket!.emit(event: eventName, data: {
                    'syncAction': 'streamChunk',
                    'syncData': {
                      'chunk': base64Encode(chunk),
                    }
                  });
                }
                
                // Send stream end
                socket!.emit(event: eventName, data: {
                  'syncAction': 'streamEnd',
                  'syncData': {}
                });

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
