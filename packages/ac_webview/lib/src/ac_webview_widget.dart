import 'dart:convert';
import 'dart:io';

import 'package:ac_webview/src/models/ac_webview_action_manager.dart';
import 'package:ac_webview/src/models/ac_webview_channel_action.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_win_floating/webview_win_floating.dart';

class AcWebview extends StatefulWidget {
  final String url;
  final Color? backgroundColor;
  final bool? allowDebugging;
  final bool? keepCache;

  final AcLogger logger = AcLogger();
  final AcWebviewActionManager actionManager = AcWebviewActionManager();

  AcWebview({required this.url, this.backgroundColor,this.allowDebugging = false,this.keepCache = true, super.key});

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

  runJavascript(String javascript) async {
    _AcWebviewState.instance?.runJavascript(javascript);
  }

  Future<bool> handleBack() async {
    return await _AcWebviewState.instance?.goBack() ?? true;
  }

  @override
  State<AcWebview> createState() => Platform.isWindows?_AcWebviewWinFloatingState():_AcWebviewState();
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
          debugPrint('WebView Console: ${consoleMessage.message}');
          return;
        },
        onReceivedError: (controller, request, error) {
          debugPrint('WebView Error: ${error.description} (URL: ${request.url})');
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          debugPrint('WebView HTTP Error: ${errorResponse.statusCode} (URL: ${request.url})');
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
      window.dispatchEvent(new Event('acWebviewChannelReady'));
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

class _AcWebviewWinFloatingState extends _AcWebviewState {
  static final Map<AcWebview , _AcWebviewState> _instances = {};

  late final WebViewController _controller;
  late WebViewWidget webview;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    _initialize();
  }

  @override
  void dispose() {
    _instances.remove(widget);
    super.dispose();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    if (Platform.isWindows) {
      final params = WindowsWebViewControllerCreationParams();
      _controller = WebViewController.fromPlatformCreationParams(params);
    } else {
      _controller = WebViewController();
    }
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (!Platform.isMacOS) {
      _controller.setBackgroundColor(widget.backgroundColor ?? Colors.white);
    }

    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {
          await _injectBridge();
        },
        onWebResourceError: (error) {
          debugPrint('Web resource error: ${error.description}');
        },
      ),
    );
    if(widget.keepCache!=true){
      _controller.clearCache();
    }
    // Add JavaScript channel for communication from web → Flutter
    _controller.addJavaScriptChannel(
      'acWinFloatingWebviewChannel',
      onMessageReceived: (JavaScriptMessage message) {
        _handleMessageFromWeb(message.message);
      },
    );

    // Enable debugging (inspectable) if allowed
    if (widget.allowDebugging == true) {
      if (Platform.isAndroid) {
        // WebViewController.(true);
      }
      // On Windows/Linux (WebView2) debugging is usually enabled via WebView2 dev tools
    }
    webview = WebViewWidget(controller: _controller);
    // Load initial URL
    await _controller.loadRequest(Uri.parse(widget.url));

    _isInitialized = true;
    if (mounted) setState(() {});
  }

  Future<void> _injectBridge() async {
    const bridgeJs = '''
    (function() {
      if (window.acWebviewJavascriptChannel) return;

      window.acWebviewJavascriptChannel = {
        postMessage: function(data) {
          let msg = data;
          if (typeof data !== 'string') {
            try {
              msg = JSON.stringify(data);
            } catch (e) {}
          }
          acWinFloatingWebviewChannel.postMessage(msg);
        }
      };

      // Optional: signal ready
      window.dispatchEvent(new Event('acWebviewChannelReady'));
    })();
    ''';

    try {
      await _controller.runJavaScript(bridgeJs);
    } catch (e) {
      debugPrint('Error injecting bridge JS: $e');
    }
  }

  Future<void> _handleMessageFromWeb(String rawMessage) async {
    try {
      final data = jsonDecode(rawMessage) as Map<String, dynamic>;

      final action = await widget.actionManager.performAction(actionJson: data);

      if (action.callbackId != null &&
          action.callbackId!.isNotEmpty &&
          action.response != null) {
        final response = {
          'callbackId': action.callbackId,
          'actionResponse': action.response, // must be JSON-serializable
        };
        _sendToWebView(response);
      }
    } catch (e, st) {
      debugPrint('Error handling message from webview: $e\n$st');
    }
  }

  Future<void> _sendToWebView(Map<String, dynamic> data) async {
    final jsonPayload = jsonEncode(data);
    try {
      await _controller.runJavaScript( "acWebviewChannel.receive({data:${jsonEncode(data)}});");
    } catch (e) {
      debugPrint('Error sending data to webview: $e');
    }
    // You can choose your preferred way — here using window.postMessage style
    // await _controller.runJavaScript('''
    //   if (window.acWebviewChannel && typeof window.acWebviewChannel.onmessage === 'function') {
    //     window.acWebviewChannel.onmessage($jsonPayload);
    //   } else {
    //     console.warn("acWebviewChannel.onmessage not available yet");
    //   }
    // ''');
  }

  Future<void> _loadUrl(String newUrl) async {
    await _controller.loadRequest(Uri.parse(newUrl));
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }

    // Optional: exit app on Android if no history
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    }

    return true;
  }

  runJavascript(String javascript) async {
    try {
      await _controller.runJavaScript(javascript);
    } catch (e) {
      debugPrint('Error running custom javascript: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return webview;
  }
}