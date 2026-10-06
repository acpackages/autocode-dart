import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';

void main() {
  group('ACP1 Format Archive Tests', () {
    late AcPatchManifest sampleManifest;
    late Uint8List samplePayload;

    setUp(() {
      sampleManifest = AcPatchManifest(
        appId: 'com.accountea.test',
        releaseId: '1.0.0+10',
        patchId: '1.0.0+10-p1',
        patchNumber: 1,
        platform: AcEnumPatchPlatform.windows,
        architecture: AcEnumPatchArchitecture.x86_64,
        flutterVersion: '3.44.4',
        dartVersion: '3.12.2',
        engineRevision: 'abc1234',
        baseBuildNumber: 10,
        baseReleaseHash: 'sha256:base123',
        payloadHash: '',
        payloadSize: 0,
      );
      samplePayload = Uint8List.fromList(utf8.encode('AOT_SNAPSHOT_PAYLOAD_TEST_DATA'));
    });

    test('Pack and unpack roundtrip (uncompressed) with valid signature', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();

      final archiveBytes = await AcPatchArchive.pack(
        manifest: sampleManifest,
        payload: samplePayload,
        keyPair: keyPair,
        compress: false,
      );

      expect(archiveBytes.length, greaterThan(samplePayload.length));

      final package = AcPatchArchive.unpack(archiveBytes);
      expect(package.manifest.appId, equals('com.accountea.test'));
      expect(package.manifest.patchId, equals('1.0.0+10-p1'));
      expect(package.payload, equals(samplePayload));
      expect(package.compression, equals(AcPatchArchive.compressionNone));

      final isSigValid = await package.verifySignature(pubKey.bytes);
      expect(isSigValid, isTrue);
    });

    test('Pack and unpack roundtrip (gzip compressed)', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();

      final archiveBytes = await AcPatchArchive.pack(
        manifest: sampleManifest,
        payload: samplePayload,
        keyPair: keyPair,
        compress: true,
      );

      final package = AcPatchArchive.unpack(archiveBytes);
      expect(package.compression, equals(AcPatchArchive.compressionGzip));
      expect(package.payload, equals(samplePayload));

      final isSigValid = await package.verifySignature(pubKey.bytes);
      expect(isSigValid, isTrue);
    });

    test('Invalid magic bytes rejected', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final archiveBytes = await AcPatchArchive.pack(
        manifest: sampleManifest,
        payload: samplePayload,
        keyPair: keyPair,
      );

      // Corrupt magic bytes
      archiveBytes[0] = 0x58; // 'X'
      expect(
        () => AcPatchArchive.unpack(archiveBytes),
        throwsA(isA<AcPatchFormatException>()),
      );
    });

    test('Truncated archive rejected', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final archiveBytes = await AcPatchArchive.pack(
        manifest: sampleManifest,
        payload: samplePayload,
        keyPair: keyPair,
      );

      // Truncate to half size
      final truncated = archiveBytes.sublist(0, archiveBytes.length ~/ 2);
      expect(
        () => AcPatchArchive.unpack(truncated),
        throwsA(isA<AcPatchFormatException>()),
      );
    });

    test('Corrupted payload fails signature verification', () async {
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();

      final archiveBytes = await AcPatchArchive.pack(
        manifest: sampleManifest,
        payload: samplePayload,
        keyPair: keyPair,
      );

      // Corrupt 1 byte in payload (at the very end)
      archiveBytes[archiveBytes.length - 1] ^= 0xFF;

      final package = AcPatchArchive.unpack(archiveBytes);
      final isSigValid = await package.verifySignature(pubKey.bytes);
      expect(isSigValid, isFalse);
    });
  });
}
