import 'package:flutter/services.dart';

class AcPatchesAndroid {
  static const MethodChannel _channel = MethodChannel('ac_patches/android');

  /// Returns the canonical path of the currently active OTA patch, or null if running base release.
  static Future<String?> getActivePatchPath() async {
    return await _channel.invokeMethod<String>('getActivePatchPath');
  }

  /// Returns true if an OTA patch is actively installed in internal storage.
  static Future<bool> isPatchInstalled() async {
    return await _channel.invokeMethod<bool>('isPatchInstalled') ?? false;
  }

  /// Returns the internal app files directory path.
  static Future<String?> getFilesDir() async {
    return await _channel.invokeMethod<String>('getFilesDir');
  }
}
