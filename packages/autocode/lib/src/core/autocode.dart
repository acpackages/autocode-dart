import 'dart:math';
import 'package:uuid/uuid.dart';
import 'ac_logger.dart';

class Autocode {
  static final Map<String,dynamic > _consoleColors = {
    "Black":'\x1B[30m',
    "Red":'\x1B[31m',
    "Green":'\x1B[32m',
    "Yellow":'\x1B[33m',
    "Blue":'\x1B[34m',
    "Magenta":'\x1B[35m',
    "Cyan":'\x1B[36m',
    "White":'\x1B[37m',
    "Reset":'\x1B[0m'
  };
  static final Map<String, Set<String>> _uniqueIds = {};

  static final String _characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random.secure();
  static AcLogger logger =  AcLogger();

  static Map<String, dynamic> enumToObject(Type enumType) {
    final mirror = enumType.toString();
    throw UnimplementedError('Enum reflection is limited in Dart. Handle manually for $mirror.');
  }

  static String uniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timestampHex = timestamp.toRadixString(16);
    final randomPart = _generateRandomHex(16);
    String id = "ac_${generateRandomString()}$timestampHex$randomPart";

    final tsKey = timestamp.toString();
    _uniqueIds.putIfAbsent(tsKey, () => <String>{});

    while (_uniqueIds[tsKey]!.contains(id)) {
      final newRandom = _generateRandomHex(16);
      id = "ac_${generateRandomString()}$timestampHex$newRandom";
    }
    _uniqueIds[tsKey]!.add(id);

    return id;
  }

  static String generateRandomString([int length = 10]) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final index = _random.nextInt(_characters.length);
      buffer.write(_characters[index]);
    }
    return buffer.toString();
  }

  static String getClassNameFromInstance(Object instance) {
    return instance.runtimeType.toString();
  }

  static String getExceptionMessage({dynamic exception,dynamic stackTrace}) {
    if(stackTrace!=null){
      print(_consoleColors["Red"]+stackTrace.toString()+_consoleColors["Reset"]);
    }
    print(_consoleColors["Red"]+exception.toString()+_consoleColors["Reset"]);
    return exception.toString();
  }

  static bool validPrimaryKey(dynamic value) {
    if (value != null && value != '') {
      if (value is String && value != "0") return true;
      if (value is num && value != 0) return true;
    }
    return false;
  }

  static bool validValue(dynamic value) {
    return value != null;
  }

  static String uuid() {
    var uuid = Uuid();
    String id = uuid.v4();
    return id;
  }

  static String _generateRandomHex(int length) {
    final List<int> values = List.generate(length ~/ 2, (_) => _random.nextInt(256));
    return values.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  }
}
