import 'dart:io';
import 'package:flutter/services.dart';

/// An asset bundle that loads patched assets from the active OTA patches directory
/// if present on disk, falling back to the base application assets otherwise.
class AcPatchAssetBundle extends PlatformAssetBundle {
  final Directory activePatchesDir;

  AcPatchAssetBundle({required this.activePatchesDir});

  @override
  Future<ByteData> load(String key) async {
    final cleanKey = key.startsWith('/') ? key.substring(1) : key;
    final patchFile = File('${activePatchesDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}$cleanKey');
    if (patchFile.existsSync()) {
      final bytes = await patchFile.readAsBytes();
      return ByteData.sublistView(bytes);
    }
    return super.load(key);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final cleanKey = key.startsWith('/') ? key.substring(1) : key;
    final patchFile = File('${activePatchesDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}$cleanKey');
    if (patchFile.existsSync()) {
      return await patchFile.readAsString();
    }
    return super.loadString(key, cache: cache);
  }
}
