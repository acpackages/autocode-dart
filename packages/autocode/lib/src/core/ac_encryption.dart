import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class AcEncryption {
  static String encryptionKey = "###RandomEncryptionKey###";
  static final IV iv = IV.fromUtf8(List.generate(16, (i) => i).map((e) => String.fromCharCode(e)).join());

  static String encrypt({required String plainText, String? customKey}) {
    final key = _deriveKey(customKey ?? encryptionKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decrypt({required String encryptedText, String? customKey}) {
    final key = _deriveKey(customKey ?? encryptionKey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = Encrypted.from64(encryptedText);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  static Key _deriveKey(String keyText) {
    final bytes = sha256.convert(utf8.encode(keyText)).bytes;
    return Key(Uint8List.fromList(bytes));
  }
}
