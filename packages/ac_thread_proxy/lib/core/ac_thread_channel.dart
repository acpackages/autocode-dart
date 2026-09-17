import 'dart:async';
import 'dart:isolate';
import 'package:autocode/autocode.dart';

import '../models/ac_thread_channel_message.dart';

class AcThreadChannel {
  ReceivePort? receivePort;
  SendPort? sendPort;
  int _lastMessageId = -1;
  final Map<int, Map<String, dynamic>> _pendingRequests = {};
  final Map<String, Function({required Map<String,dynamic> args})> _keyCallbacks = {};
  final List<Map<String, dynamic>> _outgoingQueue = [];
  AcLogger logger = AcLogger(logMessages: false, logType: AcEnumLogType.console);

  AcThreadChannel({this.receivePort, this.sendPort}) {
    if (sendPort != null && receivePort == null) {
      receivePort = ReceivePort();
      Map<String, dynamic> handshakeData = {
        "__is_channel_handshake__": true,
        "send_port": receivePort!.sendPort,
      };
      sendPort!.send(handshakeData);
    }
    if (receivePort != null) {
      receivePort!.listen((rawData) async {
        // print("Received at receive port");
        // print(rawData);
        if (rawData is! Map) return;
        final rawJson = Map<String, dynamic>.from(rawData);
        if (rawJson.containsKey("__is_channel_handshake__") && rawJson.containsKey("send_port")) {
          sendPort = rawJson['send_port'] as SendPort;
          _flushQueue();
        } else {
          var message = AcThreadChannelMessage.instanceFromJson(jsonData: rawJson);
          if (message.isResponse) {
            logger.log("[AcThreadChannel] Received response message for key : ${message.key}");
            if (_pendingRequests.containsKey(message.id)) {
              final pending = _pendingRequests.remove(message.id)!;
              final completer = pending['completer'] as Completer<dynamic>?;
              final callback = pending['callback'] as Function?;

              if (message.isError || (message.error != null && message.error.toString().isNotEmpty)) {
                logger.error("[AcThreadChannel] Response error for key '${message.key}': ${message.error}");
                if (callback != null) {
                  try {
                    callback(null);
                  } catch (_) {}
                }
                if (completer != null && !completer.isCompleted) {
                  completer.completeError(
                    message.error ?? 'AcThreadChannel error',
                    message.stackTrace != null && message.stackTrace!.isNotEmpty
                        ? StackTrace.fromString(message.stackTrace!)
                        : null,
                  );
                }
              } else {
                if (callback != null) {
                  try {
                    callback(message.response);
                  } catch (cbEx, cbStack) {
                    logger.error("[AcThreadChannel] Error in response callback for '${message.key}': $cbEx\n$cbStack");
                  }
                }
                if (completer != null && !completer.isCompleted) {
                  completer.complete(message.response);
                }
              }
            } else {
              logger.warn("[AcThreadChannel] Received response for unknown request id: ${message.id} (key: ${message.key})");
            }
          } else {
            if (!_keyCallbacks.containsKey(message.key)) {
              logger.warn("[AcThreadChannel] No callback registered for key : ${message.key}");
              message.isResponse = true;
              message.isError = true;
              message.error = "No callback registered for key: ${message.key}";
              _send(message.toJson());
              return;
            }

            try {
              logger.log("[AcThreadChannel] Calling callback for key : ${message.key}");
              dynamic res = await _keyCallbacks[message.key]!(args: message.data);
              message.response = res;
              message.isResponse = true;
              message.isError = false;
              logger.log("[AcThreadChannel] Returning callback response for key : ${message.key}");
              _send(message.toJson());
            } catch (e, stack) {
              logger.error("[AcThreadChannel] Error in handler for key '${message.key}': $e");
              logger.error(stack);
              message.isResponse = true;
              message.isError = true;
              message.error = e.toString();
              message.stackTrace = stack.toString();
              _send(message.toJson());
            }
          }
        }
      });
    }
  }

  Future<void> _send(Map<String, dynamic> data) async {
    if (sendPort != null) {
      print("[AcThreadChannel] Sending data");
      print(data);
      // print("Sent to send port");
      // if
      sendPort!.send(data);
    } else {
      // print("Added to outgoing queue");
      _outgoingQueue.add(data);
    }
  }

  void _flushQueue() {
    if (sendPort == null) return;
    while (_outgoingQueue.isNotEmpty) {
      sendPort!.send(_outgoingQueue.removeAt(0));
    }
  }

  Future<dynamic> emit({required String key, Map<String,dynamic> data = const {}, Function? callback, Duration? timeout}) {
    _lastMessageId++;
    final messageId = _lastMessageId;
    var message = AcThreadChannelMessage(key: key, data: data, id: messageId);
    final completer = Completer<dynamic>();
    _pendingRequests[messageId] = {
      "completer": completer,
      "callback": callback,
      "key": key,
    };
    _send(message.toJson());

    if (timeout != null) {
      return completer.future.timeout(
        timeout,
        onTimeout: () {
          _pendingRequests.remove(messageId);
          throw TimeoutException('AcThreadChannel request for key "$key" (id: $messageId) timed out after $timeout');
        },
      );
    }
    return completer.future;
  }

  void on({required String key, required Function({required Map<String,dynamic> args}) callback}) {
    _keyCallbacks[key] = callback;
  }

  void off({required String key}) {
    _keyCallbacks.remove(key);
  }

  void close() {
    receivePort?.close();
    for (var entry in _pendingRequests.values) {
      final completer = entry['completer'] as Completer<dynamic>?;
      final key = entry['key']?.toString() ?? 'unknown';
      if (completer != null && !completer.isCompleted) {
        completer.completeError(StateError('AcThreadChannel was closed while waiting for key "$key"'));
      }
    }
    _pendingRequests.clear();
    _keyCallbacks.clear();
    _outgoingQueue.clear();
  }
}