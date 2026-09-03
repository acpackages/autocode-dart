/* AcDoc({
  "description": "Provides encryption and decryption utilities using AES-CBC with SHA-256 derived keys.",
  "author": "Sanket Patel",
  "type": "utility"
}) */
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AcEncryption {
  /* AcDoc({
    "description": "The default encryption key used if none is provided during encryption/decryption."
  }) */
  static String encryptionKey = "###RandomEncryptionKey###";

  /* AcDoc({
    "description": "The initialization vector (IV) used for AES encryption in CBC mode."
  }) */
  static final IV iv = IV.fromUtf8(
      List.generate(16, (i) => i).map((e) => String.fromCharCode(e)).join()
  );

  /* AcDoc({
    "description": "Encrypts the provided plain text using AES-CBC and returns a base64-encoded string.",
    "params": [
      { "name": "plainText", "description": "The input string to encrypt." },
      { "name": "encryptionKey", "description": "An optional encryption key to override the default key." }
    ],
    "returns": "A base64-encoded encrypted string."
  }) */
  static String encrypt({required String plainText, String? encryptionKey}) {
    final key = _deriveKey(encryptionKey ?? AcEncryption.encryptionKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  /* AcDoc({
    "description": "Decrypts the provided base64-encoded string using AES-CBC.",
    "params": [
      { "name": "encryptedText", "description": "The base64-encoded encrypted string." },
      { "name": "encryptionKey", "description": "An optional encryption key to override the default key." }
    ],
    "returns": "The original plain text string after decryption."
  }) */
  static String decrypt({required String encryptedText, String? encryptionKey}) {
    final key = _deriveKey(encryptionKey ?? AcEncryption.encryptionKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = Encrypted.from64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /* AcDoc({
    "description": "Generates a 32-byte AES key by applying SHA-256 on the provided key text.",
    "params": [
      { "name": "keyText", "description": "The input text to derive the encryption key from." }
    ],
    "returns": "A 256-bit AES key object."
  }) */
  static Key _deriveKey(String keyText) {
    final bytes = sha256.convert(utf8.encode(keyText)).bytes;
    return Key(Uint8List.fromList(bytes));
  }

  static String _base64UrlEncode(Uint8List bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Uint8List _base64UrlDecode(String input) {
    final padded = input.padRight((input.length + 3) ~/ 4 * 4, '=');
    return base64Url.decode(padded);
  }

  /* AcDoc({
    "description": "Generates a JWT (HS256) with the given payload, secret key, and optional expiration.",
    "params": [
      { "name": "data", "description": "The payload claims map." },
      { "name": "secret", "description": "The secret key for HMAC-SHA256 signature." },
      { "name": "expiresInSeconds", "description": "Optional token TTL in seconds." }
    ],
    "returns": "A signed JWT string."
  }) */
  static String generateToken({
    required Map<String, dynamic> data,
    required String secret,
    int? expiresInSeconds,
  }) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final headerEncoded = _base64UrlEncode(Uint8List.fromList(utf8.encode(jsonEncode(header))));

    final body = Map<String, dynamic>.from(data);
    if (expiresInSeconds != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      body['exp'] = now + expiresInSeconds;
    }
    final bodyEncoded = _base64UrlEncode(Uint8List.fromList(utf8.encode(jsonEncode(body))));

    final signingInput = '$headerEncoded.$bodyEncoded';
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(signingInput));
    final signatureEncoded = _base64UrlEncode(Uint8List.fromList(digest.bytes));

    return '$signingInput.$signatureEncoded';
  }

  /* AcDoc({
    "description": "Verifies a JWT (HS256) string against the provided secret. Validates signature, exp, and nbf claims.",
    "params": [
      { "name": "token", "description": "The JWT string to verify." },
      { "name": "secret", "description": "The HMAC-SHA256 secret key." }
    ],
    "returns": "The decoded claims map on success, or null on failure."
  }) */
  static Map<String, dynamic>? verifyToken({
    required String token,
    required String secret,
  }) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final signingInput = '${parts[0]}.${parts[1]}';
      final hmac = Hmac(sha256, utf8.encode(secret));
      final digest = hmac.convert(utf8.encode(signingInput));
      final expectedSignature = _base64UrlEncode(Uint8List.fromList(digest.bytes));

      if (expectedSignature != parts[2]) return null;

      final payloadJson = utf8.decode(_base64UrlDecode(parts[1]));
      final claims = jsonDecode(payloadJson) as Map<String, dynamic>;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (claims.containsKey('exp') && (claims['exp'] as int) < now) return null;
      if (claims.containsKey('nbf') && (claims['nbf'] as int) > now) return null;

      return claims;
    } catch (_) {
      return null;
    }
  }
}

