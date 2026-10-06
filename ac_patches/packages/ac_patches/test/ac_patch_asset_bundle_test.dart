import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_patches/ac_patches.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcPatchAssetBundle Tests', () {
    late Directory tempActiveDir;

    setUp(() {
      tempActiveDir = Directory.systemTemp.createTempSync('ac_patch_bundle_test_');
    });

    tearDown(() {
      if (tempActiveDir.existsSync()) {
        try {
          tempActiveDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('loads patched text asset from active directory', () async {
      final assetsDir = Directory('${tempActiveDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}config')
        ..createSync(recursive: true);
      final jsonFile = File('${assetsDir.path}${Platform.pathSeparator}remote_config.json');
      await jsonFile.writeAsString('{"feature_flag": true, "version": "2.0.0"}');

      final bundle = AcPatchAssetBundle(activePatchesDir: tempActiveDir);
      final content = await bundle.loadString('config/remote_config.json');

      expect(content, equals('{"feature_flag": true, "version": "2.0.0"}'));
    });

    test('loads patched binary asset from active directory', () async {
      final assetsDir = Directory('${tempActiveDir.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images')
        ..createSync(recursive: true);
      final binFile = File('${assetsDir.path}${Platform.pathSeparator}icon.bin');
      await binFile.writeAsBytes([1, 2, 3, 4, 5]);

      final bundle = AcPatchAssetBundle(activePatchesDir: tempActiveDir);
      final byteData = await bundle.load('images/icon.bin');

      expect(byteData.lengthInBytes, equals(5));
      expect(byteData.getUint8(0), equals(1));
      expect(byteData.getUint8(4), equals(5));
    });
  });
}
