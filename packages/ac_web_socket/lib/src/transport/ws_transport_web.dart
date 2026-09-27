// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'ws_transport.dart';

class WebWebSocketTransport implements AcWebSocketTransport {
  final html.WebSocket _ws;
  WebWebSocketTransport(this._ws) {
    _ws.binaryType = 'arraybuffer';
  }

  @override
  void listen(void Function(dynamic data) onData, {void Function()? onDone, Function? onError}) {
    _ws.onMessage.listen((html.MessageEvent event) {
      final data = event.data;
      if (data is ByteBuffer) {
        onData(Uint8List.view(data));
      } else {
        onData(data);
      }
    });
    _ws.onClose.listen((_) => onDone?.call());
    _ws.onError.listen((e) => onError?.call(e));
  }

  @override
  void add(dynamic data) {
    _ws.send(data);
  }

  @override
  Future<void> close() async {
    _ws.close();
  }

  @override
  int get readyState => _ws.readyState;

  @override
  set pingInterval(Duration? interval) {
    // Browsers automatically manage WebSocket ping/pong
  }
}

AcWebSocketTransport wrapWebSocket(dynamic socket) {
  if (socket is AcWebSocketTransport) return socket;
  if (socket is html.WebSocket) return WebWebSocketTransport(socket);
  throw ArgumentError('Expected html.WebSocket or AcWebSocketTransport, got ${socket.runtimeType}');
}

Future<AcWebSocketTransport> connectTransport({
  required String url,
  dynamic securityContext,
  bool acceptBadCertificates = false,
}) async {
  final completer = Completer<AcWebSocketTransport>();
  final ws = html.WebSocket(url);
  ws.binaryType = 'arraybuffer';

  StreamSubscription? openSub;
  StreamSubscription? errorSub;

  openSub = ws.onOpen.listen((_) {
    openSub?.cancel();
    errorSub?.cancel();
    completer.complete(WebWebSocketTransport(ws));
  });

  errorSub = ws.onError.listen((e) {
    openSub?.cancel();
    errorSub?.cancel();
    if (!completer.isCompleted) {
      completer.completeError(e);
    }
  });

  return completer.future;
}
