import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ac_cef_flutter/ac_cef_flutter.dart';
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
  final bool useCef;
  final CefNativeClient? nativeClient;

  final AcLogger logger = AcLogger();
  final AcWebviewActionManager actionManager = AcWebviewActionManager();

  AcWebview({
    required this.url,
    this.backgroundColor,
    this.allowDebugging = false,
    this.keepCache = true,
    this.useCef = false,
    this.nativeClient,
    super.key,
  });

  String onAction({required String name, required Function callback}) {
    return actionManager.on(action: name, callback: callback);
  }

  void emitEvent({required String name, dynamic data}) {
    sendDataToWebview({'event': 'appContextChange', 'data': data});
  }

  _AcWebviewState? get _state => _AcWebviewState._instances[this] ?? _AcWebviewState.instance;

  Future<void> loadUrl(String url) async {
    await _state?.loadUrl(url);
  }

  Future<void> reload() async {
    await _state?.reload();
  }

  void sendDataToWebview(dynamic data) {
    final String evalCode = "acWebviewChannel.receive({data:${jsonEncode(data)}});";
    _state?.runJavascript(evalCode);
  }

  runJavascript(String javascript) async {
    _state?.runJavascript(javascript);
  }

  Future<bool> handleBack() async {
    return await _state?.goBack() ?? true;
  }

  @override
  State<AcWebview> createState() {
    if (useCef) {
      return _AcWebviewCefState();
    }
    return Platform.isWindows ? _AcWebviewWinFloatingState() : _AcWebviewState();
  }
}

class _AcWebviewState extends State<AcWebview> {
  static _AcWebviewState? instance;
  static final Map<AcWebview, _AcWebviewState> _instances = {};
  InAppWebViewController? controller;

