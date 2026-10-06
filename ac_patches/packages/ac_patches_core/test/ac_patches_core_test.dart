import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ac_patches_core/ac_patches_core.dart';

void main() {
  group('AcPatchCrypto Tests', () {
    test('SHA256 calculation is deterministic and accurate', () {
      final data = utf8.encode('Hello AcPatches');
      final hash = AcPatchCrypto.sha256Hex(data);
      expect(hash.startsWith('sha256:'), isTrue);
      expect(hash, equals(AcPatchCrypto.sha256Hex(data)));
    });

    test('Ed25519 key generation, signing, and verification', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();
      final pubKeyBytes = pubKey.bytes;

      final message = utf8.encode('patch-payload-verification-test');
      final signature = await AcPatchCrypto.sign(data: message, keyPair: keyPair);

      expect(signature.length, equals(64));

      // 1. Valid signature verifies
      final isValid = await AcPatchCrypto.verify(
        data: message,
        signatureBytes: signature,
        publicKeyBytes: pubKeyBytes,
      );
      expect(isValid, isTrue);

      // 2. Tampered data fails
      final tamperedMessage = utf8.encode('patch-payload-verification-TEST');
      final isTamperedValid = await AcPatchCrypto.verify(
        data: tamperedMessage,
        signatureBytes: signature,
        publicKeyBytes: pubKeyBytes,
      );
      expect(isTamperedValid, isFalse);

      // 3. Tampered signature fails
      final tamperedSignature = Uint8List.fromList(signature);
      tamperedSignature[0] ^= 0xFF;
      final isBadSigValid = await AcPatchCrypto.verify(
        data: message,
        signatureBytes: tamperedSignature,
        publicKeyBytes: pubKeyBytes,
      );
      expect(isBadSigValid, isFalse);

      // 4. Wrong public key fails
      final otherKeyPair = await AcPatchCrypto.generateKeyPair();
      final otherPubKey = await otherKeyPair.extractPublicKey();
      final isWrongKeyValid = await AcPatchCrypto.verify(
        data: message,
        signatureBytes: signature,
        publicKeyBytes: otherPubKey.bytes,
      );
      expect(isWrongKeyValid, isFalse);
    });

    test('Base64 sign and verify workflow', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();
      final pubKeyBase64 = base64Encode(pubKey.bytes);

      final message = utf8.encode('Base64 test payload');
      final signatureBase64 = await AcPatchCrypto.signBase64(
        data: message,
        keyPair: keyPair,
      );

      final verified = await AcPatchCrypto.verifyBase64(
        data: message,
        signatureBase64: signatureBase64,
        publicKeyBase64: pubKeyBase64,
      );
      expect(verified, isTrue);
    });
  });

  group('AcPatchManifest Tests', () {
    test('JSON serialization roundtrip', () {
      final manifest = AcPatchManifest(
        appId: 'com.accountea.test',
        releaseId: '1.0.0+1',
        patchId: '1.0.0+1-p1',
        patchNumber: 1,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: '700aebeca4',
        baseBuildNumber: 1,
        baseReleaseHash: 'sha256:1111',
        payloadHash: 'sha256:2222',
        payloadSize: 1024,
        signature: 'mockSigBase64',
      );

      final json = manifest.toJson();
      final parsed = AcPatchManifest.fromJson(json);

      expect(parsed.appId, equals(manifest.appId));
      expect(parsed.releaseId, equals(manifest.releaseId));
      expect(parsed.patchNumber, equals(manifest.patchNumber));
      expect(parsed.platform, equals(AcEnumPatchPlatform.windows));
      expect(parsed.architecture, equals(AcEnumPatchArchitecture.x86_64));
      expect(parsed.signature, equals('mockSigBase64'));
    });
  });

  group('AcPatchCompatibilityChecker Tests', () {
    final baseRelease = AcPatchRelease(
      releaseId: '1.0.0+10',
      appId: 'com.accountea.test',
      version: '1.0.0',
      buildNumber: 10,
      platform: AcEnumPatchPlatform.windows,
      architecture: AcEnumPatchArchitecture.x86_64,
      flutterVersion: '3.44.4',
      dartVersion: '3.12.2',
      engineRevision: 'abc',
      baseReleaseHash: 'sha256:basehash123',
    );

    test('Valid manifest passes compatibility check', () {
      final manifest = AcPatchManifest(
        appId: 'com.accountea.test',
        releaseId: '1.0.0+10',
        patchId: '1.0.0+10-p1',
        patchNumber: 1,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: 'abc',
        baseBuildNumber: 10,
        baseReleaseHash: 'sha256:basehash123',
        payloadHash: 'sha256:patch123',
        payloadSize: 500,
      );

      final res = AcPatchCompatibilityChecker.validate(
        manifest: manifest,
        currentAppId: 'com.accountea.test',
        currentPlatform: AcEnumPatchPlatform.windows,
        currentArchitecture: AcEnumPatchArchitecture.x86_64,
        baseRelease: baseRelease,
      );

      expect(res.isCompatible, isTrue);
    });

    test('Platform mismatch is rejected', () {
      final manifest = AcPatchManifest(
        appId: 'com.accountea.test',
        releaseId: '1.0.0+10',
        patchId: '1.0.0+10-p1',
        patchNumber: 1,
        platform: AcEnumPatchPlatform.android,
        architecture: AcEnumPatchArchitecture.arm64_v8a,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: 'abc',
        baseBuildNumber: 10,
        baseReleaseHash: 'sha256:basehash123',
        payloadHash: 'sha256:patch123',
        payloadSize: 500,
      );

      final res = AcPatchCompatibilityChecker.validate(
        manifest: manifest,
        currentAppId: 'com.accountea.test',
        currentPlatform: AcEnumPatchPlatform.windows,
        currentArchitecture: AcEnumPatchArchitecture.x86_64,
        baseRelease: baseRelease,
      );

      expect(res.isCompatible, isFalse);
      expect(res.reason, contains('Platform mismatch'));
    });

    test('Downgrade attack is rejected', () {
      final manifest = AcPatchManifest(
        appId: 'com.accountea.test',
        releaseId: '1.0.0+10',
        patchId: '1.0.0+10-p2',
        patchNumber: 2,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: 'abc',
        baseBuildNumber: 10,
        baseReleaseHash: 'sha256:basehash123',
        payloadHash: 'sha256:patch123',
        payloadSize: 500,
      );

      final res = AcPatchCompatibilityChecker.validate(
        manifest: manifest,
        currentAppId: 'com.accountea.test',
        currentPlatform: AcEnumPatchPlatform.windows,
        currentArchitecture: AcEnumPatchArchitecture.x86_64,
        baseRelease: baseRelease,
        currentActivePatchNumber: 2, // Already at patch 2
      );

      expect(res.isCompatible, isFalse);
      expect(res.reason, contains('Downgrade rejected'));
    });
  });

  group('AcPatchRollout Tests', () {
    test('0% never selects, 100% always selects', () {
      expect(
        AcPatchRollout.isDeviceSelected(
          installationId: 'device-1',
          patchId: 'patch-1',
          rolloutPercentage: 0,
        ),
        isFalse,
      );

      expect(
        AcPatchRollout.isDeviceSelected(
          installationId: 'device-1',
          patchId: 'patch-1',
          rolloutPercentage: 100,
        ),
        isTrue,
      );
    });

    test('Assignment is deterministic for same device and patch', () {
      final res1 = AcPatchRollout.isDeviceSelected(
        installationId: 'device-xyz-123',
        patchId: 'patch-v1',
        rolloutPercentage: 25,
      );
      final res2 = AcPatchRollout.isDeviceSelected(
        installationId: 'device-xyz-123',
        patchId: 'patch-v1',
        rolloutPercentage: 25,
      );
      expect(res1, equals(res2));
    });
  });
}
