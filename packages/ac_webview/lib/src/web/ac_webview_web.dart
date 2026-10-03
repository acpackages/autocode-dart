import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:autocode/autocode.dart';
import '../models/ac_webview_action_manager.dart';
import '../models/ac_webview_channel_action.dart';

class CefNativeClient {}

/// Base Web implementation of WebView using Flutter InAppWebView (renders as iframe on Web).
class AcWebview extends StatefulWidget {
  final String url;
  final Color? backgroundColor;
  final bool? allowDebugging;
  final bool? keepCache;
  final bool useCef;
  final CefNativeClient? nativeClient;
  final AcWebviewActionManager actionManager;

  AcWebview({
    required this.url,
    this.backgroundColor,
    this.allowDebugging = false,
    this.keepCache = true,
    this.useCef = false,
    this.nativeClient,
    AcWebviewActionManager? actionManager,
    super.key,
  }) : actionManager = actionManager ?? AcWebviewActionManager();

  String onAction({required String name, required Function callback}) {
    return actionManager.on(action: name, callback: callback);
  }

  void emitEvent({required String name, dynamic data}) {
    sendDataToWebview({'event': 'appContextChange', 'data': data});
  }

  _AcWebviewWebState? get _state => _AcWebviewWebState._instances[this];

  Future<void> loadUrl(String url) async {
    await _state?.loadUrl(url);
  }

  Future<void> reload() async {
    await _state?.reload();
  }

  void sendDataToWebview(dynamic data) {
    _state?.sendDataToWebview(data);
  }

  void runJavascript(String javascript) {
    _state?.runJavascript(javascript);
  }

  Future<bool> handleBack() async {
    return await _state?.handleBack() ?? true;
  }

  @override
  State<AcWebview> createState() => _AcWebviewWebState();
}

class _AcWebviewWebState extends State<AcWebview> {
  static final Map<AcWebview, _AcWebviewWebState> _instances = {};
  InAppWebViewController? controller;
  late String currentUrl;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    currentUrl = widget.url;
  }

  @override
  void dispose() {
    _instances.remove(widget);
    super.dispose();
  }

  Future<bool> handleBack() async {
    if (controller != null) {
      final bool canGoBack = await controller!.canGoBack();
      if (canGoBack) {
        await controller!.goBack();
        return false;
      }
    }
    return true;
  }

  Future<void> loadUrl(String webUrl) async {
    currentUrl = webUrl;
    if (controller != null) {
      await controller!.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));
    }
  }

  Future<void> reload() async {
    if (controller != null) {
      await controller!.reload();
    }
  }

  void runJavascript(String script) {
    controller?.evaluateJavascript(source: script);
  }

  void sendDataToWebview(dynamic data) {
    final String jsonStr = jsonEncode(data);
    final String evalCode = '''
(function() {
  const payload = $jsonStr;
  if (window.acWebviewChannel && window.acWebviewChannel.receive) {
    window.acWebviewChannel.receive({data: payload});
  }
  window.dispatchEvent(new CustomEvent('acWebviewMessage', { detail: payload }));
})();
''';
    controller?.evaluateJavascript(source: evalCode);
  }

  Future<void> _handleIncomingMessage(dynamic rawMessage) async {
    try {
      Map<String, dynamic> data;
      if (rawMessage is Map) {
        data = rawMessage.cast<String, dynamic>();
      } else if (rawMessage is String) {
        data = jsonDecode(rawMessage).cast<String, dynamic>();
      } else {
        return;
      }

      AcWebviewChannelAction channelAction =
          await widget.actionManager.performAction(actionJson: data);

      if (channelAction.callbackId != null &&
          channelAction.callbackId!.isNotEmpty &&
          channelAction.response != null) {
        Map<String, dynamic> response = {
          "callbackId": channelAction.callbackId,
          "actionResponse": AcJsonUtils.getJsonDataFromInstance(
              instance: channelAction.response)
        };
        sendDataToWebview(response);
      }
    } catch (e) {
      debugPrint('[AcWebview Web] Error processing incoming message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: true,
        disableContextMenu: true,
      ),
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        // Inject JS bridge supporting acWebviewJavascriptChannel and window.chrome.webview emulation
        await ctrl.evaluateJavascript(source: '''
(function() {
  if (window.acWebviewJavascriptChannel && window.chrome && window.chrome.webview) return;

  function dispatchToFlutter(message) {
    let msg = message;
    if (typeof message !== 'string') {
      try { msg = JSON.stringify(message); } catch(e) {}
    }
    window.flutter_inappwebview.callHandler('acWebviewJavascriptChannel', msg);
  }

  window.acWebviewJavascriptChannel = {
    postMessage: dispatchToFlutter
  };

  if (!window.chrome) window.chrome = {};
  if (!window.chrome.webview) {
    window.chrome.webview = {
      postMessage: dispatchToFlutter,
      addEventListener: function(type, listener) {
        window.addEventListener('acWebviewMessage', function(e) {
          listener({ data: e.detail });
        });
      }
    };
  }

  window.dispatchEvent(new Event('acWebviewChannelReady'));
})();
''');
      },
      onWebViewCreated: (InAppWebViewController ctrl) {
        controller = ctrl;
        ctrl.addJavaScriptHandler(
          handlerName: "acWebviewJavascriptChannel",
          callback: (List<dynamic> arguments) {
            if (arguments.isNotEmpty) {
              _handleIncomingMessage(arguments.first);
            }
          },
        );
      },
    );
  }
}

