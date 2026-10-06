import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class HashUtils {
  /// Computes the SHA-256 hash of a single file in format `sha256:<hex>`.
  static String hashFile(File file) {
    if (!file.existsSync()) return '';
    final bytes = file.readAsBytesSync();
    return 'sha256:${sha256.convert(bytes)}';
  }

  /// Computes a deterministic SHA-256 hash of a directory tree.
  static String hashDirectory(Directory dir, {List<String> ignorePatterns = const []}) {
    if (!dir.existsSync()) return '';
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) {
          final relPath = file.path.replaceAll('\\', '/');
          for (final pattern in ignorePatterns) {
            if (relPath.contains(pattern)) return false;
          }
          return true;
        })
        .toList();

    // Sort paths alphabetically for determinism
    files.sort((a, b) => a.path.compareTo(b.path));

    final accumulator = StringBuffer();
    for (final file in files) {
      final bytes = file.readAsBytesSync();
      final fileHash = sha256.convert(bytes).toString();
      final relPath = file.path.substring(dir.path.length).replaceAll('\\', '/');
      accumulator.writeln('$relPath:$fileHash');
    }

    return 'sha256:${sha256.convert(utf8.encode(accumulator.toString()))}';
  }
}
