import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

typedef EventHandler = void Function(dynamic data, [Function(dynamic response)? ack]);
typedef MiddlewareHandler = void Function(AcWsSocket socket, void Function([dynamic error]) next);

class AcWsSocket {
  final WebSocket _webSocket;
  final String id;
  final AcWsServer server;
  final String nsp;
  final Map<String, dynamic> handshake;
  final Map<String, List<EventHandler>> _eventHandlers = {};
  int _ackCounter = 0;
  final Map<int, Completer<dynamic>> _pendingAcks = {};

  AcWsSocket(this._webSocket, this.id, this.server, this.nsp, this.handshake);

  void _listen() {
    _webSocket.listen(
      (data) {
        if (data is Uint8List) {
          _handleBinary(data);
          return;
        }
        try {
          final decoded = jsonDecode(data as String);
          final nsp = decoded['n'] ?? '/';
          if (nsp != this.nsp) return;

          final event = decoded['e'] as String?;
          final payload = decoded['d'];
          final ackId = decoded['a'] as int?;
          final respId = decoded['r'] as int?;

          if (respId != null) {
            _pendingAcks.remove(respId)?.complete(payload);
            return;
          }

          if (event != null) {
            _handleEvent(event, payload, ackId);
          }
        } catch (e) {
          // Ignore malformed messages
        }
      },
      onDone: () => server._handleDisconnect(this),
      onError: (e) => server._handleDisconnect(this),
    );
  }

  void _handleBinary(Uint8List data) {
    // Basic binary support: emit 'binary' event
    _handleEvent('binary', data, null);
  }

  void on(String event, EventHandler handler) {
    _eventHandlers.putIfAbsent(event, () => []).add(handler);
  }

  void _handleEvent(String event, dynamic data, int? ackId) {
    final handlers = _eventHandlers[event];
    if (handlers != null) {
      for (final handler in handlers) {
        if (ackId != null) {
          handler(data, (response) {
            _send({'r': ackId, 'd': response, 'n': nsp});
          });
        } else {
          handler(data);
        }
      }
    }
  }

  AcWsVolatileSocket get volatile => AcWsVolatileSocket(this);

  Future<dynamic> emit(String event, dynamic data, [bool volatile = false]) {
    final completer = Completer<dynamic>();
    final ackId = ++_ackCounter;
    _pendingAcks[ackId] = completer;

    _send({'e': event, 'd': data, 'a': ackId, 'n': nsp, if (volatile) 'v': true});

    return completer.future.timeout(Duration(seconds: 30), onTimeout: () {
      _pendingAcks.remove(ackId);
      return null;
    });
  }

  void _send(Map<String, dynamic> map) {
    _webSocket.add(jsonEncode(map));
  }

  void sendBinary(List<int> bytes) {
    _webSocket.add(bytes);
  }

  void join(String room) {
    server.of(nsp)._joinRoom(room, this);
  }

  void leave(String room) {
    server.of(nsp)._leaveRoom(room, this);
  }

  void disconnect() {
    _webSocket.close();
  }
}

class AcWsVolatileSocket {
  final AcWsSocket _socket;
  AcWsVolatileSocket(this._socket);
  void emit(String event, dynamic data) {
    _socket.emit(event, data, true);
  }
}

abstract class AcWsAdapter {
  final AcWsNamespace nsp;
  AcWsAdapter(this.nsp);

  void broadcast(String event, dynamic data, {String? room, Set<String>? except});
  void add(String id, String room);
  void del(String id, String room);
  void delAll(String id);
}

class AcWsDefaultAdapter extends AcWsAdapter {
  AcWsDefaultAdapter(super.nsp);

  @override
  void broadcast(String event, dynamic data, {String? room, Set<String>? except}) {
    Set<AcWsSocket>? sockets;
    if (room != null) {
      sockets = nsp._rooms[room];
    } else {
      sockets = nsp._sockets;
    }

    if (sockets != null) {
      for (final socket in sockets) {
        if (except != null && except.contains(socket.id)) continue;
        socket.emit(event, data);
      }
    }
  }

  @override
  void add(String id, String room) {
    // Already handled by basic implementation for now
  }

  @override
  void del(String id, String room) {
    // Already handled by basic implementation for now
  }

  @override
  void delAll(String id) {
    // Already handled by basic implementation for now
  }
}

class AcWsNamespace {
  final String name;
  final AcWsServer server;
  final Map<String, Set<AcWsSocket>> _rooms = {};
  final Set<AcWsSocket> _sockets = {};
  late AcWsAdapter adapter;
  final List<MiddlewareHandler> _middlewares = [];
  final Map<String, List<void Function(AcWsSocket socket)>> _connectionHandlers = {};

