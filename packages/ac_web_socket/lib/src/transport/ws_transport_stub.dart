import 'ws_transport.dart';

AcWebSocketTransport wrapWebSocket(dynamic socket) {
  throw UnsupportedError('Cannot wrap socket on unsupported platform.');
}

Future<AcWebSocketTransport> connectTransport({
  required String url,
  dynamic securityContext,
  bool acceptBadCertificates = false,
}) {
  throw UnsupportedError('Cannot connect WebSocket transport on unsupported platform.');
}
