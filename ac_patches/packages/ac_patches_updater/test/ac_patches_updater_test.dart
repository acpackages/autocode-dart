import 'dart:io';
import 'package:test/test.dart';
import 'package:ac_patches_updater/ac_patches_updater.dart';

void main() {
  group('AcPatchStorage Tests', () {
    late Directory tempDir;
    late AcPatchStorage storage;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ac_patch_storage_test_');
      storage = AcPatchStorage(baseDir: tempDir);
      await storage.initialize();
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Initializes directories and saves/loads state', () async {
      final state = storage.loadState();
      expect(state.activePatchId, isNull);
      expect(state.failureCount, equals(0));

      state.activePatchId = 'patch-1';
      state.activePatchNumber = 1;
      await storage.saveState(state);

      final reloaded = storage.loadState();
      expect(reloaded.activePatchId, equals('patch-1'));
      expect(reloaded.activePatchNumber, equals(1));
    });

    test('Promote pending patch to active', () async {
      final pendingFile = File('${storage.pendingDir.path}${Platform.pathSeparator}app.so');
      await pendingFile.writeAsString('PENDING_PAYLOAD_TEST');

      final state = storage.loadState();
      state.pendingPatchId = 'patch-2';
      state.pendingPatchNumber = 2;
      await storage.saveState(state);

      final success = await storage.promotePendingToActive('app.so');
      expect(success, isTrue);

      final activeFile = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      expect(activeFile.existsSync(), isTrue);
      expect(await activeFile.readAsString(), equals('PENDING_PAYLOAD_TEST'));

      final updatedState = storage.loadState();
      expect(updatedState.activePatchId, equals('patch-2'));
      expect(updatedState.pendingPatchId, isNull);
    });

    test('Rollback restores previous snapshot if available', () async {
      final activeFile = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      await activeFile.writeAsString('BROKEN_ACTIVE');

      final previousFile = File('${storage.previousDir.path}${Platform.pathSeparator}app.so');
      await previousFile.writeAsString('KNOWN_GOOD_PREVIOUS');

      final state = storage.loadState();
      state.activePatchId = 'patch-broken';
      state.knownGoodPatchId = 'patch-good';
      await storage.saveState(state);

      await storage.rollback('app.so');

      final activeAfterRollback = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      expect(activeAfterRollback.existsSync(), isTrue);
      expect(await activeAfterRollback.readAsString(), equals('KNOWN_GOOD_PREVIOUS'));

      final updatedState = storage.loadState();
      expect(updatedState.activePatchId, equals('patch-good'));
      expect(updatedState.failureCount, equals(0));
    });

    test('Rollback clears active if no previous snapshot exists', () async {
      final activeFile = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      await activeFile.writeAsString('BROKEN_ACTIVE');

      final state = storage.loadState();
      state.activePatchId = 'patch-1';
      state.knownGoodPatchId = null;
      await storage.saveState(state);

      await storage.rollback('app.so');

      final activeAfterRollback = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      expect(activeAfterRollback.existsSync(), isFalse);

      final updatedState = storage.loadState();
      expect(updatedState.activePatchId, isNull);
    });
  });

  group('AcPatches Crash Safety Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ac_patches_crash_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Automatic rollback triggered when failureCount >= maxFailuresThreshold', () async {
      final storage = AcPatchStorage(baseDir: tempDir);
      await storage.initialize();

      // Put an active patch and set failureCount to threshold (3)
      final activeFile = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      await activeFile.writeAsString('CRASHING_PATCH');

      final state = AcPatchState(
        activePatchId: 'patch-crash',
        activePatchNumber: 2,
        failureCount: 3,
        maxFailuresThreshold: 3,
      );
      await storage.saveState(state);

      // Initialize AcPatches -> should trigger automatic rollback
      await AcPatches.instance.initialize(
        serverUrl: 'http://localhost:8080',
        appId: 'com.accountea.test',
        releaseId: '1.0.0+1',
        buildNumber: 1,
        baseReleaseHash: 'sha256:1111',
        publicKeyBase64: 'mockKey',
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        patchesDirectory: tempDir,
        maxFailuresThreshold: 3,
      );

      expect(AcPatches.instance.status, equals(AcEnumClientPatchState.rolledBack));
      expect(AcPatches.instance.state.activePatchId, isNull);
      expect(activeFile.existsSync(), isFalse);
    });

    test('markHealthy resets failure counter to 0', () async {
      final storage = AcPatchStorage(baseDir: tempDir);
      await storage.initialize();

      final activeFile = File('${storage.activeDir.path}${Platform.pathSeparator}app.so');
      await activeFile.writeAsString('GOOD_PATCH');

      final state = AcPatchState(
        activePatchId: 'patch-good',
        activePatchNumber: 1,
        failureCount: 1,
        maxFailuresThreshold: 3,
      );
      await storage.saveState(state);

      await AcPatches.instance.initialize(
        serverUrl: 'http://localhost:8080',
        appId: 'com.accountea.test',
        releaseId: '1.0.0+1',
        buildNumber: 1,
        baseReleaseHash: 'sha256:1111',
        publicKeyBase64: 'mockKey',
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        patchesDirectory: tempDir,
      );

      // Startup increments failureCount
      expect(AcPatches.instance.state.failureCount, equals(2));

      // Healthy app startup confirms health
      await AcPatches.instance.markHealthy();

      expect(AcPatches.instance.status, equals(AcEnumClientPatchState.healthy));
      expect(AcPatches.instance.state.failureCount, equals(0));
      expect(AcPatches.instance.state.isHealthy, isTrue);
    });
  });
}
