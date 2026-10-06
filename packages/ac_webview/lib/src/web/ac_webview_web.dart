import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:autocode/autocode.dart';
import '../models/ac_webview_action_manager.dart';
import '../models/ac_webview_channel_action.dart';

/// Stub for CefNativeClient on web — accepted but unused.
class CefNativeClient {}

// ---------------------------------------------------------------------------
// Bridge JavaScript
// ---------------------------------------------------------------------------

/// Bridge JavaScript for cross-origin iframe communication.
///
/// For **same-origin** content this is auto-injected on page load.
/// For **cross-origin** content the web page must include this script:
/// ```html
/// <script src="ac_webview_bridge.js"></script>
/// ```
const String acWebviewBridgeScript = r'''
(function() {
  if (window._acWebviewBridgeReady) return;
  window._acWebviewBridgeReady = true;

  var isInIframe = (window !== window.parent);

  function dispatchToFlutter(message) {
    var msg = message;
    if (typeof message !== 'string') {
      try { msg = JSON.stringify(message); } catch(e) {}
    }

    // Try InAppWebView handler first (same-origin only)
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('acWebviewJavascriptChannel', msg);
        return;
      }
    } catch(e) {}

    // Fallback: postMessage to parent (cross-origin safe)
    if (isInIframe) {
      try {
        window.parent.postMessage(JSON.stringify({
          type: 'acWebviewMessage',
          payload: msg
        }), '*');
      } catch(e) {}
    }
  }

  // Unified channel for JS -> Flutter
  window.acWebviewJavascriptChannel = {
    postMessage: dispatchToFlutter
  };

  // Chrome WebView2 compatibility shim
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

  // Listen for postMessage from Flutter parent (cross-origin safe)
  window.addEventListener('message', function(event) {
    try {
      var parsed = (typeof event.data === 'string') ? JSON.parse(event.data) : event.data;
      if (parsed && parsed.type === 'acWebviewFlutterMessage' && parsed.payload !== undefined) {
        var payload = parsed.payload;
        if (typeof payload === 'string') {
          try { payload = JSON.parse(payload); } catch(e) {}
        }
        if (window.acWebviewChannel && typeof window.acWebviewChannel.receive === 'function') {
          window.acWebviewChannel.receive({ data: payload });
        }
        window.dispatchEvent(new CustomEvent('acWebviewMessage', { detail: payload }));
      }
    } catch(e) {}
  });

  window.dispatchEvent(new Event('acWebviewChannelReady'));
})();
''';

// ---------------------------------------------------------------------------
// PostMessage Bridge Helper
// ---------------------------------------------------------------------------

/// Cross-origin safe communication bridge using [window.postMessage].
///
/// On web, [InAppWebView] renders content in an iframe. For cross-origin URLs
/// [evaluateJavascript] cannot access the iframe content due to the browser
/// Same-Origin Policy. This bridge uses the standard postMessage API which
/// works regardless of origin.
class _WebPostMessageBridge {
  final void Function(Map<String, dynamic> data) onMessage;
  StreamSubscription<html.MessageEvent>? _subscription;

  _WebPostMessageBridge({required this.onMessage});

  void start() {
    _subscription = html.window.onMessage.listen(_onWindowMessage);
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onWindowMessage(html.MessageEvent event) {
    try {
      final rawData = event.data;
      if (rawData == null) return;

      Map<String, dynamic>? envelope;
      if (rawData is String) {
        final decoded = jsonDecode(rawData);
        if (decoded is Map<String, dynamic>) envelope = decoded;
      } else if (rawData is Map) {
        envelope = Map<String, dynamic>.from(rawData);
      }

      if (envelope == null || envelope['type'] != 'acWebviewMessage') return;

      final payload = envelope['payload'];
      Map<String, dynamic>? messageData;
      if (payload is Map) {
        messageData = Map<String, dynamic>.from(payload);
      } else if (payload is String) {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) messageData = decoded;
      }

      if (messageData != null) {
        onMessage(messageData);
      }
    } catch (e) {
      debugPrint('[AcWebview PostMessage] Error handling message: $e');
    }
  }

  /// Send data to all iframes in the document via postMessage.
  void sendToIframes(dynamic data) {
    try {
      final envelope = jsonEncode({
        'type': 'acWebviewFlutterMessage',
        'payload': data,
      });

      for (final iframe in _findAllIframes()) {
        try {
          iframe.contentWindow?.postMessage(envelope, '*');
        } catch (_) {
          // Skip iframes whose contentWindow is inaccessible
        }
      }
    } catch (e) {
      debugPrint('[AcWebview PostMessage] Error sending to iframes: $e');
    }
  }

