import 'dart:async';
import 'dart:io';
import './ac_web_socket.dart';

class AcWsClient {
  final String url;
  final String nsp;
  final Map<String, String> query;
  final SecurityContext? securityContext;
  final bool acceptBadCertificates;

  AcWebSocket? _socket;
  bool _shouldReconnect = true;
  final bool instantDetection;
  Timer? _reconnectTimer;
  
  final List<void Function({required AcWebSocket socket})> _connectionHandlers = [];
  final List<void Function({dynamic data})> _disconnectHandlers = [];

  AcWsClient({
    required this.url,
    this.nsp = '/',
    this.query = const {},
    this.securityContext,
    this.acceptBadCertificates = false,
    this.instantDetection = true,
  });

  Future<AcWebSocket?> connect() async {
    _shouldReconnect = true;
    
    String wsUrl = url;
    if (wsUrl.startsWith('https://')) {
      wsUrl = 'wss://${wsUrl.substring(8)}';
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = 'ws://${wsUrl.substring(7)}';
    }

    final uri = Uri.parse(wsUrl).replace(queryParameters: {
      ...query,
      'nsp': nsp,
    });

    try {
      WebSocket ws;
      if (uri.scheme == 'wss' || uri.scheme == 'https') {
        final client = HttpClient(context: securityContext);
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
      
      _socket = AcWebSocket(
        ws, 
        id: 'client', 
        nsp: nsp,
        pingInterval: instantDetection ? const Duration(seconds: 5) : null,
      );
      
      _socket!.on(event: 'disconnect', handler: ({data, callback}) {
        for (var h in _disconnectHandlers) {
          h(data: data);
        }
        _handleDisconnect();
      });

      for (var h in _connectionHandlers) {
        h(socket: _socket!);
      }

      return _socket;
    } catch (e) {
      print('AcWsClient: Connection error: $e');
      _handleDisconnect();
      return null;
    }
  }

  void _handleDisconnect() {
    _socket = null;
    if (_shouldReconnect && _reconnectTimer == null) {
      _reconnectTimer = Timer(Duration(seconds: 2), () {
        _reconnectTimer = null;
        connect();
      });
    }
  }

  void onConnection({required void Function({required AcWebSocket socket}) handler}) {
    _connectionHandlers.add(handler);
    if (_socket != null) {
      handler(socket: _socket!);
    }
  }

  void onDisconnect({required void Function({dynamic data}) handler}) {
    _disconnectHandlers.add(handler);
  }

  AcWsVolatileClient get volatile => AcWsVolatileClient(this);

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await _socket?.disconnect();
    _socket = null;
  }

  AcWebSocket? get socket => _socket;
  bool get isConnected => _socket?.isConnected ?? false;
}

class AcWsVolatileClient {
  final AcWsClient _client;
  AcWsVolatileClient(this._client);
  void emit({required String event, dynamic data}) {
    _client.socket?.emit(event: event, data: data, volatile: true);
  }
}
