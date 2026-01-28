import 'dart:convert';
import 'dart:io';

import 'package:ac_webview/src/models/ac_webview_action_manager.dart';
import 'package:ac_webview/src/models/ac_webview_channel_action.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AcWebview extends StatefulWidget {
  final String url;
  final Color? backgroundColor;

  final AcLogger logger = AcLogger();
  final AcWebviewActionManager actionManager = AcWebviewActionManager();

  AcWebview({required this.url, this.backgroundColor, super.key});

  String onAction({required String name, required Function callback}) {
    return actionManager.on(action: name, callback: callback);
  }

  void emitEvent({required String name, dynamic? data}) {
    sendDataToWebview({'event': 'appContextChange', 'data': data});
  }

  Future<void> loadUrl(String url) async {
    await _AcWebviewState.instance?.loadUrl(url);
  }

  void sendDataToWebview(dynamic data) {
    final String evalCode = "acWebviewChannel.receive({data:${jsonEncode(data)}});";
    _AcWebviewState.instance?.runJavascript(evalCode);
  }

  Future<bool> handleBack() async {
    return await _AcWebviewState.instance?.goBack() ?? true;
  }

  @override
  State<AcWebview> createState() => _AcWebviewState();
}

class _AcWebviewState extends State<AcWebview> {
  static _AcWebviewState? instance;

  InAppWebViewController? controller;

  String url = "";

  @override
  void initState() {
    super.initState();
    instance = this;
    url = widget.url;
  }

  @override
  void dispose() {
    instance = null;
    super.dispose();
  }

  log(dynamic message) {
    // widget.logger.log(message);
  }

  Future<bool> goBack() async {
    if (controller != null) {
      final bool canGoBack = await controller!.canGoBack();
      log("Handling Back: $canGoBack");
      if (canGoBack) {
        await controller!.goBack();
        return false;
      }
    }

    // Fall back to exiting the app
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    }
    log("Handling Popup: true");
    return true;
  }

  Future<void> loadUrl(String webUrl) async {
    log("Loading Url: $webUrl");
    url = webUrl;
    if (controller != null) {
      await controller!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
    }
  }

  Future<void> messageFromWebview(Map<String, dynamic> data) async {
    log("Received message from webview");
    log(data);
    AcWebviewChannelAction channelAction = await widget.actionManager.performAction(actionJson: data);

    if (channelAction.callbackId != null &&
        channelAction.callbackId!.isNotEmpty && channelAction.response != null) {
      log("Channel action has valid callback id");
      Map<String, dynamic> response = {
        "callbackId": channelAction.callbackId,
        "actionResponse": AcJsonUtils.getJsonDataFromInstance(instance: channelAction.response)
      };
      widget.sendDataToWebview(response);
    } else {
      log("Channel action does not have valid callback id");
    }
  }

  void runJavascript(String script) {
    log("Executing script: $script");
    controller?.evaluateJavascript(source: script);
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),

      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: true,
        disableContextMenu: true,

      ),
        onConsoleMessage: (controller, consoleMessage) {
          // DO NOTHING → disables console output
          return;
        },
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        // Inject the compatibility wrapper
        await ctrl.evaluateJavascript(source: '''
    (function() {
      if (window.acWebviewJavascriptChannel) return; // avoid duplicate

      window.acWebviewJavascriptChannel = {
        postMessage: function(message) {
          let msg = message;
          if (typeof message !== 'string') {
            try { msg = JSON.stringify(message); } catch(e) {}
          }
          window.flutter_inappwebview.callHandler('acWebviewJavascriptChannel', msg);
        }
      };

      // Optional: trigger a ready event if your web code waits for it
      // const event = new Event('acWebviewChannelReady');
      // window.dispatchEvent(event);
    })();
  ''');
      },
      onLoadStart: (controller, url) {
        // Optional: handle load events if needed
      },
      onWebViewCreated: (InAppWebViewController ctrl) {
        controller = ctrl;
        ctrl.addJavaScriptHandler(
          handlerName: "acWebviewJavascriptChannel",
          callback: (List<dynamic> arguments) {
            print(arguments);
            final message = arguments.first;

            final Map<String, dynamic> data =
            jsonDecode(message).cast<String, dynamic>();
            messageFromWebview(data);
          },
        );
      },
    );
  }
}