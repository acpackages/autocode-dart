import 'dart:async';
import 'dart:io';
import './ac_web_socket.dart';
import './ac_ws_adapter.dart';

typedef MiddlewareHandler = void Function({required AcWebSocket socket, required void Function([dynamic error]) next});

class AcWsServer {
  HttpServer? _server;
  HttpServer? _secureServer;
  final Map<String, AcWsNamespace> _namespaces = {};

  int port = 0;
  int sslPort = 0;
  String sslCertificateChainPath = "";
  String sslPrivateKeyPath = "";

  AcWsServer() {
    _namespaces['/'] = AcWsNamespace(name: '/', server: this);
  }

  AcWsNamespace of({required String name}) {
    return _namespaces.putIfAbsent(name, () => AcWsNamespace(name: name, server: this));
  }

  void onConnection({required void Function({required AcWebSocket socket}) handler}) {
    of(name: '/').onConnection(handler: handler);
  }

  void onDisconnect({required void Function({required AcWebSocket socket}) handler}) {
    of(name: '/').onDisconnect(handler: handler);
  }

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    port = _server!.port;
    _server!.listen(_handleHttpRequest);

    if (sslPort > 0 && sslCertificateChainPath.isNotEmpty && sslPrivateKeyPath.isNotEmpty) {
      SecurityContext securityContext = SecurityContext();
      securityContext.useCertificateChain(sslCertificateChainPath);
      securityContext.usePrivateKey(sslPrivateKeyPath);
      _secureServer = await HttpServer.bindSecure(InternetAddress.anyIPv4, sslPort, securityContext);
      _secureServer!.listen(_handleHttpRequest);
    }
  }

  void _handleHttpRequest(HttpRequest request) async {
    try {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        final webSocket = await WebSocketTransformer.upgrade(request);
        
        final handshake = {
          'headers': request.headers,
          'query': request.uri.queryParameters,
          'address': request.connectionInfo?.remoteAddress.address,
        };

        final socketId = DateTime.now().millisecondsSinceEpoch.toString();
        final nspName = request.uri.queryParameters['nsp'] ?? '/';
        
        final socket = AcWebSocket(webSocket, id: socketId, nsp: nspName, handshake: handshake, server: this);
        
        of(name: nspName)._addSocket(socket: socket);
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        request.response.close();
      }
    } catch (e) {
      print('AcWsServer Error in _handleHttpRequest: $e');
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.close();
      } catch (_) {}
    }
  }

  void _handleDisconnect({required AcWebSocket socket}) {
    for (final nsp in _namespaces.values) {
      if (nsp._sockets.remove(socket)) {
        for (final roomSockets in nsp._rooms.values) {
          roomSockets.remove(socket);
        }
        final handlers = nsp._connectionHandlers['disconnect'];
        if (handlers != null) {
          for (final handler in handlers) {
            handler(socket: socket);
          }
        }
      }
    }
  }

  void emit({required String event, dynamic data}) {
    of(name: '/').emit(event: event, data: data);
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    await _secureServer?.close(force: true);
    for (final nsp in _namespaces.values) {
      for (final socket in nsp._sockets) {
        socket.disconnect();
      }
      nsp._sockets.clear();
      nsp._rooms.clear();
    }
  }
}

class AcWsNamespace {
  final String name;
  final AcWsServer server;
  final Map<String, Set<AcWebSocket>> _rooms = {};
  final Set<AcWebSocket> _sockets = {};
  late AcWsAdapter adapter;
  final List<MiddlewareHandler> _middlewares = [];
  final Map<String, List<void Function({required AcWebSocket socket})>> _connectionHandlers = {};

  AcWsNamespace({required this.name, required this.server}) {
    adapter = AcWsDefaultAdapter(this);
  }

  void use({required MiddlewareHandler handler}) {
    _middlewares.add(handler);
  }

  void onConnection({required void Function({required AcWebSocket socket}) handler}) {
    _connectionHandlers.putIfAbsent('connection', () => []).add(handler);
  }

  void onDisconnect({required void Function({required AcWebSocket socket}) handler}) {
    _connectionHandlers.putIfAbsent('disconnect', () => []).add(handler);
  }

  void _addSocket({required AcWebSocket socket}) {
    _runMiddlewares(socket: socket, index: 0, done: () {
      _sockets.add(socket);
      
      socket.on(event: 'disconnect', handler: ({data, callback}) {
        server._handleDisconnect(socket: socket);
      });

      final handlers = _connectionHandlers['connection'];
      if (handlers != null) {
        for (final handler in handlers) {
          handler(socket: socket);
        }
      }
    });
  }

  void _runMiddlewares({required AcWebSocket socket, required int index, required void Function() done}) {
    if (index >= _middlewares.length) {
      done();
      return;
    }
    _middlewares[index](socket: socket, next: ([error]) {
      if (error != null) {
        socket.disconnect();
        return;
      }
      _runMiddlewares(socket: socket, index: index + 1, done: done);
    });
  }

  void emit({required String event, dynamic data}) {
    adapter.broadcast(event: event, data: data);
  }

  void joinRoom({required String room, required AcWebSocket socket}) {
    _rooms.putIfAbsent(room, () => {}).add(socket);
  }

  void leaveRoom({required String room, required AcWebSocket socket}) {
    _rooms[room]?.remove(socket);
  }

  AcWsRoomNamespace to({required String room}) {
    return AcWsRoomNamespace(nsp: this, room: room);
  }

  Map<String, Set<AcWebSocket>> get rooms => _rooms;
  Set<AcWebSocket> get sockets => _sockets;
}

class AcWsRoomNamespace {
  final AcWsNamespace nsp;
  final String room;

  AcWsRoomNamespace({required this.nsp, required this.room});

  void emit({required String event, dynamic data}) {
    nsp.adapter.broadcast(event: event, data: data, room: room);
  }
}