/// Web-compatible alias for [AcWebviewWinFloating] using [InAppWebView].
class AcWebviewWinFloating extends StatefulWidget {
  final String url;
  final Color? backgroundColor;
  final bool? allowDebugging;
  final bool? keepCache;
  final AcWebviewActionManager actionManager;

  AcWebviewWinFloating({
    required this.url,
    this.backgroundColor,
    this.allowDebugging = false,
    this.keepCache = true,
    AcWebviewActionManager? actionManager,
    super.key,
  }) : actionManager = actionManager ?? AcWebviewActionManager();

  String onAction({required String name, required Function callback}) {
    return actionManager.on(action: name, callback: callback);
  }

  void emitEvent({required String name, dynamic data}) {
    sendDataToWebview({'event': 'appContextChange', 'data': data});
  }

  _AcWebviewWinFloatingWebState? get _state =>
      _AcWebviewWinFloatingWebState._instances[this];

  Future<void> loadUrl(String newUrl) async {
    await _state?.loadUrl(newUrl);
  }

  Future<void> reload() async {
    await _state?.reload();
  }

  Future<bool> handleBack() async {
    return await _state?.handleBack() ?? true;
  }

  void runJavascript(String javascript) {
    _state?.runJavascript(javascript);
  }

  void sendDataToWebview(Map<String, dynamic> data) {
    _state?.sendDataToWebview(data);
  }

  @override
  State<AcWebviewWinFloating> createState() => _AcWebviewWinFloatingWebState();
}