  AcWsNamespace(this.name, this.server) {
    adapter = AcWsDefaultAdapter(this);
  }

  void use(MiddlewareHandler handler) {
    _middlewares.add(handler);
  }

  void onConnection(void Function(AcWsSocket socket) handler) {
    _connectionHandlers.putIfAbsent('connection', () => []).add(handler);
  }

  void _runMiddlewares(AcWsSocket socket, int index, void Function() done) {
    if (index >= _middlewares.length) {
      done();
      return;
    }
    _middlewares[index](socket, ([error]) {
      if (error != null) {
        socket.disconnect();
        return;
      }
      _runMiddlewares(socket, index + 1, done);
    });
  }

  void _addSocket(AcWsSocket socket) {
    _runMiddlewares(socket, 0, () {
      _sockets.add(socket);
      final handlers = _connectionHandlers['connection'];
      if (handlers != null) {
        for (final handler in handlers) {
          handler(socket);
        }
      }
    });
  }

  void _joinRoom(String room, AcWsSocket socket) {
    _rooms.putIfAbsent(room, () => {}).add(socket);
  }

  void _leaveRoom(String room, AcWsSocket socket) {
    _rooms[room]?.remove(socket);
  }

  void emit(String event, dynamic data) {
    adapter.broadcast(event, data);
  }

  AcWsRoomNamespace to(String room) {
    return AcWsRoomNamespace(this, room);
  }
}

class AcWsRoomNamespace {
  final AcWsNamespace nsp;
  final String room;

  AcWsRoomNamespace(this.nsp, this.room);

  void emit(String event, dynamic data) {
    nsp.adapter.broadcast(event, data, room: room);
  }
}

class AcWsServer {
  HttpServer? _server;
  HttpServer? _secureServer;
  final Map<String, AcWsNamespace> _namespaces = {};

  int port = 0;

  /* AcDoc({"summary": "The port number for the HTTPS/SSL server."}) */
  int sslPort = 0;

  /* AcDoc({"summary": "The file system path to the SSL certificate chain file (.pem)."}) */
  String sslCertificateChainPath = "";

  /* AcDoc({"summary": "The file system path to the SSL private key file (.key)."}) */
  String sslPrivateKeyPath = "";

  AcWsServer() {
    _namespaces['/'] = AcWsNamespace('/', this);
  }

  AcWsNamespace of(String name) {
    return _namespaces.putIfAbsent(name, () => AcWsNamespace(name, this));
  }

  void onConnection(void Function(AcWsSocket socket) handler) {
    of('/').onConnection(handler);
  }

  Future<void> start() async {
    if(port > 0){
      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _server!.listen(_handleHttpRequest);
    }
    if(sslPort > 0 && sslCertificateChainPath.isNotEmpty && sslPrivateKeyPath.isNotEmpty){
      SecurityContext securityContext = SecurityContext();
      if (sslCertificateChainPath.isNotEmpty) {
        securityContext.useCertificateChain(sslCertificateChainPath);
      }
      if (sslPrivateKeyPath.isNotEmpty) {
        securityContext.usePrivateKey(sslPrivateKeyPath);
      }
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
        
        // Handle initial namespace from query or default
        final nspName = request.uri.queryParameters['nsp'] ?? '/';
        final socket = AcWsSocket(webSocket, socketId, this, nspName, handshake);
        socket._listen();
        of(nspName)._addSocket(socket);
      } else {
        request.response.statusCode = HttpStatus.forbidden;
        request.response.close();
      }
    } catch (e, stack) {
      print('AcWsServer Error in _handleHttpRequest: $e');
      print(stack);
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        request.response.close();
      } catch (_) {}
    }
  }

  void _handleDisconnect(AcWsSocket socket) {
    for (final nsp in _namespaces.values) {
      nsp._sockets.remove(socket);
      for (final roomSockets in nsp._rooms.values) {
        roomSockets.remove(socket);
      }
    }
  }

  void emit(String event, dynamic data) {
    of('/').emit(event, data);
  }

  Future<void> stop() async {
    if(_server != null){
      await _server?.close(force: true);
    }
    if(_secureServer != null){
      await _secureServer?.close(force: true);
    }
    for (final nsp in _namespaces.values) {
      for (final socket in nsp._sockets) {
        socket.disconnect();
      }
      nsp._sockets.clear();
      nsp._rooms.clear();
    }
  }
}
