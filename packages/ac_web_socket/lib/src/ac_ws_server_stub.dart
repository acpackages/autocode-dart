import './ac_web_socket.dart';

class AcWsServer {
  AcWsServer() {
    throw UnsupportedError('AcWsServer is only supported on server/desktop (dart:io).');
  }

  void onConnection({required void Function({required AcWebSocket socket}) handler}) {
    throw UnsupportedError('AcWsServer is only supported on server/desktop (dart:io).');
  }

  void onDisconnect({required void Function({required AcWebSocket socket}) handler}) {
    throw UnsupportedError('AcWsServer is only supported on server/desktop (dart:io).');
  }
}
