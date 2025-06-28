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
}
