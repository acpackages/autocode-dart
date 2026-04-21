// import 'dart:convert';
// import 'dart:io';
//
// import 'package:ac_cef/ac_cef.dart';
// import 'package:ac_webview/src/models/ac_webview_action_manager.dart';
// import 'package:ac_webview/src/models/ac_webview_channel_action.dart';
// import 'package:autocode/autocode.dart';
// import 'package:flutter/material.dart';
//
// class AcWebviewCef extends StatefulWidget {
//   final String url;
//   final Color? backgroundColor;
//   final bool? allowDebugging;
//   final bool? keepCache;
//
//   final AcLogger logger = AcLogger();
//   late final AcWebviewActionManager actionManager;
//
//   AcWebviewCef({
//     required this.url,
//     this.backgroundColor,
//     this.allowDebugging = false,
//     this.keepCache = true,
//     AcWebviewActionManager? actionManager,
//     super.key,
//   }) : actionManager = actionManager ?? AcWebviewActionManager();
//
//   String onAction({required String name, required Function callback}) {
//     return actionManager.on(action: name, callback: callback);
//   }
//
//   void emitEvent({required String name, dynamic? data}) {
//     sendDataToWebview({'event': 'appContextChange', 'data': data});
//   }
//
//   Future<void> loadUrl(String url) async {
//     await _AcWebviewCefState._instances[this]?.loadUrl(url);
//   }
//
//   void sendDataToWebview(dynamic data) {
//     _AcWebviewCefState._instances[this]?.sendDataToWebview(data);
//   }
//
//   Future<bool> handleBack() async {
//     return await _AcWebviewCefState._instances[this]?.goBack() ?? true;
//   }
//
//   @override
//   State<AcWebviewCef> createState() => _AcWebviewCefState();
// }
//
// class _AcWebviewCefState extends State<AcWebviewCef> {
//   static final Map<AcWebviewCef, _AcWebviewCefState> _instances = {};
//
//   AcCefController? controller;
//   bool _initialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _instances[widget] = this;
//     _initCef();
//   }
//
//   Future<void> _initCef() async {
//     // Ensure CEF is initialized. Multiple calls are usually fine or handled by ac_cef.
//     await AcCef.init();
//     if (mounted) {
//       setState(() {
//         _initialized = true;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _instances.remove(widget);
//     super.dispose();
//   }
//
//   log(dynamic message) {
//     // widget.logger.log(message);
//   }
//
//   Future<bool> goBack() async {
//     if (controller != null) {
//       // Assuming AcCefController has a way to check canGoBack or we just try it
//       // Based on ac_cef_controller.dart, it has goBack() but not canGoBack explicitly returned?
//       // Wait, onLoadingStateChanged provides canGoBack.
//       // For now, let's just call goBack if we want to handle it.
//       await controller!.goBack();
//       return false;
//     }
//     return true;
//   }
//
//   Future<void> loadUrl(String webUrl) async {
//     if (controller != null) {
//       await controller!.loadUrl(webUrl);
//     }
//   }
//
//   Future<void> messageFromWebview(String channel, String message) async {
//     log("Received message from webview on channel: $channel");
//     try {
//       final Map<String, dynamic> data = jsonDecode(message).cast<String, dynamic>();
//       AcWebviewChannelAction channelAction = await widget.actionManager.performAction(actionJson: data);
//
//       if (channelAction.callbackId != null &&
//           channelAction.callbackId!.isNotEmpty && channelAction.response != null) {
//         log("Channel action has valid callback id");
//         Map<String, dynamic> response = {
//           "callbackId": channelAction.callbackId,
//           "actionResponse": AcJsonUtils.getJsonDataFromInstance(instance: channelAction.response)
//         };
//         sendDataToWebview(response);
//       }
//     } catch (e) {
//       log("Error parsing message from webview: $e");
//     }
//   }
//
//   void sendDataToWebview(dynamic data) {
//     if (controller != null) {
//       final String jsonStr = jsonEncode(data);
//       // We use the same channel name as InAppWebView compatibility or a specific one.
//       // AcCefController.addJavascriptChannel('acWebviewJavascriptChannel') was used in my thought
//       // but let's see how it's implemented in AcCefController.
//       final String evalCode = "if(window.acWebviewChannel) { acWebviewChannel.receive({data:$jsonStr}); }";
//       controller?.executeJavaScript(evalCode);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_initialized) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return AcCefWidget(
//       initialUrl: widget.url,
//       onControllerCreated: (ctrl) {
//         controller = ctrl;
//         // InAppWebView uses 'acWebviewJavascriptChannel' in its bridge.
//         // Let's use the same for consistency if possible, or adapt the bridge.
//         controller!.addJavascriptChannel('acWebviewJavascriptChannelNative');
//
//         controller!.onMessage = (channel, message) {
//           if (channel == 'acWebviewJavascriptChannelNative') {
//             messageFromWebview(channel, message);
//           }
//         };
//
//         controller!.onLoadingStateChanged = (isLoading, canGoBack, canGoForward) {
//           if (!isLoading) {
//              // Inject compatibility bridge
//              controller!.executeJavaScript('''
//               (function() {
//                 if (window.acWebviewJavascriptChannel) return;
//                 window.acWebviewJavascriptChannel = {
//                   postMessage: function(message) {
//                     let msg = message;
//                     if (typeof message !== 'string') {
//                       try { msg = JSON.stringify(message); } catch(e) {}
//                     }
//                     // This calls the native channel registered via addJavascriptChannel
//                     if (window.acWebviewJavascriptChannelNative) {
//                       window.acWebviewJavascriptChannelNative.postMessage(msg);
//                     }
//                   }
//                 };
//                 window.dispatchEvent(new Event('acWebviewChannelReady'));
//               })();
//             ''');
//           }
//         };
//       },
//     );
//   }
// }
