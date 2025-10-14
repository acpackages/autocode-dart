import 'dart:convert';
import 'dart:io';
import 'package:ac_webview/src/models/ac_webview_action_manager.dart';
import 'package:ac_webview/src/models/ac_webview_channel_action.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_plugin.dart';

class AcWebview extends StatefulWidget{
  final String url;
  late BuildContext context;
  final AcLogger logger = AcLogger();
  Color? backgroundColor;
  _AcWebviewState state=_AcWebviewState();
  final AcWebviewActionManager actionManager = AcWebviewActionManager();
  AcWebview({required this.url,this.backgroundColor,super.key});
  @override
  State<AcWebview> createState() => state;

  String onAction({required String name, required Function callback}){
    return actionManager.on(action: name, callback: callback);
  }

  void emitEvent({required String name, dynamic? data}){
    sendDataToWebview({'event':'appContextChange','data':data});
  }

  loadUrl(String url)async{
    await state.loadUrl(url);
  }

  void sendDataToWebview(dynamic data){
    String evalCode="acWebviewChannel.receive({data:${jsonEncode(data)}});";
    state.runJavascript(evalCode);
  }

  Future<bool> handleBack() async {
    return await state.goBack();
  }
}
class _AcWebviewState extends State<AcWebview> {
  late WebViewController controller;
  String url="";
  Widget displayWidget=Text("");
  bool initialized=false,available=true;
  bool defaultWeb=true,notifyOnInternet=false,isFullscreen=false;
  int localServerPort=0;
  Map<String,dynamic> config = {};
  Autocode simplify=Autocode();
  late WebViewWidget webview;
  log(dynamic message){
    widget.logger.log(message);
  }
  
  goBack() async {
    var status = await controller.canGoBack();
    log("Handling Back : $status");
    if (status) {
      controller.goBack();
      return false;
    } else {
      SystemNavigator.pop();
      log("Handling Popup : ${true}");
      return true;
    }
  }

  initWebview() async{
    if(!initialized) {
      initialized = true;
      if(url.isEmpty){
        url=widget.url;
      }
      if(Platform.isWindows){
        WindowsWebViewPlatform.registerWith();
      }
      controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.addJavaScriptChannel("acWebviewJavascriptChannel", onMessageReceived: (message) {
        messageFromWebview(jsonDecode(message.message) .cast<String,dynamic>());
      });
      if(widget.backgroundColor!=null){
        controller.setBackgroundColor(widget.backgroundColor!);
      }
      webview = WebViewWidget(controller: controller);
      await controller.loadRequest(Uri.parse(url));
      // widget.registerAppTasks();
    }
    setState(() {
      displayWidget = webview;
    });
  }

  loadUrl(String webUrl)async{
    log("Loading Url : $url");
    url=webUrl;
    if(initialized){
      await controller.loadRequest(Uri.parse(url));
    }
  }

  Future<void> messageFromWebview(Map<String,dynamic> data) async {
    log("Received message from webview");
    AcWebviewChannelAction channelAction = await widget.actionManager.performAction(actionJson: data);
    if(channelAction.callbackId != null && channelAction.callbackId!.isNotEmpty){
      log("Channel action has valid callback id");
      Map<String,dynamic> response = {"callbackId":channelAction.callbackId,"actionResponse":channelAction.response};
      widget.sendDataToWebview(response);
    }
    else{
      log("Channel action does not have valid callback id");
    }
  }

  runJavascript(String script){
    log("Executing script : $script");
    controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    widget.context=context;
    initWebview();
    return displayWidget;
  }

}