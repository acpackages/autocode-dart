import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import './ac_ws_client.dart';
import './ac_ws_server.dart';

typedef EventHandler = void Function({dynamic data, void Function({dynamic response})? callback});
typedef AnyEventHandler = void Function({required String event, dynamic data, void Function({dynamic response})? callback});

/// A function that intercepts a WebSocket message using named parameters.
/// [message] is the raw message map which can be modified in-place.
/// [callback] is provided for incoming messages that request an acknowledgment.
/// Calling [abort] will prevent further interceptors and event handlers from being executed.
typedef MessageInterceptor = FutureOr<void> Function({
  required dynamic message,
  void Function({dynamic response})? callback,
  void Function()? abort,
});

class AcWebSocket {
  final WebSocket _webSocket;
  final String id;
  final String nsp;
  final Map<String, dynamic> handshake;
  final AcWsServer? server;
  
  final Map<String, List<EventHandler>> _eventHandlers = {};
  final List<AnyEventHandler> _anyEventHandlers = [];
  int _ackCounter = 0;
  final Map<int, Completer<dynamic>> _pendingAcks = {};

  /// Global interceptors for incoming messages.
  final List<MessageInterceptor> _incomingInterceptors = [];

  /// Global interceptors for outgoing messages.
  final List<MessageInterceptor> _outgoingInterceptors = [];

  /// Event-specific interceptors for incoming messages.
  final Map<String, List<MessageInterceptor>> _eventIncomingInterceptors = {};

  /// Event-specific interceptors for outgoing messages.
  final Map<String, List<MessageInterceptor>> _eventOutgoingInterceptors = {};

  AcWebSocket(this._webSocket, {
    required this.id,
    this.nsp = '/',
    this.handshake = const {},
    this.server,
  }) {
    _listen();
  }

  void _listen() {
    _webSocket.listen(
      (data) async {
        if (data is! String) {
          final bytes = data is Uint8List ? data : Uint8List.fromList(data as List<int>);
          _handleBinary(data: bytes);
          return;
        }
        try {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;

          final ackId = decoded['a'] as int?;
          final nsp = decoded['n'] ?? '/';
          
          void Function({dynamic response})? callback;
          if (ackId != null) {
            callback = ({response}) {
              _send(map: {'r': ackId, 'd': response, 'n': nsp});
            };
          }

          bool aborted = false;
          void abort() => aborted = true;

          // 1. Run global incoming interceptors
          for (var interceptor in _incomingInterceptors) {
            await interceptor(message: decoded, callback: callback, abort: abort);
            if (aborted) return;
          }

          // 2. Run event-specific incoming interceptors
          final event = decoded['e'] as String?;
          if (event != null) {
            final eventInterceptors = _eventIncomingInterceptors[event];
            if (eventInterceptors != null) {
              for (var interceptor in eventInterceptors) {
                await interceptor(message: decoded, callback: callback, abort: abort);
                if (aborted) return;
              }
            }
          }

          if (nsp != this.nsp) return;

          final payload = decoded['d'];
          final respId = decoded['r'] as int?;

          if (respId != null) {
            _pendingAcks.remove(respId)?.complete(payload);
            return;
          }

          if (event != null) {
            _handleEvent(event: event, data: payload, ackId: ackId);
          }
        } catch (e) {
          // Ignore malformed messages or interceptor errors
        }
      },
      onDone: () => _handleEvent(event: 'disconnect'),
      onError: (e) => _handleEvent(event: 'disconnect', data: e),
    );
  }

  void _handleBinary({required Uint8List data}) {
    _handleEvent(event: 'bin', data: data);
  }

  void on({required String event, required EventHandler handler}) {
    _eventHandlers.putIfAbsent(event, () => []).add(handler);
  }

  void onAny({required AnyEventHandler handler}) {
    _anyEventHandlers.add(handler);
  }

