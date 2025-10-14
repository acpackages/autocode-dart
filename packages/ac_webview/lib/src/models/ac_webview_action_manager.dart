import 'dart:core';
import 'package:ac_webview/src/models/ac_webview_channel_action.dart';
import 'package:autocode/autocode.dart';

class AcWebviewActionManager {
  final AcEvents events = AcEvents();
  final AcLogger logger = AcLogger();

  String on({required String action,required Function callback}){
    logger.log("Registering callback for action $action");
    var id = events.subscribe(event: action, callback: callback);
    logger.log("Registered callback for action $action!");
    return id;
  }

  Future<AcWebviewChannelAction> performAction({required Map<String,dynamic> actionJson}) async{
    AcWebviewChannelAction channelAction = AcWebviewChannelAction.fromJson(jsonData: actionJson);
    logger.log(actionJson);
    if(channelAction.action.isNotEmpty){
      logger.log("Performing action ${channelAction.action}");
      await events.execute(key: channelAction.action,args: [channelAction]);
      logger.log("Action response ${channelAction.response}");
    }
    else{
      logger.error("Action not found in channelAction");
    }
    return channelAction;
  }
}