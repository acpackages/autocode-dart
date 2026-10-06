import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_patches_updater/src/ac_patch_storage.dart';

void main() {
  group('AcPatchStorage Asset Lifecycle Tests', () {
    late Directory tempBaseDir;
    late AcPatchStorage storage;

    setUp(() async {
      tempBaseDir = Directory.systemTemp.createTempSync('ac_storage_asset_test_');
      storage = AcPatchStorage(baseDir: tempBaseDir);
      await storage.initialize();
    });

    tearDown(() async {
      if (tempBaseDir.existsSync()) {
        try {
          tempBaseDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('promotes pending assets to active assets and archives previous', () async {
      // 1. Stage pending assets
      final pendingAssets = storage.pendingAssetsDir;
      await pendingAssets.create(recursive: true);
      final testFile = File('${pendingAssets.path}${Platform.pathSeparator}test.json');
      await testFile.writeAsString('{"version": 1}');

      // 2. Promote
      final promoted = await storage.promotePendingToActive('app.so');
      expect(promoted, isTrue);

      final activeAssets = storage.activeAssetsDir;
      expect(activeAssets.existsSync(), isTrue);
      final activeFile = File('${activeAssets.path}${Platform.pathSeparator}test.json');
      expect(activeFile.existsSync(), isTrue);
      expect(activeFile.readAsStringSync(), equals('{"version": 1}'));
      expect(pendingAssets.existsSync(), isFalse);

      // 3. Stage a newer pending asset
      await pendingAssets.create(recursive: true);
      final testFile2 = File('${pendingAssets.path}${Platform.pathSeparator}test.json');
      await testFile2.writeAsString('{"version": 2}');

      final promoted2 = await storage.promotePendingToActive('app.so');
      expect(promoted2, isTrue);

      // Active is now version 2
      expect(activeFile.readAsStringSync(), equals('{"version": 2}'));

      // Previous is now version 1
      final previousFile = File('${storage.previousAssetsDir.path}${Platform.pathSeparator}test.json');
      expect(previousFile.existsSync(), isTrue);
      expect(previousFile.readAsStringSync(), equals('{"version": 1}'));
    });

    test('rollback restores previous assets if available', () async {
      // Create previous assets
      await storage.previousAssetsDir.create(recursive: true);
      final prevFile = File('${storage.previousAssetsDir.path}${Platform.pathSeparator}asset.txt');
      await prevFile.writeAsString('PREVIOUS_ASSET');

      // Create broken active assets
      await storage.activeAssetsDir.create(recursive: true);
      final actFile = File('${storage.activeAssetsDir.path}${Platform.pathSeparator}asset.txt');
      await actFile.writeAsString('BROKEN_ACTIVE');

      // Rollback
      await storage.rollback('app.so');

      // Active should now be PREVIOUS_ASSET
      expect(actFile.existsSync(), isTrue);
      expect(actFile.readAsStringSync(), equals('PREVIOUS_ASSET'));
    });
  });
}
