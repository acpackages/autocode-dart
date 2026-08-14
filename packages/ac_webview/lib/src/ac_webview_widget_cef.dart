import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ac_cef_flutter/ac_cef_flutter.dart';
import 'package:autocode/autocode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/ac_webview_action_manager.dart';

class AcWebviewCef extends StatefulWidget {
  final String url;
  final Color? backgroundColor;
  final bool? allowDebugging;
  final bool? keepCache;
  final CefNativeClient? nativeClient;

  final AcLogger logger = AcLogger();
  late final AcWebviewActionManager actionManager;

  AcWebviewCef({
    required this.url,
    this.backgroundColor,
    this.allowDebugging = false,
    this.keepCache = true,
    this.nativeClient,
    AcWebviewActionManager? actionManager,
    super.key,
  }) : actionManager = actionManager ?? AcWebviewActionManager();

  // Public API
  Future<void> loadUrl(String newUrl) async {
    final state = _AcWebviewCefStandaloneState._instances[this];
    await state?._loadUrl(newUrl);
  }

  Future<void> reload() async {
    final state = _AcWebviewCefStandaloneState._instances[this];
    await state?._reload();
  }

  Future<bool> handleBack() async {
    final state = _AcWebviewCefStandaloneState._instances[this];
    return await state?._handleBack() ?? true;
  }

  runJavascript(String javascript) async {
    final state = _AcWebviewCefStandaloneState._instances[this];
    state?.runJavascript(javascript);
  }

  void sendDataToWebview(dynamic data) {
    final state = _AcWebviewCefStandaloneState._instances[this];
    state?._sendToWebView(data);
  }

  void emitEvent({required String name, dynamic data}) {
    sendDataToWebview({'event': 'appContextChange', 'data': data});
  }

  String onAction({
    required String name,
    required Function callback,
  }) {
    return actionManager.on(action: name, callback: callback);
  }

  @override
  State<AcWebviewCef> createState() => _AcWebviewCefStandaloneState();
}

class _AcWebviewCefStandaloneState extends State<AcWebviewCef> {
  static final Map<AcWebviewCef, _AcWebviewCefStandaloneState> _instances = {};

  CefNativeClient? _nativeClient;
  CefController? _controller;
  bool _isInitialized = false;

  static Future<CefNativeClient> _ensureNativeClient() async {
    if (isCefInitialized && defaultCefNativeClient != null) {
      return defaultCefNativeClient!;
    }
    final client = CefClient();
    client.addRequestHandler(_AcWebviewCefStandaloneRequestHandler());
    client.addLoadHandler(_AcWebviewCefStandaloneLoadHandler());
    return await initCef(client: client);
  }

  @override
  void initState() {
    super.initState();
    _instances[widget] = this;
    _initialize();
  }

  @override
  void dispose() {
    _instances.remove(widget);
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

  Future<void> _sendToWebView(dynamic data) async {
    final jsonPayload = jsonEncode(data);
    try {
      _controller?.executeJavaScript("acWebviewChannel.receive({data:$jsonPayload});");
    } catch (e) {
      debugPrint('Error sending data to CEF webview: $e');
    }
  }

  Future<void> _loadUrl(String newUrl) async {
    try {
      _controller?.loadUrl(newUrl);
    } catch (e) {
      debugPrint('Error loading URL in CEF webview: $e');
    }
  }

  Future<void> _reload() async {
    try {
      _controller?.reload();
    } catch (e) {
      debugPrint('Error reloading CEF webview: $e');
    }
  }

  Future<bool> _handleBack() async {
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

  runJavascript(String javascript) async {
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
          _AcWebviewCefStandaloneQueryHandler(_handleMessageFromWeb),
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

class _AcWebviewCefStandaloneQueryHandler implements CefMessageRouterHandler {
  final Future<void> Function(String) onMessage;
  _AcWebviewCefStandaloneQueryHandler(this.onMessage);

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

class _AcWebviewCefStandaloneRequestHandler extends CefRequestHandler {
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

class _AcWebviewCefStandaloneLoadHandler extends CefLoadHandler {
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
