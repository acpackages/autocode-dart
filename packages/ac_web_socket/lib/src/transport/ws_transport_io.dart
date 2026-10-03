import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
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
  Map<String, dynamic>? headers,
  Iterable<String>? protocols,
}) async {
  final uri = Uri.parse(url);
  final isSecure = uri.scheme == 'wss' || uri.scheme == 'https';
  final httpScheme = isSecure ? 'https' : 'http';
  final defaultPort = isSecure ? 443 : 80;
  final port = uri.hasPort ? uri.port : defaultPort;

  final targetUri = uri.replace(
    scheme: httpScheme,
    port: port == defaultPort ? null : port,
  );

  final client = HttpClient(
    context: securityContext is SecurityContext ? securityContext : null,
  );
  if (acceptBadCertificates) {
    client.badCertificateCallback = (cert, host, port) => true;
  }

  try {
    final request = await client.openUrl('GET', targetUri);

    if (targetUri.userInfo.isNotEmpty) {
      final auth = base64Encode(utf8.encode(targetUri.userInfo));
      request.headers.set(HttpHeaders.authorizationHeader, 'Basic $auth');
    }

    if (headers != null) {
      headers.forEach((field, value) {
        request.headers.add(field, value);
      });
    }

    final nonceData = Uint8List(16);
    final random = Random();
    for (int i = 0; i < 16; i++) {
      nonceData[i] = random.nextInt(256);
    }
    final nonce = base64Encode(nonceData);

    request.headers
      ..set(HttpHeaders.connectionHeader, 'Upgrade')
      ..set(HttpHeaders.upgradeHeader, 'websocket')
      ..set('Sec-WebSocket-Key', nonce)
      ..set('Cache-Control', 'no-cache')
      ..set('Sec-WebSocket-Version', '13');

    if (protocols != null) {
      request.headers.add('Sec-WebSocket-Protocol', protocols.toList());
    }

    final response = await request.close();

    if (response.statusCode != HttpStatus.switchingProtocols) {
      response.detachSocket().then((s) => s.destroy()).catchError((_) {});
      throw WebSocketException(
        "Connection to '$targetUri' was not upgraded to websocket",
        response.statusCode,
      );
    }

    final upgradeHeader = response.headers.value(HttpHeaders.upgradeHeader);
    if (upgradeHeader == null || upgradeHeader.toLowerCase() != 'websocket') {
      response.detachSocket().then((s) => s.destroy()).catchError((_) {});
      throw WebSocketException(
        "Connection to '$targetUri' was not upgraded to websocket",
        response.statusCode,
      );
    }

    final accept = response.headers.value('Sec-WebSocket-Accept');
    if (accept == null) {
      response.detachSocket().then((s) => s.destroy()).catchError((_) {});
      throw WebSocketException(
        "Response did not contain a 'Sec-WebSocket-Accept' header",
      );
    }

    final expectedAccept = base64Encode(
      sha1.convert(utf8.encode('${nonce}258EAFA5-E914-47DA-95CA-C5AB0DC85B11')).bytes,
    );
    if (accept != expectedAccept) {
      response.detachSocket().then((s) => s.destroy()).catchError((_) {});
      throw WebSocketException(
        "Response header 'Sec-WebSocket-Accept' does not match",
      );
    }

    final selectedProtocol = response.headers.value('Sec-WebSocket-Protocol');
    final rawSocket = await response.detachSocket();

    final ws = WebSocket.fromUpgradedSocket(
      rawSocket,
      serverSide: false,
      protocol: selectedProtocol,
    );
    return IoWebSocketTransport(ws);
  } catch (e) {
    client.close(force: true);
    rethrow;
  }
}

