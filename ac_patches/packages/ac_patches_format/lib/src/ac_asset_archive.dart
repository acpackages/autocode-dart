import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class AcAssetArchiveException implements Exception {
  final String message;
  AcAssetArchiveException(this.message);

  @override
  String toString() => 'AcAssetArchiveException: $message';
}

/// An in-memory representation of an unpacked asset bundle.
class AcAssetBundle {
  final Map<String, Uint8List> files;

  AcAssetBundle(this.files);

  /// Extracts all files in the bundle to [targetDir].
  Future<void> extractToDirectory(Directory targetDir) async {
    if (!targetDir.existsSync()) {
      await targetDir.create(recursive: true);
    }

    for (final entry in files.entries) {
      final relativePath = entry.key.replaceAll('/', Platform.pathSeparator);
      final destFile = File('${targetDir.path}${Platform.pathSeparator}$relativePath');
      final parentDir = destFile.parent;
      if (!parentDir.existsSync()) {
        await parentDir.create(recursive: true);
      }
      await destFile.writeAsBytes(entry.value, flush: true);
    }
  }
}

/// Serializes and deserializes directory trees of assets into a compact binary format.
class AcAssetArchive {
  static const List<int> magicBytes = [0x41, 0x43, 0x41, 0x53]; // 'ACAS'
  static const int currentVersion = 1;

  /// Serializes a map of `{relativeFilePath: bytes}` into a binary byte buffer.
  static Uint8List pack(Map<String, List<int>> files) {
    var totalSize = 4 + 2 + 4; // Magic (4) + Version (2) + Count (4)

    final encodedPaths = <String, Uint8List>{};
    for (final entry in files.entries) {
      // Normalize slashes to forward slash for cross-platform consistency
      final normalizedPath = entry.key.replaceAll('\\', '/');
      final pathBytes = Uint8List.fromList(utf8.encode(normalizedPath));
      encodedPaths[entry.key] = pathBytes;
      totalSize += 2 + pathBytes.length + 4 + entry.value.length;
    }

    final buffer = Uint8List(totalSize);
    final byteData = ByteData.sublistView(buffer);

    var offset = 0;
    // 1. Magic
    buffer.setRange(offset, offset + 4, magicBytes);
    offset += 4;

    // 2. Version
    byteData.setUint16(offset, currentVersion, Endian.big);
    offset += 2;

    // 3. File count
    byteData.setUint32(offset, files.length, Endian.big);
    offset += 4;

    // 4. File entries
    for (final entry in files.entries) {
      final pathBytes = encodedPaths[entry.key]!;
      // Path length
      byteData.setUint16(offset, pathBytes.length, Endian.big);
      offset += 2;

      // Path bytes
      buffer.setRange(offset, offset + pathBytes.length, pathBytes);
      offset += pathBytes.length;

      // Data length
      byteData.setUint32(offset, entry.value.length, Endian.big);
      offset += 4;

      // Data bytes
      buffer.setRange(offset, offset + entry.value.length, entry.value);
      offset += entry.value.length;
    }

    return buffer;
  }

  /// Recursively walks [dir] and packs all files into an asset archive.
  static Future<Uint8List> packDirectory(Directory dir) async {
    if (!dir.existsSync()) {
      throw AcAssetArchiveException('Directory does not exist: ${dir.path}');
    }

    final filesMap = <String, List<int>>{};
    final entities = dir.listSync(recursive: true, followLinks: false);

    final basePath = dir.path.endsWith(Platform.pathSeparator)
        ? dir.path
        : '${dir.path}${Platform.pathSeparator}';

    for (final entity in entities) {
      if (entity is File) {
        final relPath = entity.path.substring(basePath.length).replaceAll('\\', '/');
        filesMap[relPath] = await entity.readAsBytes();
      }
    }

    return pack(filesMap);
  }

  /// Deserializes binary bytes into an [AcAssetBundle].
  static AcAssetBundle unpack(List<int> archiveBytes) {
    if (archiveBytes.length < 10) {
      throw AcAssetArchiveException('Archive too short for ACAS header');
    }

    final uint8List = archiveBytes is Uint8List ? archiveBytes : Uint8List.fromList(archiveBytes);
    final byteData = ByteData.sublistView(uint8List);

    var offset = 0;

    // 1. Magic
    for (var i = 0; i < 4; i++) {
      if (uint8List[offset + i] != magicBytes[i]) {
        throw AcAssetArchiveException('Invalid ACAS magic header');
      }
    }
    offset += 4;

    // 2. Version
    final version = byteData.getUint16(offset, Endian.big);
    offset += 2;
    if (version != currentVersion) {
      throw AcAssetArchiveException('Unsupported ACAS version: $version');
    }

    // 3. Count
    final count = byteData.getUint32(offset, Endian.big);
    offset += 4;

    final files = <String, Uint8List>{};

    for (var i = 0; i < count; i++) {
      if (offset + 2 > uint8List.length) {
        throw AcAssetArchiveException('Truncated while reading path length at index $i');
      }
      final pathLen = byteData.getUint16(offset, Endian.big);
      offset += 2;

      if (offset + pathLen > uint8List.length) {
        throw AcAssetArchiveException('Truncated while reading path string at index $i');
      }
      final pathBytes = uint8List.sublist(offset, offset + pathLen);
      final pathStr = utf8.decode(pathBytes);
      offset += pathLen;

      if (offset + 4 > uint8List.length) {
        throw AcAssetArchiveException('Truncated while reading data length for $pathStr');
      }
      final dataLen = byteData.getUint32(offset, Endian.big);
      offset += 4;

      if (offset + dataLen > uint8List.length) {
        throw AcAssetArchiveException('Truncated while reading data bytes for $pathStr');
      }
      final dataBytes = uint8List.sublist(offset, offset + dataLen);
      offset += dataLen;

      files[pathStr] = dataBytes;
    }

    return AcAssetBundle(files);
  }
}
