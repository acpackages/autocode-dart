import 'dart:io';
import './ac_sync_provider.dart';
import './ac_sync_file_provider.dart';

class AcSyncDirectoryProvider implements AcSyncProvider {
  @override
  final String targetId;
  final String directoryPath;
  final String destinationDirectory;
  final bool recursive;
  final List<String> includeFiles;
  final List<String> excludeFiles;
  final int chunkSize;

  AcSyncFileProvider? _fileProvider;

  AcSyncDirectoryProvider({
    required this.targetId,
    required this.directoryPath,
    required this.destinationDirectory,
    this.recursive = true,
    this.includeFiles = const [],
    this.excludeFiles = const [],
    this.chunkSize = 64 * 1024,
  });

  // Lazy-initialize file provider by scanning directory
  AcSyncFileProvider _getFileProvider() {
    if (_fileProvider != null) return _fileProvider!;

    List<File> matchedFiles = [];
    Directory dir = Directory(directoryPath);
    if (dir.existsSync()) {
      var entities = dir.listSync(recursive: recursive);
      // Sort entities to ensure consistent order
      entities.sort((a, b) => a.path.compareTo(b.path));
      
      for (var entity in entities) {
        if (entity is File) {
          // Get relative path
          String entityPathNorm = entity.path.replaceAll('\\', '/');
          String dirPathNorm = dir.path.replaceAll('\\', '/');
          String relativePath = entityPathNorm;
          if (entityPathNorm.startsWith(dirPathNorm)) {
            relativePath = entityPathNorm.substring(dirPathNorm.length);
          }
          if (relativePath.startsWith('/') || relativePath.startsWith('\\')) {
            relativePath = relativePath.substring(1);
          }
          relativePath = relativePath.replaceAll('\\', '/');

          // Filter files
          bool isIncluded = true;
          if (includeFiles.isNotEmpty) {
            isIncluded = false;
            for (var pattern in includeFiles) {
              if (_matchesGlob(relativePath, pattern)) {
                isIncluded = true;
                break;
              }
            }
          }

          if (isIncluded && excludeFiles.isNotEmpty) {
            for (var pattern in excludeFiles) {
              if (_matchesGlob(relativePath, pattern)) {
                isIncluded = false;
                break;
              }
            }
          }

          if (isIncluded) {
            matchedFiles.add(entity);
          }
        }
      }
    }

    _fileProvider = AcSyncFileProvider(
      targetId: targetId,
      files: matchedFiles,
      destinationDirectory: destinationDirectory,
      baseDirectory: directoryPath,
      chunkSize: chunkSize,
    );
    return _fileProvider!;
  }

  @override
  Future<dynamic> getCurrentCheckpoint() async {
    return _getFileProvider().getCurrentCheckpoint();
  }

  @override
  Future<AcSyncBatch> getChanges(dynamic fromCheckpoint, dynamic targetCheckpoint) async {
    return _getFileProvider().getChanges(fromCheckpoint, targetCheckpoint);
  }

  @override
  Future<void> applyChanges(dynamic payload) async {
    return _getFileProvider().applyChanges(payload);
  }

  @override
  Future<void> commitChanges() async {
    return _getFileProvider().commitChanges();
  }

  @override
  Future<void> rollbackChanges() async {
    return _getFileProvider().rollbackChanges();
  }

  @override
  Future<void> deleteSyncedData(dynamic payload) async {
    return _getFileProvider().deleteSyncedData(payload);
  }

  bool _matchesGlob(String path, String pattern) {
    path = path.replaceAll('\\', '/');
    pattern = pattern.replaceAll('\\', '/');

    // Simple glob translation
    String regexString = pattern
        .replaceAll('.', r'\.')
        .replaceAll('**/', '([^/]+/)*')
        .replaceAll('**', '.*')
        .replaceAll('*', '[^/]*')
        .replaceAll('?', '.');

    // Prefix/suffix match logic
    if (!regexString.startsWith('^')) {
      regexString = '^' + regexString;
    }
    if (!regexString.endsWith('\$')) {
      regexString = regexString + '\$';
    }

    try {
      RegExp regExp = RegExp(regexString, caseSensitive: false);
      return regExp.hasMatch(path);
    } catch (_) {
      // Fallback: exact match or contains
      return path.toLowerCase() == pattern.toLowerCase() || path.toLowerCase().contains(pattern.toLowerCase());
    }
  }
}
