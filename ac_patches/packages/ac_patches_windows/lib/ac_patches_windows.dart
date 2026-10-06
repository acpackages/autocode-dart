import 'package:flutter/services.dart';

class AcPatchesWindows {
  static const MethodChannel _channel = MethodChannel('ac_patches/windows');

  /// Returns the path to the currently active OTA patch, or null if running base release.
  static Future<String?> getActivePatchPath() async {
    return await _channel.invokeMethod<String>('getActivePatchPath');
  }

  /// Returns true if an active OTA patch exists in the executable's patches/active directory.
  static Future<bool> isPatchInstalled() async {
    return await _channel.invokeMethod<bool>('isPatchInstalled') ?? false;
  }
}