  String url = "";

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    instance = this;
    url = widget.url;
  }

  @override
  void dispose() {
    _instances.remove(widget);
    if (instance == this) {
      instance = null;
    }
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

  Future<void> reload() async {
    if (controller != null) {
      await controller!.reload();
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
  static final Map<AcWebview, _AcWebviewState> _instances = {};

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
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

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
    if (widget.keepCache != true) {
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
          'actionResponse': AcJsonUtils.getJsonDataFromInstance(instance: action.response),
        };
        _sendToWebView(response);
      }
    } catch (e, st) {
      debugPrint('Error handling message from webview: $e\n$st');
    }
  }

  Future<void> _sendToWebView(Map<String, dynamic> data) async {
    try {
      await _controller.runJavaScript("acWebviewChannel.receive({data:${jsonEncode(data)}});");
    } catch (e) {
      debugPrint('Error sending data to webview: $e');
    }
  }

  @override
  Future<void> loadUrl(String webUrl) async {
    url = webUrl;
    await _controller.loadRequest(Uri.parse(webUrl));
  }

  @override
  Future<void> reload() async {
    await _controller.reload();
  }

  @override
  Future<bool> goBack() async {
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

  @override
  void runJavascript(String javascript) async {
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

class _AcWebviewCefState extends _AcWebviewState {
  CefNativeClient? _nativeClient;
  CefController? _controller;
  bool _isInitialized = false;

  static Future<CefNativeClient> _ensureNativeClient() async {
    final client = CefClient();
    client.addRequestHandler(_AcWebviewCefRequestHandler());
    client.addLoadHandler(_AcWebviewCefLoadHandler());
    return await initCef(client: client);
  }

  @override
  void initState() {
    super.initState();
    _AcWebviewState._instances[widget] = this;
    _AcWebviewState.instance = this;
    _initialize();
  }

  @override
  void dispose() {
    _AcWebviewState._instances.remove(widget);
    if (_AcWebviewState.instance == this) {
      _AcWebviewState.instance = null;
    }
    _controller = null;
    super.dispose();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      if (widget.nativeClient != null) {
        _nativeClient = widget.nativeClient;
      } else {
        _nativeClient = await _ensureNativeClient();
      }
      _isInitialized = true;
      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('Error initializing CEF Native Client: $e\n$st');
    }
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
          if (window.cefQuery) {
            window.cefQuery({
              request: msg,
              onSuccess: function(response) {},
              onFailure: function(errCode, errMsg) {}
            });
          }
        }
      };

      // Signal ready
      window.dispatchEvent(new Event('acWebviewChannelReady'));
    })();
    ''';

    try {
      _controller?.executeJavaScript(bridgeJs);
    } catch (e) {
      debugPrint('Error injecting bridge JS into CEF: $e');
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
          'actionResponse': AcJsonUtils.getJsonDataFromInstance(instance: action.response),
        };
        _sendToWebView(response);
      }
    } catch (e, st) {
      debugPrint('Error handling message from webview: $e\n$st');
    }
  }

  Future<void> _sendToWebView(Map<String, dynamic> data) async {
    try {
      _controller?.executeJavaScript(
          "acWebviewChannel.receive({data:${jsonEncode(data)}});");
    } catch (e) {
      debugPrint('Error sending data to CEF webview: $e');
    }
  }

  @override
  Future<void> loadUrl(String webUrl) async {
    url = webUrl;
    try {
      _controller?.loadUrl(webUrl);
    } catch (e) {
      debugPrint('Error loading URL in CEF webview: $e');
    }
  }

  @override
  Future<void> reload() async {
    try {
      _controller?.reload();
    } catch (e) {
      debugPrint('Error reloading CEF webview: $e');
    }
  }

  @override
  Future<bool> goBack() async {
    if (_controller != null && _controller!.canGoBackNow) {
      try {
        _controller!.goBack();
        return false;
      } catch (e) {
        debugPrint('Error navigating back in CEF webview: $e');
      }
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    }
    return true;
  }

  @override
  void runJavascript(String javascript) async {
    try {
      _controller?.executeJavaScript(javascript);
    } catch (e) {
      debugPrint('Error running custom javascript in CEF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _nativeClient == null) {
      return widget.backgroundColor != null
          ? Container(
              color: widget.backgroundColor,
              child: const Center(child: CircularProgressIndicator()),
            )
          : const Center(child: CircularProgressIndicator());
    }

    return CefView(
      native: _nativeClient!,
      initialUrl: widget.url,
      backgroundColor: widget.backgroundColor ?? Colors.white,
      onCreated: (controller) {
        _controller = controller;
        _nativeClient!.registerMessageRouter(controller.browserId);
        controller.registerQueryHandler(
          _AcWebviewCefQueryRouterHandler(_handleMessageFromWeb),
        );
        controller.onLoadingStateChanged = (isLoading, canGoBack, canGoForward) {
          if (!isLoading) {
            _injectBridge();
          }
        };
        if (widget.allowDebugging == true) {
          controller.openDevTools();
        }
      },
    );
  }
}

class _AcWebviewCefQueryRouterHandler implements CefMessageRouterHandler {
  final Future<void> Function(String) onMessage;
  _AcWebviewCefQueryRouterHandler(this.onMessage);

  @override
  bool onQuery(
    CefBrowser browser,
    int queryId,
    String request,
    bool persistent,
    CefQueryCallback callback,
  ) {
    onMessage(request);
    callback.success('');
    return true;
  }

  @override
  void onQueryCanceled(CefBrowser browser, int queryId) {}
}

class _AcWebviewCefRequestHandler extends CefRequestHandler {
  @override
  bool onCertificateError(
    CefBrowser browser,
    CefErrorCode certError,
    String requestUrl,
    CefCallback callback,
  ) {
    debugPrint('[CEF] Auto-accepting SSL cert for $requestUrl ($certError)');
    callback.onContinue(true);
    return true;
  }
}

class _AcWebviewCefLoadHandler extends CefLoadHandler {
  @override
  void onLoadError(
    CefBrowser browser,
    CefFrame frame,
    CefErrorCode errorCode,
    String errorText,
    String failedUrl,
  ) {
    debugPrint('[CEF] Load error on $failedUrl: $errorCode ($errorText)');
  }
}