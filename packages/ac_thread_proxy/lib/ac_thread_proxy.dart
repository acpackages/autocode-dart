import 'dart:async';
import 'dart:isolate';
import 'package:ac_mirrors/ac_mirrors.dart';

/// A registry that tracks local hosted objects and active remote proxies.
class AcRpcRegistry {
  final Map<String, dynamic> _localObjects = {};
  int _nextId = 1;
  final String side;

  AcRpcRegistry({required this.side});

  /// Registers a local object and returns a unique ID.
  String register({required dynamic obj}) {
    for (var entry in _localObjects.entries) {
      if (identical(entry.value, obj)) {
        return entry.key;
      }
    }
    final id = '$side-obj-${_nextId++}';
    _localObjects[id] = obj;
    return id;
  }

  /// Registers a local object with a specific ID.
  void registerWithId({required String id, required dynamic obj}) {
    _localObjects[id] = obj;
  }

  /// Gets a local object by its ID.
  dynamic getById({required String id}) {
    return _localObjects[id];
  }
}

/// Helper to parse Symbol to String without dart:mirrors MirrorSystem dependency.
String symbolToString({required Symbol symbol}) {
  final str = symbol.toString();
  final match = RegExp(r'^Symbol\("(.+)"\)$').firstMatch(str);
  if (match != null) {
    return match.group(1)!;
  }
  return str;
}

/// The transparent dynamic proxy that intercepts all method and property calls
/// and delegates them to the remote Isolate via RPC.
class AcIsolateProxy {
  final SendPort sendPort;
  final String objectId;
  final AcRpcRegistry registry;
  final SendPort localSendPort;

  AcIsolateProxy({
    required this.sendPort,
    required this.objectId,
    required this.registry,
    required this.localSendPort,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = symbolToString(symbol: invocation.memberName);
    final isGetter = invocation.isGetter;
    final isSetter = invocation.isSetter;

    final String callType = isGetter
        ? 'get'
        : isSetter
            ? 'set'
            : 'method';

    final responseCompleter = Completer<dynamic>();
    final replyPort = ReceivePort();

    // Serialize arguments
    final serializedPosArgs = invocation.positionalArguments
        .map((arg) => _serialize(value: arg, hostSendPort: localSendPort, registry: registry))
        .toList();

    final serializedNamedArgs = <String, dynamic>{};
    invocation.namedArguments.forEach((symbol, value) {
      final name = symbolToString(symbol: symbol);
      serializedNamedArgs[name] = _serialize(value: value, hostSendPort: localSendPort, registry: registry);
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
        final result = _deserialize(
          value: response['value'],
          registry: registry,
          remoteSendPort: sendPort,
          localSendPort: localSendPort,
        );
        responseCompleter.complete(result);
      }
    });

    return responseCompleter.future;
  }
}

/// Serializes objects for sending across the isolate boundary.
dynamic _serialize({required dynamic value, required SendPort hostSendPort, required AcRpcRegistry registry}) {
  if (value == null ||
      value is num ||
      value is String ||
      value is bool ||
      value is SendPort) {
    return value;
  }
  if (value is List) {
    return value.map((e) => _serialize(value: e, hostSendPort: hostSendPort, registry: registry)).toList();
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k, _serialize(value: v, hostSendPort: hostSendPort, registry: registry)));
  }
  if (value is AcIsolateProxy) {
    return {
      '__ac_proxy_ref__': true,
      'objectId': value.objectId,
      'sendPort': value.sendPort,
    };
  }

  final id = registry.register(obj: value);
  return {
    '__ac_proxy_ref__': true,
    'objectId': id,
    'sendPort': hostSendPort,
  };
}

/// Deserializes objects received from the remote isolate.
dynamic _deserialize({required dynamic value, required AcRpcRegistry registry, required SendPort remoteSendPort, required SendPort localSendPort}) {
  if (value is Map && value['__ac_proxy_ref__'] == true) {
    final String objectId = value['objectId'];
    final SendPort sendPort = value['sendPort'];

    final localObj = registry.getById(id: objectId);
    if (localObj != null) {
      return localObj;
    }

    return AcIsolateProxy(
      sendPort: sendPort,
      objectId: objectId,
      registry: registry,
      localSendPort: localSendPort,
    );
  }
  if (value is List) {
    return value.map((e) => _deserialize(
      value: e,
      registry: registry,
      remoteSendPort: remoteSendPort,
      localSendPort: localSendPort,
    )).toList();
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k, _deserialize(
      value: v,
      registry: registry,
      remoteSendPort: remoteSendPort,
      localSendPort: localSendPort,
    )));
  }
  return value;
}

