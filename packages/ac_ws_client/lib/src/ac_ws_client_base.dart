import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

typedef EventHandler = void Function(dynamic data, [Function(dynamic response)? ack]);

class AcWsClient {
  final String url;
  final String nsp;
  final Map<String, String> query;
  final SecurityContext? securityContext;
  final bool acceptBadCertificates;

  WebSocket? _webSocket;
  bool _isConnected = false;
  final Map<String, List<EventHandler>> _eventHandlers = {};
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;
  int _ackCounter = 0;
  final Map<int, Completer<dynamic>> _pendingAcks = {};

  AcWsClient(
    this.url, {
    this.nsp = '/',
    this.query = const {},
    this.securityContext,
    this.acceptBadCertificates = false,
  });

  Future<void> connect() async {
    _shouldReconnect = true;
    
    // Auto-convert http(s) to ws(s)
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
      if (uri.scheme == 'wss' || uri.scheme == 'https') {
        final client = HttpClient(context: securityContext);
        if (acceptBadCertificates) {
          client.badCertificateCallback = (cert, host, port) => true;
        }

        _webSocket = await WebSocket.connect(
          uri.replace(scheme: uri.scheme == 'https' ? 'wss' : uri.scheme).toString(),
          customClient: client,
        );
      } else {
        _webSocket = await WebSocket.connect(uri.toString());
      }
      
      _isConnected = true;
      _handleEvent('connect', null, null);

      _webSocket!.listen(
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
        onDone: _handleDisconnect,
        onError: (e) => _handleDisconnect(),
      );
    } catch (e) {
      print('AcWsClient: Connection error: $e');
      _handleDisconnect();
    }
  }

  void _handleBinary(Uint8List data) {
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

  AcWsVolatileClient get volatile => AcWsVolatileClient(this);

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
    if (_isConnected && _webSocket != null) {
      _webSocket!.add(jsonEncode(map));
    }
  }

  void sendBinary(List<int> bytes) {
    if (_isConnected && _webSocket != null) {
      _webSocket!.add(bytes);
    }
  }
  void _handleDisconnect() {
    if (!_isConnected && _reconnectTimer != null) return;
    
    _isConnected = false;
    _webSocket = null;
    _handleEvent('disconnect', null, null);

    if (_shouldReconnect) {
      _reconnectTimer = Timer(Duration(seconds: 2), () {
        _reconnectTimer = null;
        connect();
      });
    }
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _webSocket?.close();
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
}

class AcWsVolatileClient {
  final AcWsClient _client;
  AcWsVolatileClient(this._client);
  void emit(String event, dynamic data) {
    _client.emit(event, data, true);
  }
}