class _AcWebviewWinFloatingWebState extends State<AcWebviewWinFloating> {
  static final Map<AcWebviewWinFloating, _AcWebviewWinFloatingWebState>
      _instances = {};
  InAppWebViewController? controller;
  late String currentUrl;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    currentUrl = widget.url;
  }

  @override
  void dispose() {
    _instances.remove(widget);
    super.dispose();
  }

  Future<bool> handleBack() async {
    if (controller != null) {
      final bool canGoBack = await controller!.canGoBack();
      if (canGoBack) {
        await controller!.goBack();
        return false;
      }
    }
    return true;
  }

  Future<void> loadUrl(String webUrl) async {
    currentUrl = webUrl;
    if (controller != null) {
      await controller!.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));
    }
  }

  Future<void> reload() async {
    if (controller != null) {
      await controller!.reload();
    }
  }

  void runJavascript(String script) {
    controller?.evaluateJavascript(source: script);
  }

  void sendDataToWebview(Map<String, dynamic> data) {
    final String jsonStr = jsonEncode(data);
    final String evalCode = '''
(function() {
  const payload = $jsonStr;
  if (window.acWebviewChannel && window.acWebviewChannel.receive) {
    window.acWebviewChannel.receive({data: payload});
  }
  window.dispatchEvent(new CustomEvent('acWebviewMessage', { detail: payload }));
})();
''';
    controller?.evaluateJavascript(source: evalCode);
  }

  Future<void> _handleIncomingMessage(dynamic rawMessage) async {
    try {
      Map<String, dynamic> data;
      if (rawMessage is Map) {
        data = rawMessage.cast<String, dynamic>();
      } else if (rawMessage is String) {
        data = jsonDecode(rawMessage).cast<String, dynamic>();
      } else {
        return;
      }

      AcWebviewChannelAction channelAction =
          await widget.actionManager.performAction(actionJson: data);

      if (channelAction.callbackId != null &&
          channelAction.callbackId!.isNotEmpty &&
          channelAction.response != null) {
        Map<String, dynamic> response = {
          "callbackId": channelAction.callbackId,
          "actionResponse": AcJsonUtils.getJsonDataFromInstance(
              instance: channelAction.response)
        };
        sendDataToWebview(response);
      }
    } catch (e) {
      debugPrint('[AcWebviewWinFloating Web] Error processing message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: true,
        disableContextMenu: true,
      ),
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        await ctrl.evaluateJavascript(source: '''
(function() {
  if (window.acWebviewJavascriptChannel && window.chrome && window.chrome.webview) return;

  function dispatchToFlutter(message) {
    let msg = message;
    if (typeof message !== 'string') {
      try { msg = JSON.stringify(message); } catch(e) {}
    }
    window.flutter_inappwebview.callHandler('acWebviewJavascriptChannel', msg);
  }

  window.acWebviewJavascriptChannel = {
    postMessage: dispatchToFlutter
  };

  if (!window.chrome) window.chrome = {};
  if (!window.chrome.webview) {
    window.chrome.webview = {
      postMessage: dispatchToFlutter,
      addEventListener: function(type, listener) {
        window.addEventListener('acWebviewMessage', function(e) {
          listener({ data: e.detail });
        });
      }
    };
  }

  window.dispatchEvent(new Event('acWebviewChannelReady'));
})();
''');
      },
      onWebViewCreated: (InAppWebViewController ctrl) {
        controller = ctrl;
        ctrl.addJavaScriptHandler(
          handlerName: "acWebviewJavascriptChannel",
          callback: (List<dynamic> arguments) {
            if (arguments.isNotEmpty) {
              _handleIncomingMessage(arguments.first);
            }
          },
        );
      },
    );
  }
}

/// Web-compatible alias for [AcWebviewCef] using [InAppWebView].
class AcWebviewCef extends StatefulWidget {
  final String url;
  final Color? backgroundColor;
  final bool? allowDebugging;
  final bool? keepCache;
  final CefNativeClient? nativeClient;
  final AcWebviewActionManager actionManager;

  AcWebviewCef({
    required this.url,
    this.backgroundColor,
    this.allowDebugging = false,
    this.keepCache = true,
    this.nativeClient,
    AcWebviewActionManager? actionManager,
    super.key,
  }) : actionManager = actionManager ?? AcWebviewActionManager();

  String onAction({required String name, required Function callback}) {
    return actionManager.on(action: name, callback: callback);
  }

  void emitEvent({required String name, dynamic data}) {
    sendDataToWebview({'event': 'appContextChange', 'data': data});
  }

  _AcWebviewCefWebState? get _state => _AcWebviewCefWebState._instances[this];

  Future<void> loadUrl(String newUrl) async {
    await _state?.loadUrl(newUrl);
  }

  Future<void> reload() async {
    await _state?.reload();
  }

  Future<bool> handleBack() async {
    return await _state?.handleBack() ?? true;
  }