  /// Find iframes in DOM, including inside Flutter platform view shadow DOMs.
  List<html.IFrameElement> _findAllIframes() {
    final iframes = <html.IFrameElement>[];

    // Direct DOM query
    html.document.querySelectorAll('iframe').forEach((e) {
      if (e is html.IFrameElement) iframes.add(e);
    });

    // Inside Flutter platform view shadow DOMs (CanvasKit rendering mode)
    html.document.querySelectorAll('flt-platform-view').forEach((pv) {
      final shadow = pv.shadowRoot;
      if (shadow != null) {
        shadow.querySelectorAll('iframe').forEach((e) {
          if (e is html.IFrameElement) iframes.add(e);
        });
      }
    });

    return iframes;
  }
}

// ---------------------------------------------------------------------------
// AcWebview (Web)
// ---------------------------------------------------------------------------

/// Web implementation of WebView using InAppWebView (iframe) + postMessage.
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
  late _WebPostMessageBridge _bridge;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    currentUrl = widget.url;
    _bridge = _WebPostMessageBridge(onMessage: _handleIncomingMessage);
    _bridge.start();
  }

  @override
  void dispose() {
    _instances.remove(widget);
    _bridge.stop();
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

  /// Run arbitrary JavaScript in the webview.
  /// NOTE: Only works for same-origin content. Cross-origin iframes block
  /// evaluateJavascript due to the browser Same-Origin Policy.
  void runJavascript(String script) {
    controller?.evaluateJavascript(source: script);
  }

  /// Send data to the webview content via postMessage (cross-origin safe).
  void sendDataToWebview(dynamic data) {
    _bridge.sendToIframes(data);
  }

  Future<void> _handleIncomingMessage(dynamic rawMessage) async {
    try {
      Map<String, dynamic> data;
      if (rawMessage is Map) {
        data = Map<String, dynamic>.from(rawMessage);
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
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('WebView Console: ${consoleMessage.message}');
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView Error: ${error.description} (URL: ${request.url})');
      },
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        // Inject bridge JS for same-origin content.
        // For cross-origin content this silently fails — the web page must
        // include acWebviewBridgeScript (or ac_webview_bridge.js) manually.
        try {
          await ctrl.evaluateJavascript(source: acWebviewBridgeScript);
        } catch (_) {}
      },
      onWebViewCreated: (InAppWebViewController ctrl) {
        controller = ctrl;
        // InAppWebView JS handler — same-origin communication fast path.
        // For cross-origin the postMessage bridge handles it instead.
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

// ---------------------------------------------------------------------------
// AcWebviewWinFloating (Web Alias)
// ---------------------------------------------------------------------------

/// Web-compatible alias for [AcWebviewWinFloating] using InAppWebView + postMessage.
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
  late _WebPostMessageBridge _bridge;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    currentUrl = widget.url;
    _bridge = _WebPostMessageBridge(onMessage: _handleIncomingMessage);
    _bridge.start();
  }

  @override
  void dispose() {
    _instances.remove(widget);
    _bridge.stop();
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
    _bridge.sendToIframes(data);
  }

  Future<void> _handleIncomingMessage(dynamic rawMessage) async {
    try {
      Map<String, dynamic> data;
      if (rawMessage is Map) {
        data = Map<String, dynamic>.from(rawMessage);
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
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('WebView Console: ${consoleMessage.message}');
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView Error: ${error.description} (URL: ${request.url})');
      },
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        try {
          await ctrl.evaluateJavascript(source: acWebviewBridgeScript);
        } catch (_) {}
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

// ---------------------------------------------------------------------------
// AcWebviewCef (Web Alias)
// ---------------------------------------------------------------------------

/// Web-compatible alias for [AcWebviewCef] using InAppWebView + postMessage.
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
  late _WebPostMessageBridge _bridge;

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    currentUrl = widget.url;
    _bridge = _WebPostMessageBridge(onMessage: _handleIncomingMessage);
    _bridge.start();
  }

  @override
  void dispose() {
    _instances.remove(widget);
    _bridge.stop();
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
    _bridge.sendToIframes(data);
  }

  Future<void> _handleIncomingMessage(dynamic rawMessage) async {
    try {
      Map<String, dynamic> data;
      if (rawMessage is Map) {
        data = Map<String, dynamic>.from(rawMessage);
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
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('WebView Console: ${consoleMessage.message}');
      },
      onReceivedError: (controller, request, error) {
        debugPrint('WebView Error: ${error.description} (URL: ${request.url})');
      },
      onLoadStop: (InAppWebViewController ctrl, WebUri? url) async {
        try {
          await ctrl.evaluateJavascript(source: acWebviewBridgeScript);
        } catch (_) {}
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
