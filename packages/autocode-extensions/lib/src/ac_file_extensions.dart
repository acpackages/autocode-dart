import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart';
extension AcFileExtensions on File {

  String getExtension(){
    return path.split(".").last;
  }

  String getName(){
    String result= path.split('/').last;
    result= result.split('\\').last;
    return result;
  }

  Future<Map<String, dynamic>> toBlobJson() async {
    if (!await exists()) {
      throw Exception("File not found: $path");
    }

    return {
      'name': getName(),
      'lastModified': (await stat()).modified.millisecondsSinceEpoch,
      'size': await length(),
      'type': lookupMimeType(path) ?? 'application/octet-stream',
      'blob': await readAsBytes(),
    };
  }

  Future<Map<String, dynamic>> toBytesJson() async {
    if (!await exists()) {
      throw Exception("File not found: $path");
    }

    final bytes = await readAsBytes();

    return {
      'name': getName(),
      'lastModified': (await stat()).modified.millisecondsSinceEpoch,
      'size': bytes.length,
      'type': lookupMimeType(path) ?? 'application/octet-stream',
      'bytes': bytes.toList(),
    };
  }

  Future<void> writeByteData(ByteData data) async{
    final buffer = data.buffer;
    await writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

}