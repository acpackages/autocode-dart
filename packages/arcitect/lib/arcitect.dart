import 'dart:async';
import 'dart:isolate';
import 'dart:mirrors';

/// A registry that tracks local hosted objects and active remote proxies.
class AcRpcRegistry {
  final Map<String, dynamic> _localObjects = {};
  int _nextId = 1;
  final String _side; // 'main' or 'child'

  AcRpcRegistry(this._side);

  /// Registers a local object and returns a unique ID.
  String register(dynamic obj) {
    // If already registered, return existing ID
    for (var entry in _localObjects.entries) {
      if (identical(entry.value, obj)) {
        return entry.key;
      }
    }
    final id = '$_side-obj-${_nextId++}';
    _localObjects[id] = obj;
    return id;
  }

  /// Registers a local object with a specific ID (e.g. 'root').
  void registerWithId(String id, dynamic obj) {
    _localObjects[id] = obj;
  }

  /// Gets a local object by its ID.
  dynamic getById(String id) {
    return _localObjects[id];
  }
}

/// Helper to parse Symbol to String cross-platform.
String symbolToString(Symbol symbol) {
  return MirrorSystem.getName(symbol);
}

/// The transparent dynamic proxy that intercepts all method and property calls
/// and delegates them to the remote Isolate via RPC.
class AcIsolateProxy {
  final SendPort sendPort;
  final String objectId;
  final AcRpcRegistry registry;
  final SendPort localSendPort;

  AcIsolateProxy(this.sendPort, this.objectId, this.registry, this.localSendPort);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = symbolToString(invocation.memberName);
    final isGetter = invocation.isGetter;
    final isSetter = invocation.isSetter;
    final isMethod = invocation.isMethod;

    final String callType = isGetter
        ? 'get'
        : isSetter
            ? 'set'
            : 'method';

    final responseCompleter = Completer<dynamic>();
    final replyPort = ReceivePort();

    // Serialize arguments
    final serializedPosArgs = invocation.positionalArguments
        .map((arg) => _serialize(arg, localSendPort, registry))
        .toList();

    final serializedNamedArgs = <String, dynamic>{};
    invocation.namedArguments.forEach((symbol, value) {
      final name = symbolToString(symbol);
      serializedNamedArgs[name] = _serialize(value, localSendPort, registry);
    });

    // Send RPC Request
    sendPort.send({
      'type': 'rpc',
      'objectId': objectId,
      'callType': callType,
      'memberName': isSetter && memberName.endsWith('=')
          ? memberName.substring(0, memberName.length - 1)
          : memberName,
      'positionalArgs': serializedPosArgs,
      'namedArgs': serializedNamedArgs,
      'replyTo': replyPort.sendPort,
    });

    // Handle reply
    replyPort.first.then((response) {
      replyPort.close();
      if (response is Map && response.containsKey('error')) {
        responseCompleter.completeError(
            Exception('RPC Error: ${response['error']}'));
      } else {
        final result = _deserialize(response['value'], registry, sendPort, localSendPort);
        responseCompleter.complete(result);
      }
    });

    return responseCompleter.future;
  }
}

/// Serializes objects for sending across the isolate boundary.
dynamic _serialize(dynamic value, SendPort hostSendPort, AcRpcRegistry registry) {
  if (value == null ||
      value is num ||
      value is String ||
      value is bool ||
      value is SendPort) {
    return value;
  }
  if (value is List) {
    return value.map((e) => _serialize(e, hostSendPort, registry)).toList();
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k, _serialize(v, hostSendPort, registry)));
  }
  if (value is AcIsolateProxy) {
    return {
      '__ac_proxy_ref__': true,
      'objectId': value.objectId,
      'sendPort': value.sendPort,
    };
  }

  // Fallback: register the local custom class instance and pass by proxy
  final id = registry.register(value);
  return {
    '__ac_proxy_ref__': true,
    'objectId': id,
    'sendPort': hostSendPort,
  };
}

/// Deserializes objects received from the remote isolate.
dynamic _deserialize(dynamic value, AcRpcRegistry registry, SendPort remoteSendPort, SendPort localSendPort) {
  if (value is Map && value['__ac_proxy_ref__'] == true) {
    final String objectId = value['objectId'];
    final SendPort sendPort = value['sendPort'];

    // If it originated locally on this side, return the actual instance
    final localObj = registry.getById(objectId);
    if (localObj != null) {
      return localObj;
    }

    // Otherwise, wrap in a new dynamic proxy
    return AcIsolateProxy(sendPort, objectId, registry, localSendPort);
  }
  if (value is List) {
    return value.map((e) => _deserialize(e, registry, remoteSendPort, localSendPort)).toList();
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k, _deserialize(v, registry, remoteSendPort, localSendPort)));
  }
  return value;
}