  void addIncomingInterceptor(MessageInterceptor handler, {String? event}) {
    if (event == null) {
      _incomingInterceptors.add(handler);
    } else {
      _eventIncomingInterceptors.putIfAbsent(event, () => []).add(handler);
    }
  }

  void addOutgoingInterceptor(MessageInterceptor handler, {String? event}) {
    if (event == null) {
      _outgoingInterceptors.add(handler);
    } else {
      _eventOutgoingInterceptors.putIfAbsent(event, () => []).add(handler);
    }
  }

  void pipe({required AcWsClient client}) {
    onAny(handler: ({required event, data, callback}) async {
      final response = await client.socket?.emit(event: event, data: data);
      if (callback != null) {
        callback(response: response);
      }
    });
  }

  void _handleEvent({required String event, dynamic data, int? ackId}) {
    final handlers = _eventHandlers[event];
    if (handlers != null) {
      for (final handler in handlers) {
        if (ackId != null) {
          handler(data: data, callback: ({response}) {
            _send(map: {'r': ackId, 'd': response, 'n': nsp});
          });
        } else {
          handler(data: data);
        }
      }
    }

    for (final handler in _anyEventHandlers) {
      if (ackId != null) {
        handler(event: event, data: data, callback: ({response}) {
          _send(map: {'r': ackId, 'd': response, 'n': nsp});
        });
      } else {
        handler(event: event, data: data);
      }
    }
  }

  AcWsVolatileSocket get volatile => AcWsVolatileSocket(this);

  Future<dynamic> emit({
    required String event,
    dynamic data,
    bool volatile = false,
    void Function({dynamic response})? callback,
  }) {
    final completer = Completer<dynamic>();
    final ackId = ++_ackCounter;
    _pendingAcks[ackId] = completer;

    _send(map: {'e': event, 'd': data, 'a': ackId, 'n': nsp, if (volatile) 'v': true});

    final future = completer.future.timeout(Duration(seconds: 30), onTimeout: () {
      _pendingAcks.remove(ackId);
      return null;
    });

    if (callback != null) {
      future.then((response) => callback(response: response));
    }

    return future;
  }

  Future<void> _send({required Map<String, dynamic> map}) async {
    try {
      final message = map;
      bool aborted = false;
      void abort() => aborted = true;

      // 1. Run global outgoing interceptors
      for (var interceptor in _outgoingInterceptors) {
        await interceptor(message: message, abort: abort);
        if (aborted) return;
      }

      // 2. Run event-specific outgoing interceptors
      final event = message['e'] as String?;
      if (event != null) {
        final eventInterceptors = _eventOutgoingInterceptors[event];
        if (eventInterceptors != null) {
          for (var interceptor in eventInterceptors) {
            await interceptor(message: message, abort: abort);
            if (aborted) return;
          }
        }
      }

      _webSocket.add(jsonEncode(message));
    } catch (e) {
      print("AcWebSocket: Error sending data: $e");
    }
  }

  void sendBinary({required List<int> bytes}) {
    try {
      _webSocket.add(bytes);
    } catch (e) {
      print("AcWebSocket: Error sending binary: $e");
    }
  }

  void join({required String room}) {
    server?.of(name: nsp).joinRoom(room: room, socket: this);
  }

  void leave({required String room}) {
    server?.of(name: nsp).leaveRoom(room: room, socket: this);
  }

  Future<void> disconnect() async {
    await _webSocket.close();
  }

  bool get isConnected => _webSocket.readyState == WebSocket.open;
  
  @Deprecated('Use addIncomingInterceptor instead')
  List<MessageInterceptor> get incomingInterceptors => _incomingInterceptors;
  @Deprecated('Use addOutgoingInterceptor instead')
  List<MessageInterceptor> get outgoingInterceptors => _outgoingInterceptors;
}

class AcWsVolatileSocket {
  final AcWebSocket _socket;
  AcWsVolatileSocket(this._socket);
  void emit({required String event, dynamic data}) {
    _socket.emit(event: event, data: data, volatile: true);
  }
}
