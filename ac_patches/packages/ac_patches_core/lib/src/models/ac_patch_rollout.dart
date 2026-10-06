import 'dart:convert';
import 'package:crypto/crypto.dart';

class AcPatchRollout {
  /// Deterministically calculates whether a device with [installationId] qualifies
  /// for a rollout with [rolloutPercentage] (0 - 100) for [patchId].
  static bool isDeviceSelected({
    required String installationId,
    required String patchId,
    required int rolloutPercentage,
  }) {
    if (rolloutPercentage <= 0) return false;
    if (rolloutPercentage >= 100) return true;

    final key = '$installationId:$patchId';
    final hash = sha256.convert(utf8.encode(key)).bytes;
    // Use first 4 bytes as big-endian unsigned integer
    final value = (hash[0] << 24) | (hash[1] << 16) | (hash[2] << 8) | hash[3];
    final bucket = (value.abs() % 100);
    return bucket < rolloutPercentage;
  }
}
