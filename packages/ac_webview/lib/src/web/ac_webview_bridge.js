/**
 * AcWebview Bridge — include in cross-origin web pages loaded inside AcWebview.
 *
 * For same-origin pages this script is injected automatically.
 * For cross-origin pages, add this to your HTML:
 *
 *   <script src="ac_webview_bridge.js"></script>
 *
 * After the bridge loads, your page can:
 *
 *   // Send an action to Flutter (fire-and-forget)
 *   acWebviewJavascriptChannel.postMessage(JSON.stringify({
 *     action: 'myAction',
 *     data: { key: 'value' }
 *   }));
 *
 *   // Send an action and receive a response via callbackId
 *   acWebviewJavascriptChannel.postMessage(JSON.stringify({
 *     action: 'myAction',
 *     data: { key: 'value' },
 *     callbackId: 'unique-id-123'
 *   }));
 *
 *   // Receive data/responses from Flutter
 *   window.acWebviewChannel = {
 *     receive: function(message) {
 *       console.log('From Flutter:', message.data);
 *     }
 *   };
 *
 *   // Wait for bridge readiness
 *   window.addEventListener('acWebviewChannelReady', function() {
 *     console.log('Bridge is ready');
 *   });
 */
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
