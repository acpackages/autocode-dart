import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Only import on Windows/Linux — recommended to use conditional import in real project
import 'package:webview_win_floating/webview_win_floating.dart';

import '../ac_webview.dart';

class AcWebviewWinFloating   extends StatefulWidget {
  final String url;
  final Color? backgroundColor;
  final bool? allowDebugging;
  final bool? keepCache;
  // You should inject this from outside or make it injectable
  final AcWebviewActionManager actionManager = AcWebviewActionManager();

  AcWebviewWinFloating  ({
    required this.url,
    this.backgroundColor,
    this.allowDebugging = false,
    this.keepCache = true,
    super.key,
  });

  // Public API
  Future<void> loadUrl(String newUrl) async {
    final state = _AcWebviewState._instances[this];
    await state?._loadUrl(newUrl);
  }

  Future<bool> handleBack() async {
    final state = _AcWebviewState._instances[this];
    return await state?._handleBack() ?? true;
  }

  void sendDataToWebview(Map<String, dynamic> data) {
    final state = _AcWebviewState._instances[this];
    state?._sendToWebView(data);
  }

  String onAction({
    required String name,
    required Function callback,
  }) {
    return actionManager.on(action: name, callback: callback);
  }

  @override
  State<AcWebviewWinFloating  > createState() => _AcWebviewState();
}

class _AcWebviewState extends State<AcWebviewWinFloating  > {
  static final Map<AcWebviewWinFloating  , _AcWebviewState> _instances = {};

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
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor ?? Colors.white)
      ..setNavigationDelegate(
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
      // window.dispatchEvent(new Event('acWebviewChannelReady'));
    })();
    ''';

    await _controller.runJavaScript(bridgeJs);
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
    _controller.runJavaScript( "acWebviewChannel.receive({data:${jsonEncode(data)}});");
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

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return webview;
  }
}