  void runJavascript(String javascript) {
    _state?.runJavascript(javascript);
  }

  void sendDataToWebview(dynamic data) {
    _state?.sendDataToWebview(data);
  }

  @override
  State<AcWebviewCef> createState() => _AcWebviewCefWebState();
}

class _AcWebviewCefWebState extends State<AcWebviewCef> {
  static final Map<AcWebviewCef, _AcWebviewCefWebState> _instances = {};
  InAppWebViewController? controller;
  late String currentUrl;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    currentUrl = widget.url;
  }

  @override
  void dispose() {
    _instances.remove(widget);
    super.dispose();
  }

  Future<bool> handleBack() async {
    if (controller != null) {
      final bool canGoBack = await controller!.canGoBack();
      if (canGoBack) {
        await controller!.goBack();
        return false;
      }
    }
    return true;
  }

  Future<void> loadUrl(String webUrl) async {
    currentUrl = webUrl;
    if (controller != null) {
      await controller!.loadUrl(urlRequest: URLRequest(url: WebUri(currentUrl)));
    }
  }

  Future<void> reload() async {
    if (controller != null) {
      await controller!.reload();
    }
  }

  void runJavascript(String script) {
    controller?.evaluateJavascript(source: script);
  }

  void sendDataToWebview(dynamic data) {
    final String jsonStr = jsonEncode(data);
    final String evalCode = '''
(function() {
  const payload = $jsonStr;
  if (window.acWebviewChannel && window.acWebviewChannel.receive) {
    window.acWebviewChannel.receive({data: payload});
  }
  window.dispatchEvent(new CustomEvent('acWebviewMessage', { detail: payload }));
})();
''';
    controller?.evaluateJavascript(source: evalCode);
  }

  Future<void> _handleIncomingMessage(dynamic rawMessage) async {
    try {
      Map<String, dynamic> data;
      if (rawMessage is Map) {
        data = rawMessage.cast<String, dynamic>();
      } else if (rawMessage is String) {
        data = jsonDecode(rawMessage).cast<String, dynamic>();
      } else {
        return;
      }

      AcWebviewChannelAction channelAction =
          await widget.actionManager.performAction(actionJson: data);

      if (channelAction.callbackId != null &&
          channelAction.callbackId!.isNotEmpty &&
          channelAction.response != null) {
        Map<String, dynamic> response = {
          "callbackId": channelAction.callbackId,
          "actionResponse": AcJsonUtils.getJsonDataFromInstance(
              instance: channelAction.response)
        };
        sendDataToWebview(response);
      }
    } catch (e) {
      debugPrint('[AcWebviewCef Web] Error processing message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        isInspectable: true,
        disableContextMenu: true,
      ),
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        await ctrl.evaluateJavascript(source: '''
(function() {
  if (window.acWebviewJavascriptChannel && window.chrome && window.chrome.webview) return;

  function dispatchToFlutter(message) {
    let msg = message;
    if (typeof message !== 'string') {
      try { msg = JSON.stringify(message); } catch(e) {}
    }
    window.flutter_inappwebview.callHandler('acWebviewJavascriptChannel', msg);
  }

  window.acWebviewJavascriptChannel = {
    postMessage: dispatchToFlutter
  };

  if (!window.chrome) window.chrome = {};
  if (!window.chrome.webview) {
    window.chrome.webview = {
      postMessage: dispatchToFlutter,
      addEventListener: function(type, listener) {
        window.addEventListener('acWebviewMessage', function(e) {
          listener({ data: e.detail });
        });
      }
    };
  }

  window.dispatchEvent(new Event('acWebviewChannelReady'));
})();
''');
      },
      onWebViewCreated: (InAppWebViewController ctrl) {
        controller = ctrl;
        ctrl.addJavaScriptHandler(
          handlerName: "acWebviewJavascriptChannel",
          callback: (List<dynamic> arguments) {
            if (arguments.isNotEmpty) {
              _handleIncomingMessage(arguments.first);
            }
          },
        );
      },
    );
  }
}
