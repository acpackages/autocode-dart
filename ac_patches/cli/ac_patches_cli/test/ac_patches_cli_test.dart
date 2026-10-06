import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import 'package:ac_patches_cli/ac_patches_cli.dart';

void main() {
  group('AcPatchesProjectConfig Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ac_patches_cli_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Create and load ac_patches.yaml', () {
      final config = AcPatchesProjectConfig(
        appId: 'com.test.app',
        serverUrl: 'http://testserver:8080',
        track: 'beta',
        publicKey: 'pubKeyBase64Sample',
        privateKey: 'privKeyBase64Sample',
      );

      config.save(tempDir);
      final loaded = AcPatchesProjectConfig.load(tempDir);

      expect(loaded, isNotNull);
      expect(loaded!.appId, 'com.test.app');
      expect(loaded.serverUrl, 'http://testserver:8080');
      expect(loaded.track, 'beta');
      expect(loaded.publicKey, 'pubKeyBase64Sample');
      expect(loaded.privateKey, 'privKeyBase64Sample');
    });
  });

  group('HashUtils & NativeChangeDetector Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ac_native_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('HashUtils produces deterministic hashes', () {
      final file1 = File('${tempDir.path}/test.txt');
      file1.writeAsStringSync('Hello Antigravity');
      final hash1 = HashUtils.hashFile(file1);
      final hash2 = HashUtils.hashFile(file1);
      expect(hash1, startsWith('sha256:'));
      expect(hash1, equals(hash2));
    });

    test('NativeChangeDetector detects native source modifications', () {
      final windowsDir = Directory('${tempDir.path}/windows');
      windowsDir.createSync(recursive: true);
      final mainCpp = File('${windowsDir.path}/main.cpp');
      mainCpp.writeAsStringSync('int main() { return 0; }');

      NativeChangeDetector.recordReleaseSnapshot(
        projectDir: tempDir,
        releaseId: '1.0.0+1',
        platform: 'windows',
        baseReleaseHash: 'sha256:fakebasehash',
      );

      // Verify no changes initially
      var check = NativeChangeDetector.checkForChanges(
        projectDir: tempDir,
        releaseId: '1.0.0+1',
        platform: 'windows',
      );
      expect(check.hasChanges, isFalse);

      // Mutate native file
      mainCpp.writeAsStringSync('int main() { return 1; /* MODIFIED NATIVE CODE */ }');

      check = NativeChangeDetector.checkForChanges(
        projectDir: tempDir,
        releaseId: '1.0.0+1',
        platform: 'windows',
      );
      expect(check.hasChanges, isTrue);
      expect(check.message, contains('Native source code modifications detected'));
    });
  });

  group('CLI Packaging & Cryptographic Signing Integration', () {
    test('Generate keypair, sign payload, pack and unpack ACP1 archive', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();
      final privBytes = await keyPair.extractPrivateKeyBytes();

      final dummyAot = Uint8List.fromList(utf8.encode('AOT_ELF_BINARY_DATA'));
      final payloadHash = AcPatchCrypto.sha256Hex(dummyAot);
      final signature = await AcPatchCrypto.signBase64(data: dummyAot, keyPair: keyPair);

      final manifest = AcPatchManifest(
        appId: 'com.accountea.testapp',
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
        payloadHash: payloadHash,
        payloadSize: dummyAot.length,
        signature: signature,
      );

      final archiveBytes = await AcPatchArchive.pack(
        manifest: manifest,
        payload: dummyAot,
        keyPair: keyPair,
        compress: true,
      );
      expect(archiveBytes.length, greaterThan(0));

      final unpacked = AcPatchArchive.unpack(archiveBytes);
      expect(unpacked.manifest.patchId, '1.0.0+1-p1');

      // Verify cryptographic signature with public key
      final isValid = await unpacked.verifySignature(pubKey.bytes);
      expect(isValid, isTrue);
    });
  });
}
