/* AcDoc({
  "description": "Utility class for common string operations.",
  "methods": {
    "random": "Generates a random string combining secure random bytes and the current timestamp in milliseconds. Useful for creating unique identifiers or tokens."
  },
  "returns": {
    "random": "A hexadecimal string followed by the current timestamp, ensuring high uniqueness."
  },
  "security": "Uses `Random.secure()` for cryptographically strong randomness."
}) */
import 'dart:math';

class AcStringUtils {
  static String random() {
    final randomBytes = List<int>.generate(8, (_) => Random.secure().nextInt(256));
    final hex = randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '$hex${DateTime.now().millisecondsSinceEpoch}';
  }
}
