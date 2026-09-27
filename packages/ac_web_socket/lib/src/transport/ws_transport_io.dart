import 'dart:async';
import 'dart:io';
import 'ws_transport.dart';

class IoWebSocketTransport implements AcWebSocketTransport {
  final WebSocket _ws;
  IoWebSocketTransport(this._ws);

  @override
  void listen(void Function(dynamic data) onData, {void Function()? onDone, Function? onError}) {
    _ws.listen(onData, onDone: onDone, onError: onError);
  }

  @override
  void add(dynamic data) {
    _ws.add(data);
  }

  @override
  Future<void> close() => _ws.close();

  @override
  int get readyState => _ws.readyState;

  @override
  set pingInterval(Duration? interval) {
    _ws.pingInterval = interval;
  }
}

AcWebSocketTransport wrapWebSocket(dynamic socket) {
  if (socket is AcWebSocketTransport) return socket;
  if (socket is WebSocket) return IoWebSocketTransport(socket);
  throw ArgumentError('Expected WebSocket or AcWebSocketTransport, got ${socket.runtimeType}');
}

Future<AcWebSocketTransport> connectTransport({
  required String url,
  dynamic securityContext,
  bool acceptBadCertificates = false,
}) async {
  final uri = Uri.parse(url);
  WebSocket ws;
  if (uri.scheme == 'wss' || uri.scheme == 'https') {
    final client = HttpClient(context: securityContext is SecurityContext ? securityContext : null);
    if (acceptBadCertificates) {
      client.badCertificateCallback = (cert, host, port) => true;
    }
    ws = await WebSocket.connect(
      uri.replace(scheme: uri.scheme == 'https' ? 'wss' : uri.scheme).toString(),
      customClient: client,
    );
  } else {
    ws = await WebSocket.connect(uri.toString());
  }
  return IoWebSocketTransport(ws);
}
