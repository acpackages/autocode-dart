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

  AcSyncOnWs({
    this.socket,
    this.syncDestinationDatabase,
    this.syncSourceDatabase,
    this.eventName = 'acSync',
  }) {
    _init();
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
        }
      });
    }
  }
}
