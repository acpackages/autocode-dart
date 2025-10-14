
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'ac_logger.dart';
/* AcDoc({
  "description": "Utility class that provides functions for generating unique IDs, random strings, console-colored outputs, and UUIDs, along with utility checks for primary keys and values."
}) */
class Autocode {
  /* AcDoc({"description": "ANSI color codes used for console output formatting."}) */
  static final Map<String, dynamic> _consoleColors = {
    "Black": '\x1B[30m',
    "Red": '\x1B[31m',
    "Green": '\x1B[32m',
    "Yellow": '\x1B[33m',
    "Blue": '\x1B[34m',
    "Magenta": '\x1B[35m',
    "Cyan": '\x1B[36m',
    "White": '\x1B[37m',
    "Reset": '\x1B[0m'
  };

  /* AcDoc({"description": "Map of timestamps to sets of generated IDs to ensure uniqueness within the same second."}) */
  static final Map<String, Set<String>> _uniqueIds = {};

  /* AcDoc({"description": "Character set used for generating random alphanumeric strings."}) */
  static final String _characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  /* AcDoc({"description": "Secure random number generator instance."}) */
  static final Random _random = Random.secure();

  /* AcDoc({"description": "Logger instance used by Autocode for internal logging."}) */
  static AcLogger logger = AcLogger();

  /* AcDoc({"description": "Throws unimplemented error for enum reflection (not supported in Dart)."}) */
  static Map<String, dynamic> enumToObject(Type enumType) {
    final mirror = enumType.toString();
    throw UnimplementedError('Enum reflection is limited in Dart. Handle manually for \$mirror.');
  }

  /* AcDoc({"description": "Generates a globally unique ID using timestamp, random parts, and prefix."}) */
  static String uniqueId() {
    // final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // final timestampHex = timestamp.toRadixString(16);
    // final randomPart = _generateRandomHex(16);
    // String id = "ac_\${generateRandomString()}\$timestampHex\$randomPart";
    //
    // final tsKey = timestamp.toString();
    // _uniqueIds.putIfAbsent(tsKey, () => <String>{});
    //
    // while (_uniqueIds[tsKey]!.contains(id)) {
    //   final newRandom = _generateRandomHex(16);
    //   id = "ac_\${generateRandomString()}\$timestampHex\$newRandom";
    // }
    // _uniqueIds[tsKey]!.add(id);

    return uuid();
  }

  /* AcDoc({"description": "Generates a random alphanumeric string of a given length."}) */
  static String generateRandomString([int length = 10]) {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final index = _random.nextInt(_characters.length);
      buffer.write(_characters[index]);
    }
    return buffer.toString();
  }

  /* AcDoc({"description": "Returns the runtime class name of the provided instance."}) */
  static String getClassNameFromInstance(Object instance) {
    return instance.runtimeType.toString();
  }

  /* AcDoc({"description": "Logs and returns the exception message with optional stack trace."}) */
  static String getExceptionMessage({dynamic exception, dynamic stackTrace}) {
    if (stackTrace != null) {
      print(_consoleColors["Red"] + stackTrace.toString() + _consoleColors["Reset"]);
    }
    print(_consoleColors["Red"] + exception.toString() + _consoleColors["Reset"]);
    return exception.toString();
  }

  /* AcDoc({"description": "Validates whether the given value qualifies as a non-null primary key."}) */
  static bool validPrimaryKey(dynamic value) {
    if (value != null && value != '') {
      if (value is String && value != "0") return true;
      if (value is num && value != 0) return true;
    }
    return false;
  }

  /* AcDoc({"description": "Checks if the provided value is not null."}) */
  static bool validValue(dynamic value) {
    return value != null;
  }

  /* AcDoc({"description": "Generates a UUID v4 string using the 'uuid' package."}) */
  static String uuid() {
    var uuid = Uuid();
    String id = uuid.v4();
    return id;
  }

  /* AcDoc({"description": "Generates a random hexadecimal string of the specified length."}) */
  static String _generateRandomHex(int length) {
    final List<int> values = List.generate(length ~/ 2, (_) => _random.nextInt(256));
    return values.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
  }
}
