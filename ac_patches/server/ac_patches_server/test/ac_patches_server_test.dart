import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import 'package:ac_patches_server/ac_patches_server.dart';

void main() {
  group('AcPatchesServer Integration Tests', () {
    late Directory tempDir;
    late AcPatchesServerApp serverApp;
    final testPort = 9191;
    final baseUrl = 'http://localhost:$testPort';

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('ac_patches_server_test_');
      final dbPath = '${tempDir.path}${Platform.pathSeparator}test.db';
      final storageDir = Directory('${tempDir.path}${Platform.pathSeparator}storage');

      serverApp = AcPatchesServerApp(
        port: testPort,
        dbPath: dbPath,
        storageDir: storageDir,
        dataDictionaryName: 'ac_patches_test_${DateTime.now().millisecondsSinceEpoch}',
      );

      await serverApp.initialize();
      await serverApp.start();
    });

    tearDownAll(() async {
      await serverApp.stop();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Upload, publish, check, download, report, and rollback lifecycle', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();

      final manifest = AcPatchManifest(
        appId: 'com.accountea.servertest',
        releaseId: '1.0.0+1',
        patchId: '1.0.0+1-p1',
        patchNumber: 1,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: 'abc123',
        baseBuildNumber: 1,
        baseReleaseHash: 'sha256:basehash',
        payloadHash: '',
        payloadSize: 0,
      );

      final payload = Uint8List.fromList(utf8.encode('AOT_PATCH_PAYLOAD_INTEGRATION_TEST'));
      final archiveBytes = await AcPatchArchive.pack(
        manifest: manifest,
        payload: payload,
        keyPair: keyPair,
      );

      // 1. Upload patch package: POST /api/v1/patch/upload
      final uploadRes = await http.post(
        Uri.parse('$baseUrl/api/v1/patch/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bytesBase64': base64Encode(archiveBytes)}),
      );
      expect(uploadRes.statusCode, equals(200));
      final uploadJson = jsonDecode(uploadRes.body) as Map<String, dynamic>;
      expect(uploadJson['success'], isTrue);
      expect(uploadJson['patchId'], equals('1.0.0+1-p1'));

      // 2. Publish patch: POST /api/v1/patch/publish
      final publishRes = await http.post(
        Uri.parse('$baseUrl/api/v1/patch/publish'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patchId': '1.0.0+1-p1',
          'track': 'stable',
          'rolloutPercentage': 100,
        }),
      );
      expect(publishRes.statusCode, equals(200));
      final publishJson = jsonDecode(publishRes.body) as Map<String, dynamic>;
      expect(publishJson['success'], isTrue);

      // 3. Check for update: POST /api/v1/patch/check
      final checkReq = AcPatchCheckRequest(
        appId: 'com.accountea.servertest',
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        releaseId: '1.0.0+1',
        buildNumber: 1,
        currentPatchId: null,
        currentPatchNumber: 0,
        track: AcEnumPatchTrack.stable,
        installationId: 'test_device_001',
      );

      final checkRes = await http.post(
        Uri.parse('$baseUrl/api/v1/patch/check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(checkReq.toJson()),
      );
      expect(checkRes.statusCode, equals(200));
      final checkResponse = AcPatchCheckResponse.fromJson(jsonDecode(checkRes.body) as Map<String, dynamic>);
      expect(checkResponse.available, isTrue);
      expect(checkResponse.patchId, equals('1.0.0+1-p1'));
      expect(checkResponse.downloadUrl, isNotNull);

      // 4. Download patch package: GET /api/v1/patch/download/{patchId}
      final downloadRes = await http.get(Uri.parse('$baseUrl${checkResponse.downloadUrl}'));
      expect(downloadRes.statusCode, equals(200));

      final downloadedPackage = AcPatchArchive.unpack(downloadRes.bodyBytes);
      expect(downloadedPackage.manifest.patchId, equals('1.0.0+1-p1'));
      expect(downloadedPackage.payload, equals(payload));
      expect(await downloadedPackage.verifySignature(pubKey.bytes), isTrue);

      // 5. Report telemetry event: POST /api/v1/patch/report
      final reportRes = await http.post(
        Uri.parse('$baseUrl/api/v1/patch/report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          AcPatchReportRequest(
            installationId: 'test_device_001',
            appId: 'com.accountea.servertest',
            patchId: '1.0.0+1-p1',
            releaseId: '1.0.0+1',
            eventType: 'healthy',
          ).toJson(),
        ),
      );
      expect(reportRes.statusCode, equals(200));
      final reportJson = jsonDecode(reportRes.body) as Map<String, dynamic>;
      expect(reportJson['success'], isTrue);

      // 6. Rollback patch: POST /api/v1/patch/rollback
      final rollbackRes = await http.post(
        Uri.parse('$baseUrl/api/v1/patch/rollback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': 'com.accountea.servertest',
          'track': 'stable',
          'targetPatchId': null,
        }),
      );
      expect(rollbackRes.statusCode, equals(200));

      // 7. Check again -> should now report available == false
      final checkAfterRollbackRes = await http.post(
        Uri.parse('$baseUrl/api/v1/patch/check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(checkReq.toJson()),
      );
      final checkAfterRollback = AcPatchCheckResponse.fromJson(
        jsonDecode(checkAfterRollbackRes.body) as Map<String, dynamic>,
      );
      expect(checkAfterRollback.available, isFalse);
    });
  });
}