/// Sets up the RPC host message loop on a given ReceivePort.
void acHostInstance(dynamic rootInstance, ReceivePort receivePort, SendPort remoteSendPort) {
  final registry = AcRpcRegistry('child');
  registry.registerWithId('root', rootInstance);

  final localReceivePort = ReceivePort();
  final localSendPort = localReceivePort.sendPort;

  // Function to process RPC requests
  Future<void> handleMessage(dynamic message) async {
    if (message is! Map) return;

    if (message['type'] == 'rpc') {
      final String objectId = message['objectId'];
      final String callType = message['callType'];
      final String memberName = message['memberName'];
      final List serializedPosArgs = message['positionalArgs'] ?? [];
      final Map serializedNamedArgs = message['namedArgs'] ?? {};
      final SendPort replyTo = message['replyTo'];

      final target = registry.getById(objectId);
      if (target == null) {
        replyTo.send({'error': 'Object with ID $objectId not found'});
        return;
      }

      try {
        final posArgs = serializedPosArgs
            .map((arg) => _deserialize(arg, registry, remoteSendPort, localSendPort))
            .toList();

        final namedArgs = <Symbol, dynamic>{};
        serializedNamedArgs.forEach((key, val) {
          namedArgs[Symbol(key)] = _deserialize(val, registry, remoteSendPort, localSendPort);
        });

        final instanceMirror = reflect(target);
        dynamic result;

        if (callType == 'get') {
          result = instanceMirror.getField(Symbol(memberName)).reflectee;
        } else if (callType == 'set') {
          instanceMirror.setField(Symbol(memberName), posArgs.first);
          result = null;
        } else if (callType == 'method') {
          result = instanceMirror.invoke(Symbol(memberName), posArgs, namedArgs).reflectee;
        }

        if (result is Future) {
          result = await result;
        }

        final serializedResult = _serialize(result, localSendPort, registry);
        replyTo.send({'value': serializedResult});
      } catch (e, stack) {
        replyTo.send({'error': '$e\n$stack'});
      }
    }
  }

  receivePort.listen(handleMessage);
  localReceivePort.listen(handleMessage);
}

/// Returns a dynamic proxy connected to the hosted isolate instance.
dynamic acGetIsolateInstance(SendPort sendPort, {String objectId = 'root'}) {
  final registry = AcRpcRegistry('main');
  final localReceivePort = ReceivePort();
  final localSendPort = localReceivePort.sendPort;

  // Listen for callback RPC calls from the child isolate
  localReceivePort.listen((message) async {
    if (message is! Map) return;
    if (message['type'] == 'rpc') {
      final String objId = message['objectId'];
      final String callType = message['callType'];
      final String memberName = message['memberName'];
      final List serializedPosArgs = message['positionalArgs'] ?? [];
      final Map serializedNamedArgs = message['namedArgs'] ?? {};
      final SendPort replyTo = message['replyTo'];

      final target = registry.getById(objId);
      if (target == null) {
        replyTo.send({'error': 'Object with ID $objId not found'});
        return;
      }

      try {
        final posArgs = serializedPosArgs
            .map((arg) => _deserialize(arg, registry, sendPort, localSendPort))
            .toList();

        final namedArgs = <Symbol, dynamic>{};
        serializedNamedArgs.forEach((key, val) {
          namedArgs[Symbol(key)] = _deserialize(val, registry, sendPort, localSendPort);
        });

        final instanceMirror = reflect(target);
        dynamic result;

        if (callType == 'get') {
          result = instanceMirror.getField(Symbol(memberName)).reflectee;
        } else if (callType == 'set') {
          instanceMirror.setField(Symbol(memberName), posArgs.first);
          result = null;
        } else if (callType == 'method') {
          result = instanceMirror.invoke(Symbol(memberName), posArgs, namedArgs).reflectee;
        }

        if (result is Future) {
          result = await result;
        }

        final serializedResult = _serialize(result, localSendPort, registry);
        replyTo.send({'value': serializedResult});
      } catch (e, stack) {
        replyTo.send({'error': '$e\n$stack'});
      }
    }
  });

  return AcIsolateProxy(sendPort, objectId, registry, localSendPort);
}

/// Entrypoint configuration for spawning isolate.
class _IsolateSpawnConfig {
  final Type clazz;
  final SendPort mainSendPort;
  final List<dynamic> constructorArgs;

  _IsolateSpawnConfig(this.clazz, this.mainSendPort, this.constructorArgs);
}

/// Spawns a new isolate, instantiates the class, hosts it, and returns the dynamic proxy.
Future<dynamic> acCreateIsolateInstance(Type clazz, {List<dynamic> constructorArgs = const []}) async {
  final mainReceivePort = ReceivePort();
  
  await Isolate.spawn(_isolateEntry, _IsolateSpawnConfig(clazz, mainReceivePort.sendPort, constructorArgs));

  final ports = await mainReceivePort.first as List;
  final SendPort childSendPort = ports[0];
  final SendPort mainSendPort = ports[1];

  return acGetIsolateInstance(childSendPort);
}

/// Spawned Isolate Entry Point.
void _isolateEntry(_IsolateSpawnConfig config) {
  final classMirror = reflectClass(config.clazz);
  final instance = classMirror.newInstance(Symbol(''), config.constructorArgs).reflectee;

  final receivePort = ReceivePort();
  
  // Create a separate port for callbacks
  final callbackReceivePort = ReceivePort();

  config.mainSendPort.send([receivePort.sendPort, callbackReceivePort.sendPort]);

  acHostInstance(instance, receivePort, callbackReceivePort.sendPort);
}
