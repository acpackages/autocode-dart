import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:cryptography/cryptography.dart';

class AcPatchFormatException implements Exception {
  final String message;
  AcPatchFormatException(this.message);

  @override
  String toString() => 'AcPatchFormatException: $message';
}

class AcPatchPackage {
  final AcPatchManifest manifest;
  final Uint8List payload;
  final Uint8List signatureBytes;
  final int compression;

  AcPatchPackage({
    required this.manifest,
    required this.payload,
    required this.signatureBytes,
    required this.compression,
  });

  /// Verifies the embedded signature against the provided [publicKeyBytes] (32 bytes Ed25519).
  Future<bool> verifySignature(List<int> publicKeyBytes) async {
    // 1. Verify that payload hash in manifest matches actual payload hash
    final actualPayloadHash = AcPatchCrypto.sha256Hex(payload);
    if (manifest.payloadHash != actualPayloadHash) {
      return false;
    }

    // 2. Verify Ed25519 signature on the manifest's signable bytes
    final signableBytes = manifest.toSignableBytes();
    return await AcPatchCrypto.verify(
      data: signableBytes,
      signatureBytes: signatureBytes,
      publicKeyBytes: publicKeyBytes,
    );
  }
}

class AcPatchArchive {
  static const List<int> magicBytes = [0x41, 0x43, 0x50, 0x31]; // 'ACP1'
  static const int currentFormatVersion = 1;
  static const int compressionNone = 0;
  static const int compressionGzip = 1;

  /// Packs a manifest and payload into an ACP1 binary archive, signing it with [keyPair].
  static Future<Uint8List> pack({
    required AcPatchManifest manifest,
    required List<int> payload,
    required SimpleKeyPair keyPair,
    bool compress = false,
  }) async {
    // 1. Prepare payload (optionally gzip compressed)
    final compression = compress ? compressionGzip : compressionNone;
    final finalPayload = compress ? gzip.encode(payload) : payload;

    // 2. Compute payload SHA-256 and update manifest (hash of uncompressed payload)
    final payloadHash = AcPatchCrypto.sha256Hex(payload);
    final updatedManifest = AcPatchManifest(
      formatVersion: currentFormatVersion,
      appId: manifest.appId,
      releaseId: manifest.releaseId,
      patchId: manifest.patchId,
      patchNumber: manifest.patchNumber,
      patchType: manifest.patchType,
      platform: manifest.platform,
      architecture: manifest.architecture,
      flutterVersion: manifest.flutterVersion,
      dartVersion: manifest.dartVersion,
      engineRevision: manifest.engineRevision,
      baseBuildNumber: manifest.baseBuildNumber,
      baseReleaseHash: manifest.baseReleaseHash,
      payloadHash: payloadHash,
      payloadSize: payload.length,
      createdAt: manifest.createdAt,
      minRuntimeVersion: manifest.minRuntimeVersion,
      maxRuntimeVersion: manifest.maxRuntimeVersion,
      mandatory: manifest.mandatory,
    );

    // 3. Sign manifest signable bytes with Ed25519
    final signableBytes = updatedManifest.toSignableBytes();
    final signatureBytes = await AcPatchCrypto.sign(
      data: signableBytes,
      keyPair: keyPair,
    );
    updatedManifest.signature = base64Encode(signatureBytes);

    // 4. Encode manifest JSON
    final manifestBytes = utf8.encode(jsonEncode(updatedManifest.toJson()));

    // 5. Build binary envelope
    // Header layout:
    // Magic: 4 bytes
    // Format Version: 2 bytes (uint16 big-endian)
    // Compression: 2 bytes (uint16 big-endian)
    // Manifest Length: 4 bytes (uint32 big-endian)
    // Manifest Bytes: [manifestLength]
    // Signature Length: 2 bytes (uint16 big-endian)
    // Signature Bytes: [signatureLength]
    // Payload Length: 8 bytes (uint64 big-endian)
    // Payload Bytes: [payloadLength]
    final headerSize = 4 + 2 + 2 + 4 + manifestBytes.length + 2 + signatureBytes.length + 8;
    final totalSize = headerSize + finalPayload.length;
    final buffer = Uint8List(totalSize);
    final byteData = ByteData.sublistView(buffer);

    var offset = 0;
    // Magic
    buffer.setRange(offset, offset + 4, magicBytes);
    offset += 4;

    // Format Version
    byteData.setUint16(offset, currentFormatVersion, Endian.big);
    offset += 2;

    // Compression
    byteData.setUint16(offset, compression, Endian.big);
    offset += 2;

    // Manifest Length
    byteData.setUint32(offset, manifestBytes.length, Endian.big);
    offset += 4;

    // Manifest Bytes
    buffer.setRange(offset, offset + manifestBytes.length, manifestBytes);
    offset += manifestBytes.length;

    // Signature Length
    byteData.setUint16(offset, signatureBytes.length, Endian.big);
    offset += 2;

    // Signature Bytes
    buffer.setRange(offset, offset + signatureBytes.length, signatureBytes);
    offset += signatureBytes.length;

    // Payload Length
    byteData.setUint64(offset, finalPayload.length, Endian.big);
    offset += 8;

    // Payload Bytes
    buffer.setRange(offset, offset + finalPayload.length, finalPayload);

    return buffer;
  }