/// Sets up the RPC host message loop on a given ReceivePort.
void acHostInstance({required dynamic rootInstance, required ReceivePort receivePort, required SendPort remoteSendPort}) {
  final registry = AcRpcRegistry(side: 'child');
  registry.registerWithId(id: 'root', obj: rootInstance);

  final localReceivePort = ReceivePort();
  final localSendPort = localReceivePort.sendPort;

  Future<void> handleMessage(dynamic message) async {
    if (message is! Map) return;

    if (message['type'] == 'rpc') {
      final String objectId = message['objectId'];
      final String callType = message['callType'];
      final String memberName = message['memberName'];
      final List serializedPosArgs = message['positionalArgs'] ?? [];
      final Map serializedNamedArgs = message['namedArgs'] ?? {};
      final SendPort replyTo = message['replyTo'];

      final target = registry.getById(id: objectId);
      if (target == null) {
        replyTo.send({'error': 'Object with ID $objectId not found'});
        return;
      }

      try {
        final posArgs = serializedPosArgs
            .map((arg) => _deserialize(
                  value: arg,
                  registry: registry,
                  remoteSendPort: remoteSendPort,
                  localSendPort: localSendPort,
                ))
            .toList();

        final namedArgs = <Symbol, dynamic>{};
        serializedNamedArgs.forEach((key, val) {
          namedArgs[Symbol(key)] = _deserialize(
            value: val,
            registry: registry,
            remoteSendPort: remoteSendPort,
            localSendPort: localSendPort,
          );
        });

        final instanceMirror = acReflect(target);
        dynamic result;

        if (callType == 'get') {
          result = instanceMirror.getField(Symbol(memberName));
        } else if (callType == 'set') {
          instanceMirror.setField(Symbol(memberName), posArgs.first);
          result = null;
        } else if (callType == 'method') {
          result = instanceMirror.invoke(Symbol(memberName), posArgs, namedArgs);
        }

        if (result is Future) {
          result = await result;
        }

        final serializedResult = _serialize(value: result, hostSendPort: localSendPort, registry: registry);
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
dynamic acGetIsolateInstance({required SendPort sendPort, String objectId = 'root'}) {
  final registry = AcRpcRegistry(side: 'main');
  final localReceivePort = ReceivePort();
  final localSendPort = localReceivePort.sendPort;

  localReceivePort.listen((message) async {
    if (message is! Map) return;
    if (message['type'] == 'rpc') {
      final String objId = message['objectId'];
      final String callType = message['callType'];
      final String memberName = message['memberName'];
      final List serializedPosArgs = message['positionalArgs'] ?? [];
      final Map serializedNamedArgs = message['namedArgs'] ?? {};
      final SendPort replyTo = message['replyTo'];

      final target = registry.getById(id: objId);
      if (target == null) {
        replyTo.send({'error': 'Object with ID $objId not found'});
        return;
      }

      try {
        final posArgs = serializedPosArgs
            .map((arg) => _deserialize(
                  value: arg,
                  registry: registry,
                  remoteSendPort: sendPort,
                  localSendPort: localSendPort,
                ))
            .toList();

        final namedArgs = <Symbol, dynamic>{};
        serializedNamedArgs.forEach((key, val) {
          namedArgs[Symbol(key)] = _deserialize(
            value: val,
            registry: registry,
            remoteSendPort: sendPort,
            localSendPort: localSendPort,
          );
        });

        final instanceMirror = acReflect(target);
        dynamic result;

        if (callType == 'get') {
          result = instanceMirror.getField(Symbol(memberName));
        } else if (callType == 'set') {
          instanceMirror.setField(Symbol(memberName), posArgs.first);
          result = null;
        } else if (callType == 'method') {
          result = instanceMirror.invoke(Symbol(memberName), posArgs, namedArgs);
        }

        if (result is Future) {
          result = await result;
        }

        final serializedResult = _serialize(value: result, hostSendPort: localSendPort, registry: registry);
        replyTo.send({'value': serializedResult});
      } catch (e, stack) {
        replyTo.send({'error': '$e\n$stack'});
      }
    }
  });

  return AcIsolateProxy(
    sendPort: sendPort,
    objectId: objectId,
    registry: registry,
    localSendPort: localSendPort,
  );
}

class _IsolateSpawnConfig {
  final Type clazz;
  final SendPort mainSendPort;
  final List<dynamic> constructorArgs;
  final void Function()? onInit;

  _IsolateSpawnConfig({
    required this.clazz,
    required this.mainSendPort,
    required this.constructorArgs,
    this.onInit,
  });
}

/// Spawns a new isolate, instantiates the class, hosts it, and returns the dynamic proxy.
Future<dynamic> acCreateIsolateInstance({
  required Type clazz,
  List<dynamic> constructorArgs = const [],
  void Function()? onInit,
}) async {
  final mainReceivePort = ReceivePort();

  await Isolate.spawn(
    _isolateEntry,
    _IsolateSpawnConfig(
      clazz: clazz,
      mainSendPort: mainReceivePort.sendPort,
      constructorArgs: constructorArgs,
      onInit: onInit,
    ),
  );

  final ports = await mainReceivePort.first as List;
  final SendPort childSendPort = ports[0];

  return acGetIsolateInstance(sendPort: childSendPort);
}

void _isolateEntry(_IsolateSpawnConfig config) {
  if (config.onInit != null) {
    config.onInit!();
  }
  final classMirror = acReflectClass(config.clazz);
  final instance = classMirror.newInstance('', config.constructorArgs);

  final receivePort = ReceivePort();
  final callbackReceivePort = ReceivePort();

  config.mainSendPort.send([receivePort.sendPort, callbackReceivePort.sendPort]);

  acHostInstance(
    rootInstance: instance,
    receivePort: receivePort,
    remoteSendPort: callbackReceivePort.sendPort,
  );
}
