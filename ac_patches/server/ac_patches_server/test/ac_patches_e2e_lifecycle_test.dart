import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:cryptography/cryptography.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import 'package:ac_patches_updater/ac_patches_updater.dart';
import 'package:ac_patches_server/ac_patches_server.dart';

void main() {
  group('ac_patches End-to-End Complete Production Journey', () {
    late Directory tempDir;
    late Directory clientPatchesDir;
    late AcPatchesServerApp serverApp;
    final serverPort = 9292;
    final serverUrl = 'http://localhost:$serverPort';

    late SimpleKeyPair keyPair;
    late SimplePublicKey pubKey;
    late String pubKeyBase64;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('ac_e2e_journey_');
      clientPatchesDir = Directory('${tempDir.path}${Platform.pathSeparator}client_patches');
      clientPatchesDir.createSync(recursive: true);

      final dbPath = '${tempDir.path}${Platform.pathSeparator}e2e_server.db';
      final storageDir = Directory('${tempDir.path}${Platform.pathSeparator}storage');

      // 1. Start Server
      serverApp = AcPatchesServerApp(
        port: serverPort,
        dbPath: dbPath,
        storageDir: storageDir,
        dataDictionaryName: 'ac_patches_e2e_${DateTime.now().millisecondsSinceEpoch}',
      );
      await serverApp.initialize();
      await serverApp.start();

      // 2. Generate Ed25519 signing keys
      keyPair = await AcPatchCrypto.generateKeyPair();
      pubKey = await keyPair.extractPublicKey();
      pubKeyBase64 = base64Encode(pubKey.bytes);
    });

    tearDownAll(() async {
      await serverApp.stop();
      if (tempDir.existsSync()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }
    });

    test('Full End-to-End OTA Lifecycle: Release -> Patch -> Download -> Cryptographic Verify -> Activate -> Health -> Crash Rollback -> Server Rollback', () async {
      const appId = 'com.accountea.productionapp';
      const releaseId = '1.0.0+100';
      const baseBuildNumber = 100;
      const baseReleaseHash = 'sha256:0123456789abcdef0123456789abcdef';

      // 1. Register Base Release on Server
      final regResp = await http.post(
        Uri.parse('$serverUrl/api/v1/release/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'releaseId': releaseId,
          'appId': appId,
          'version': '1.0.0',
          'buildNumber': baseBuildNumber,
          'platform': 'windows',
          'baseReleaseHash': baseReleaseHash,
        }),
      );
      expect(regResp.statusCode, inInclusiveRange(200, 299));

      // 2. Initialize Client Updater
      await AcPatches.instance.initialize(
        serverUrl: serverUrl,
        appId: appId,
        releaseId: releaseId,
        buildNumber: baseBuildNumber,
        baseReleaseHash: baseReleaseHash,
        publicKeyBase64: pubKeyBase64,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        patchesDirectory: clientPatchesDir,
        installationId: 'device_e2e_prod_001',
      );

      // 3. Client checks for update before any patch exists
      var hasUpdate = await AcPatches.instance.checkForUpdate();
      expect(hasUpdate, isFalse);
      expect(AcPatches.instance.status, equals(AcEnumClientPatchState.none));

      // 4. Build, Sign, Pack and Upload Patch 1
      const patchId = '1.0.0+100-p1';
      final aotPayload = Uint8List.fromList([
        0x7F, 0x45, 0x4C, 0x46, // ELF magic
        0x02, 0x01, 0x01, 0x00,
        ...utf8.encode('VERSION_2_DART_AOT_PATCH_CODE'),
      ]);
      final payloadHash = AcPatchCrypto.sha256Hex(aotPayload);
      final signature = await AcPatchCrypto.signBase64(data: aotPayload, keyPair: keyPair);

      final manifest = AcPatchManifest(
        appId: appId,
        releaseId: releaseId,
        patchId: patchId,
        patchNumber: 1,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: 'a10d8ac38de835021c8d2f920dbf50a920ccc030',
        baseBuildNumber: baseBuildNumber,
        baseReleaseHash: baseReleaseHash,
        payloadHash: payloadHash,
        payloadSize: aotPayload.length,
        signature: signature,
      );

      final archiveBytes = await AcPatchArchive.pack(
        manifest: manifest,
        payload: aotPayload,
        keyPair: keyPair,
        compress: true,
      );

      // Upload archive to server
      final uploadResp = await http.post(
        Uri.parse('$serverUrl/api/v1/patch/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bytesBase64': base64Encode(archiveBytes)}),
      );
      expect(uploadResp.statusCode, equals(200));

      // 5. Publish Patch to 'stable' track at 100% rollout
      final publishResp = await http.post(
        Uri.parse('$serverUrl/api/v1/patch/publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patchId': patchId,
          'track': 'stable',
          'rolloutPercentage': 100,
        }),
      );
      expect(publishResp.statusCode, equals(200));

      // 6. Client checks for update -> now available!
      hasUpdate = await AcPatches.instance.checkForUpdate();
      expect(hasUpdate, isTrue);
      expect(AcPatches.instance.status, equals(AcEnumClientPatchState.available));
      expect(AcPatches.instance.availableUpdate?.patchId, equals(patchId));

      // 7. Client downloads and cryptographically verifies patch
      final downloadSuccess = await AcPatches.instance.downloadUpdate();
      expect(downloadSuccess, isTrue);

      final pendingFile = File('${clientPatchesDir.path}/pending/app.so');
      expect(pendingFile.existsSync(), isTrue);
      expect(pendingFile.readAsBytesSync(), equals(aotPayload));

      // 8. Client restarts & activates pending patch
      final activated = await AcPatches.instance.activateOnRestart();
      expect(activated, isTrue);

      final activeFile = File('${clientPatchesDir.path}/active/app.so');
      expect(activeFile.existsSync(), isTrue);
      expect(activeFile.readAsBytesSync(), equals(aotPayload));

      // 9. Confirm healthy application launch
      await AcPatches.instance.markHealthy();
      expect(AcPatches.instance.state.isHealthy, isTrue);
      expect(AcPatches.instance.state.failureCount, equals(0));

      // 10. Induce crash threshold failure & verify automatic rollback
      final storage = AcPatchStorage(baseDir: clientPatchesDir);
      final crashState = storage.loadState();
      crashState.failureCount = 3;
      await storage.saveState(crashState);

      // Re-initialize client runtime (simulates app boot after 3 crashes)
      await AcPatches.instance.initialize(
        serverUrl: serverUrl,
        appId: appId,
        releaseId: releaseId,
        buildNumber: baseBuildNumber,
        baseReleaseHash: baseReleaseHash,
        publicKeyBase64: pubKeyBase64,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        patchesDirectory: clientPatchesDir,
        installationId: 'device_e2e_prod_001',
        maxFailuresThreshold: 3,
      );

      // Active patch must have been purged and rolled back to base release!
      expect(activeFile.existsSync(), isFalse);
      expect(AcPatches.instance.state.activePatchId, isNull);

      // 11. Server-side Track Rollback
      final rollbackResp = await http.post(
        Uri.parse('$serverUrl/api/v1/patch/rollback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': appId,
          'track': 'stable',
        }),
      );
      expect(rollbackResp.statusCode, equals(200));

      // Client checks for update again -> server track is rolled back, no update!
      final checkAfterRollback = await AcPatches.instance.checkForUpdate();
      expect(checkAfterRollback, isFalse);

      print('🎉 COMPLETE SUCCESS: All 11 steps of the OTA Production Journey PASSED!');
    });
  });
}
