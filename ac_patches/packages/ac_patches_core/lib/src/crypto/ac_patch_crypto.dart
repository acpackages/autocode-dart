import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

class AcPatchCrypto {
  static final Ed25519 _ed25519 = Ed25519();

  /// Calculates the SHA-256 hash of the given bytes and returns it as a hex string with "sha256:" prefix.
  static String sha256Hex(List<int> bytes) {
    final digest = crypto.sha256.convert(bytes);
    return 'sha256:$digest';
  }

  /// Calculates the raw 32-byte SHA-256 hash of the given bytes.
  static Uint8List sha256Bytes(List<int> bytes) {
    final digest = crypto.sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  /// Generates a new random Ed25519 SimpleKeyPair.
  static Future<SimpleKeyPair> generateKeyPair() async {
    return await _ed25519.newKeyPair();
  }

  /// Creates a SimpleKeyPair from a 32-byte private seed.
  static Future<SimpleKeyPair> keyPairFromSeed(List<int> privateKeyBytes) async {
    return await _ed25519.newKeyPairFromSeed(privateKeyBytes);
  }

  /// Signs the specified [data] using Ed25519 and returns the 64-byte signature.
  static Future<Uint8List> sign({
    required List<int> data,
    required SimpleKeyPair keyPair,
  }) async {
    final signature = await _ed25519.sign(data, keyPair: keyPair);
    return Uint8List.fromList(signature.bytes);
  }

  /// Signs the specified [data] and returns a Base64-encoded signature string.
  static Future<String> signBase64({
    required List<int> data,
    required SimpleKeyPair keyPair,
  }) async {
    final sigBytes = await sign(data: data, keyPair: keyPair);
    return base64Encode(sigBytes);
  }

  /// Verifies an Ed25519 signature against [publicKeyBytes] (32 bytes).
  static Future<bool> verify({
    required List<int> data,
    required List<int> signatureBytes,
    required List<int> publicKeyBytes,
  }) async {
    try {
      final pubKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519);
      final signature = Signature(signatureBytes, publicKey: pubKey);
      return await _ed25519.verify(data, signature: signature);
    } catch (_) {
      return false;
    }
  }

  /// Verifies an Ed25519 Base64-encoded signature against a Base64-encoded public key.
  static Future<bool> verifyBase64({
    required List<int> data,
    required String signatureBase64,
    required String publicKeyBase64,
  }) async {
    try {
      final sigBytes = base64Decode(signatureBase64.trim());
      final pubKeyBytes = base64Decode(publicKeyBase64.trim());
      return await verify(
        data: data,
        signatureBytes: sigBytes,
        publicKeyBytes: pubKeyBytes,
      );
    } catch (_) {
      return false;
    }
  }
}
