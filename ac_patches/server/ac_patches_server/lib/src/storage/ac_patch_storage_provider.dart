import 'dart:io';
import 'dart:typed_data';

abstract class IAcPatchStorageProvider {
  /// Stores a patch binary under [storageKey] and returns its relative URI or URL.
  Future<String> put({required String storageKey, required List<int> bytes});

  /// Retrieves the patch binary for [storageKey].
  Future<Uint8List> get({required String storageKey});

  /// Deletes the patch binary for [storageKey].
  Future<void> delete({required String storageKey});

  /// Checks if the patch binary exists.
  Future<bool> exists({required String storageKey});
}

class AcPatchLocalStorageProvider implements IAcPatchStorageProvider {
  final Directory rootDir;

  AcPatchLocalStorageProvider({required this.rootDir}) {
    if (!rootDir.existsSync()) {
      rootDir.createSync(recursive: true);
    }
  }

  File _resolveFile(String storageKey) {
    // Sanitize storage key to avoid directory traversal
    final normalized = storageKey.replaceAll('/', Platform.pathSeparator).replaceAll('\\', Platform.pathSeparator);
    return File('${rootDir.path}${Platform.pathSeparator}$normalized');
  }

  @override
  Future<String> put({required String storageKey, required List<int> bytes}) async {
    final file = _resolveFile(storageKey);
    final parent = file.parent;
    if (!parent.existsSync()) {
      await parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes, flush: true);
    return storageKey;
  }

  @override
  Future<Uint8List> get({required String storageKey}) async {
    final file = _resolveFile(storageKey);
    if (!file.existsSync()) {
      throw FileNotFoundException(file.path);
    }
    return await file.readAsBytes();
  }

  @override
  Future<void> delete({required String storageKey}) async {
    final file = _resolveFile(storageKey);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  @override
  Future<bool> exists({required String storageKey}) async {
    final file = _resolveFile(storageKey);
    return file.existsSync();
  }
}

class FileNotFoundException implements Exception {
  final String path;
  FileNotFoundException(this.path);
  @override
  String toString() => 'FileNotFoundException: $path';
}
