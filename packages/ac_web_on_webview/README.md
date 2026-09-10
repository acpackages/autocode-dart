# ac_webview_on_web

A bridge between `AcWeb` and WebView JavaScript channels. This package replicates the functionality of `ac_ws_on_web` but uses JavaScript channels instead of WebSockets to handle requests from a web application running inside a WebView.

## Features

- Handle HTTP-like requests (GET, POST, etc.) over JavaScript channels.
- Support for route matching and path parameters.
- Interceptor support for request validation or modification.
- Seamless integration with `AcWeb` and `AcWebviewActionManager`.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ac_webview_on_web:
    path: path/to/ac_webview_on_web
```

## Usage

### 1. Initialize AcWeb and AcWebviewOnWeb

```dart
final app = AcWeb();
// Define your routes...
app.get('/api/hello', (request) async {
  return AcWebResponse.success(data: {'message': 'Hello from Dart!'});
});

final webviewBridge = AcWebviewOnWeb(app);
```

### 2. Register with AcWebviewActionManager

If you are using `ac_webview`, you can register the bridge directly:

```dart
final actionManager = AcWebviewActionManager();
webviewBridge.registerWithActionManager(actionManager);

// In your WebView setup:
JavascriptChannel(
  name: 'AcWebChannel',
  onMessageReceived: (message) async {
    final json = jsonDecode(message.message);
    final result = await actionManager.performAction(actionJson: json);
    // Send result back to JS if needed
    controller.runJavaScript("window.onAcWebResponse(${jsonEncode(result.response)})");
  },
)
```

### 3. JavaScript Side

From your web application:

```javascript
window.AcWebChannel.postMessage(JSON.stringify({
  action: 'web_request',
  data: {
    method: 'GET',
    url: '/api/hello'
  }
}));
```

## License

MIT
