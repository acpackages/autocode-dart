import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

extension AcFileExtensions on File {
  String get extensionName => p.extension(path).replaceFirst('.', '');

  String get fileName => p.basename(path);

  Future<Map<String, dynamic>> toBlobJson() async {
    if (!await exists()) {
      throw FileSystemException("File not found", path);
    }

    final statInfo = await stat();

    return {
      'name': fileName,
      'lastModified': statInfo.modified.millisecondsSinceEpoch,
      'size': await length(),
      'type': lookupMimeType(path) ?? 'application/octet-stream',
      'blob': await readAsBytes(),
    };
  }

  Future<Map<String, dynamic>> toBytesJson() async {
    if (!await exists()) {
      throw FileSystemException("File not found", path);
    }

    final statInfo = await stat();
    final bytes = await readAsBytes();

    return {
      'name': fileName,
      'lastModified': statInfo.modified.millisecondsSinceEpoch,
      'size': bytes.length,
      'type': lookupMimeType(path) ?? 'application/octet-stream',
      'bytes': bytes.toList(),
    };
  }

  Future<void> writeByteData(ByteData data) async {
    final buffer = data.buffer;
    await writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
