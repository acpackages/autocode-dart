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
    Duration? pingInterval,
  }) {
    if (pingInterval != null) {
      _webSocket.pingInterval = pingInterval;
    }
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
    if (data.length > 2 && data[0] == 0xAC) {
      final eventLen = data[1];
      if (data.length >= 2 + eventLen) {
        try {
          final eventName = utf8.decode(data.sublist(2, 2 + eventLen));
          final payload = data.sublist(2 + eventLen);
          _handleEvent(event: eventName, data: payload);
          return;
        } catch (e) {
          // Fallback to raw binary if decoding fails
        }
      }
    }
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

  /// Emits a binary event. Use this for high-performance streaming (video/audio).
  ///
  /// Protocol: [0xAC] [eventLen (1 byte)] [event...] [payload...]
  void emitBinary({required String event, required List<int> data}) {
    try {
      final eventBytes = utf8.encode(event);
      if (eventBytes.length > 255) throw Exception("Event name too long for binary event");
      
      final buffer = Uint8List(2 + eventBytes.length + data.length);
      buffer[0] = 0xAC; 
      buffer[1] = eventBytes.length;
      buffer.setRange(2, 2 + eventBytes.length, eventBytes);
      buffer.setRange(2 + eventBytes.length, buffer.length, data);
      _webSocket.add(buffer);
    } catch (e) {
      print("AcWebSocket: Error sending binary event: $e");
    }
  }

  /// Emits a stream of data. If data is List<int>, it's sent as a sequence of binary events.
  /// Otherwise, it's sent via JSON (Base64 for binary).
  void emitStream({
    required String event,
    required Stream<dynamic> stream,
    Map<String, dynamic>? metadata,
    bool binary = true,
  }) {
    final String transferId = "stream_${DateTime.now().millisecondsSinceEpoch}_$id";

    // 1. Send start notification (JSON)
    emit(event: event, data: {
      'action': 'start',
      'transferId': transferId,
      'metadata': metadata,
      'isBinary': binary,
    });

    // 2. Send chunks
    stream.listen((data) {
      if (binary && data is List<int>) {
        emitBinary(event: event, data: data);
      } else {
        dynamic payload = data;
        if (data is List<int>) payload = base64Encode(data);
        
        emit(event: event, data: {
          'action': 'chunk',
          'transferId': transferId,
          'data': payload,
        });
      }
    }, onDone: () {
      // 3. Send end notification
      emit(event: event, data: {
        'action': 'end',
        'transferId': transferId,
      });
    });
  }

  /// Registers a handler for incoming streams.
  void onStream({
    required String event,
    required void Function({
      required String transferId,
      required Stream<dynamic> stream,
      Map<String, dynamic>? metadata,
    }) handler,
  }) {
    final Map<String, StreamController<dynamic>> controllers = {};

    on(event: event, handler: ({data, callback}) {
      if (data is List<int>) {
        // This is a binary chunk for an ongoing stream.
        // We don't have a transferId here in the binary frame, 
        // so we assume it belongs to the most recent stream for this event.
        // For multi-stream support, use JSON-based streaming or tagged binary streams.
        for (final controller in controllers.values) {
           if (!controller.isClosed) controller.add(data);
        }
        return;
      }

      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      final String? action = payload['action'] as String?;
      final String? transferId = payload['transferId'] as String?;

      if (action == 'start' && transferId != null) {
        final StreamController<dynamic> controller = StreamController<dynamic>();
        controllers[transferId] = controller;

        handler(
          transferId: transferId,
          stream: controller.stream,
          metadata: payload['metadata'] != null ? Map<String, dynamic>.from(payload['metadata']) : null,
        );
      } else if (action == 'chunk' && transferId != null) {
        controllers[transferId]?.add(payload['data']);
      } else if (action == 'end' && transferId != null) {
        controllers.remove(transferId)?.close();
      }

      if (callback != null) {
        callback(response: {'success': true});
      }
    });
  }

  /// Sends a file in chunks with a progress callback.
  ///
  /// [file] The file to be sent.
  /// [event] The event name to use for the transfer (default: 'file').
  /// [metadata] Optional metadata to send with the file.
  /// [onProgress] A callback that receives the progress as a double (0.0 to 1.0).
  /// [chunkSize] The size of each chunk in bytes (default: 64KB).
  Future<void> sendFile({
    required File file,
    String event = 'file',
    Map<String, dynamic>? metadata,
    void Function(double progress)? onProgress,
    int chunkSize = 64 * 1024,
  }) async {
    final int totalSize = await file.length();
    final String name = file.path.split(Platform.pathSeparator).last;
    final String transferId = "${DateTime.now().millisecondsSinceEpoch}_$id";

    // 1. Send start
    await emit(event: event, data: {
      'action': 'start',
      'transferId': transferId,
      'name': name,
      'size': totalSize,
      'metadata': metadata,
    });

    // 2. Send chunks
    final RandomAccessFile raf = await file.open(mode: FileMode.read);
    try {
      int sent = 0;
      while (sent < totalSize) {
        final int length = (totalSize - sent) < chunkSize ? (totalSize - sent) : chunkSize;
        final List<int> buffer = await raf.read(length);

        await emit(event: event, data: {
          'action': 'chunk',
          'transferId': transferId,
          'data': base64Encode(buffer),
        });

        sent += length;
        if (onProgress != null) {
          onProgress(sent / totalSize);
        }
      }
    } finally {
      await raf.close();
    }

    // 3. Send end
    await emit(event: event, data: {
      'action': 'end',
      'transferId': transferId,
    });
  }

  /// Registers a handler for incoming file transfers.
  ///
  /// [event] The event name to listen for (default: 'file').
  /// [handler] The callback to execute when a file transfer starts.
  void onFile({
    String event = 'file',
    required void Function({
      required String transferId,
      required String name,
      required int totalSize,
      required Stream<List<int>> stream,
      Map<String, dynamic>? metadata,
    }) handler,
  }) {
    final Map<String, StreamController<List<int>>> controllers = {};

    on(event: event, handler: ({data, callback}) {
      final Map<String, dynamic> payload = Map<String, dynamic>.from(data);
      final String action = payload['action'] as String;
      final String transferId = payload['transferId'] as String;

      if (action == 'start') {
        final StreamController<List<int>> controller = StreamController<List<int>>();
        controllers[transferId] = controller;

        handler(
          transferId: transferId,
          name: payload['name'] as String,
          totalSize: payload['size'] as int,
          stream: controller.stream,
          metadata: payload['metadata'] != null ? Map<String, dynamic>.from(payload['metadata']) : null,
        );
      } else if (action == 'chunk') {
        final List<int> chunk = base64Decode(payload['data'] as String);
        controllers[transferId]?.add(chunk);
      } else if (action == 'end') {
        controllers.remove(transferId)?.close();
      }

      if (callback != null) {
        callback(response: {'success': true});
      }
    });
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
