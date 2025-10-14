import 'dart:core';

class AcWebviewChannelAction {
  String action = "";
  Map<String,dynamic>? data;
  String? callbackId;
  dynamic response;

  static AcWebviewChannelAction fromJson({required Map<String,dynamic> jsonData}){
    var result = AcWebviewChannelAction();
    if(jsonData.containsKey('action')){
      result.action = jsonData['action'];
    }
    if(jsonData.containsKey('data')){
      result.data = jsonData['data'];
    }
    if(jsonData.containsKey('callbackId')){
      result.callbackId = jsonData['callbackId'];
    }
    return result;
  }
}