  /// Unpacks an ACP1 binary archive into an [AcPatchPackage].
  static AcPatchPackage unpack(List<int> archiveBytes) {
    if (archiveBytes.length < 24) {
      throw AcPatchFormatException('Archive is too short to contain a valid ACP1 header');
    }

    final uint8List = archiveBytes is Uint8List ? archiveBytes : Uint8List.fromList(archiveBytes);
    final byteData = ByteData.sublistView(uint8List);

    var offset = 0;

    // 1. Verify Magic Bytes
    for (var i = 0; i < 4; i++) {
      if (uint8List[offset + i] != magicBytes[i]) {
        throw AcPatchFormatException('Invalid magic bytes in patch header (expected ACP1)');
      }
    }
    offset += 4;

    // 2. Format Version
    final formatVersion = byteData.getUint16(offset, Endian.big);
    offset += 2;
    if (formatVersion != currentFormatVersion) {
      throw AcPatchFormatException('Unsupported ACP version: $formatVersion (current is $currentFormatVersion)');
    }

    // 3. Compression
    final compression = byteData.getUint16(offset, Endian.big);
    offset += 2;

    // 4. Manifest Length & Manifest
    final manifestLength = byteData.getUint32(offset, Endian.big);
    offset += 4;
    if (offset + manifestLength > uint8List.length) {
      throw AcPatchFormatException('Archive truncated while reading manifest');
    }
    final manifestBytes = uint8List.sublist(offset, offset + manifestLength);
    offset += manifestLength;

    final manifestMap = jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
    final manifest = AcPatchManifest.fromJson(manifestMap);

    // 5. Signature Length & Signature
    if (offset + 2 > uint8List.length) {
      throw AcPatchFormatException('Archive truncated while reading signature header');
    }
    final signatureLength = byteData.getUint16(offset, Endian.big);
    offset += 2;
    if (offset + signatureLength > uint8List.length) {
      throw AcPatchFormatException('Archive truncated while reading signature');
    }
    final signatureBytes = uint8List.sublist(offset, offset + signatureLength);
    offset += signatureLength;

    // 6. Payload Length & Payload
    if (offset + 8 > uint8List.length) {
      throw AcPatchFormatException('Archive truncated while reading payload header');
    }
    final payloadLength = byteData.getUint64(offset, Endian.big);
    offset += 8;
    if (offset + payloadLength > uint8List.length) {
      throw AcPatchFormatException(
        'Archive truncated: expected $payloadLength payload bytes, got ${uint8List.length - offset}',
      );
    }
    final rawPayload = uint8List.sublist(offset, offset + payloadLength);

    // 7. Decompress if needed
    final Uint8List payload;
    if (compression == compressionGzip) {
      payload = Uint8List.fromList(gzip.decode(rawPayload));
    } else {
      payload = rawPayload;
    }

    return AcPatchPackage(
      manifest: manifest,
      payload: payload,
      signatureBytes: signatureBytes,
      compression: compression,
    );
  }

  /// Writes packed archive to a file.
  static Future<void> packToFile({
    required File targetFile,
    required AcPatchManifest manifest,
    required List<int> payload,
    required SimpleKeyPair keyPair,
    bool compress = false,
  }) async {
    final bytes = await pack(
      manifest: manifest,
      payload: payload,
      keyPair: keyPair,
      compress: compress,
    );
    await targetFile.writeAsBytes(bytes, flush: true);
  }

  /// Reads and unpacks an ACP1 archive directly from a file.
  static Future<AcPatchPackage> unpackFromFile(File file) async {
    final bytes = await file.readAsBytes();
    return unpack(bytes);
  }
}
