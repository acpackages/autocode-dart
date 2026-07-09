import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import './ac_sync_provider.dart';

class AcSyncFileProvider implements AcSyncProvider {
  @override
  final String targetId;
  final List<File> files;
  final String destinationDirectory;
  final String? baseDirectory;
  final int chunkSize;

  // Track temporary writing file handle or path
  String? _activeTempPath;
  File? _activeTempFile;

  AcSyncFileProvider({
    required this.targetId,
    required this.files,
    required this.destinationDirectory,
    this.baseDirectory,
    this.chunkSize = 64 * 1024, // Default 64KB for sync transfers
  });

  @override
  Future<dynamic> getCurrentCheckpoint() async {
    // Current checkpoint is target checkpoint: all files at their final chunk
    return {
      'fileIndex': files.length,
      'chunkIndex': 0,
    };
  }

  @override
  Future<AcSyncBatch> getChanges(dynamic fromCheckpoint, dynamic targetCheckpoint) async {
    int fileIndex = 0;
    int chunkIndex = 0;

    if (fromCheckpoint is Map) {
      fileIndex = fromCheckpoint['fileIndex'] ?? 0;
      chunkIndex = fromCheckpoint['chunkIndex'] ?? 0;
    }

    if (fileIndex >= files.length) {
      return AcSyncBatch(
        payload: null,
        nextCheckpoint: {'fileIndex': files.length, 'chunkIndex': 0},
        hasMore: false,
      );
    }

    File currentFile = files[fileIndex];
    if (!currentFile.existsSync()) {
      // If file doesn't exist, skip to next file
      return getChanges({'fileIndex': fileIndex + 1, 'chunkIndex': 0}, targetCheckpoint);
    }

    int fileSize = currentFile.lengthSync();
    int totalChunks = (fileSize / chunkSize).ceil();
    if (totalChunks == 0) totalChunks = 1; // Empty file needs 1 chunk

    // Read chunk bytes
    List<int> chunkBytes = [];
    if (fileSize > 0) {
      int start = chunkIndex * chunkSize;
      int end = start + chunkSize;
      if (end > fileSize) end = fileSize;
      
      var raf = await currentFile.open(mode: FileMode.read);
      await raf.setPosition(start);
      chunkBytes = await raf.read(end - start);
      await raf.close();
    }

    // File metadata
    String relativePath = currentFile.path.replaceAll('\\', '/');
    String? baseDirNorm = baseDirectory?.replaceAll('\\', '/');
    if (baseDirNorm != null && relativePath.startsWith(baseDirNorm)) {
      relativePath = relativePath.substring(baseDirNorm.length);
    }
    if (relativePath.startsWith('/') || relativePath.startsWith('\\')) {
      relativePath = relativePath.substring(1);
    }
    String fileHash = _calculateHash(currentFile);

    Map<String, dynamic> payload = {
      'relativePath': relativePath,
      'fileIndex': fileIndex,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'fileSize': fileSize,
      'chunkData': base64Encode(chunkBytes),
      'hash': fileHash,
      'lastModified': currentFile.lastModifiedSync().toIso8601String(),
    };

    int nextFileIndex = fileIndex;
    int nextChunkIndex = chunkIndex + 1;
    if (nextChunkIndex >= totalChunks) {
      nextFileIndex += 1;
      nextChunkIndex = 0;
    }

    bool hasMore = nextFileIndex < files.length;

    return AcSyncBatch(
      payload: payload,
      nextCheckpoint: {
        'fileIndex': nextFileIndex,
        'chunkIndex': nextChunkIndex,
      },
      hasMore: hasMore,
    );
  }

  @override
  Future<void> applyChanges(dynamic payload) async {
    if (payload == null) return;
    
    String relativePath = payload['relativePath'];
    int chunkIndex = payload['chunkIndex'] ?? 0;
    int totalChunks = payload['totalChunks'] ?? 1;
    String chunkDataBase64 = payload['chunkData'] ?? "";
    List<int> chunkBytes = base64Decode(chunkDataBase64);

    // Build local path relative to destinationDirectory
    // Keep relative path clean
    String cleanRelPath = relativePath.replaceAll('\\', '/');
    if (cleanRelPath.startsWith('./')) cleanRelPath = cleanRelPath.substring(2);
    
    // Split segments and reconstruct to prevent absolute path escapes
    List<String> segments = cleanRelPath.split('/');
    String fileName = segments.join(Platform.pathSeparator);
    String localPath = destinationDirectory + Platform.pathSeparator + fileName;

    // Write to a temporary file until all chunks are complete
    String tempPath = '$localPath.tmp';
    _activeTempPath = tempPath;

    File tempFile = File(tempPath);
    if (!tempFile.parent.existsSync()) {
      tempFile.parent.createSync(recursive: true);
    }

    if (chunkIndex == 0) {
      if (tempFile.existsSync()) tempFile.deleteSync();
      _activeTempFile = await tempFile.create(recursive: true);
    } else {
      _activeTempFile ??= tempFile;
    }

    var raf = await _activeTempFile!.open(mode: FileMode.writeOnlyAppend);
    await raf.writeFrom(chunkBytes);
    await raf.close();

    // If this is the last chunk, rename temporary file to destination path
    if (chunkIndex + 1 == totalChunks) {
      File destFile = File(localPath);
      if (destFile.existsSync()) destFile.deleteSync();
      await tempFile.rename(localPath);
      
      // Update modified time if present
      if (payload['lastModified'] != null) {
        var dt = DateTime.parse(payload['lastModified']);
        await destFile.setLastModified(dt);
      }
      
      _activeTempFile = null;
      _activeTempPath = null;
    }
  }

  @override
  Future<void> commitChanges() async {
    // Completed implicitly during last chunk rename
  }

  @override
  Future<void> rollbackChanges() async {
    _activeTempFile = null;
    if (_activeTempPath != null) {
      var f = File(_activeTempPath!);
      if (f.existsSync()) {
        f.deleteSync();
      }
      _activeTempPath = null;
    }
  }

  @override
  Future<void> deleteSyncedData(dynamic payload) async {
    // Not required for basic file sync
  }

  String _calculateHash(File file) {
    if (!file.existsSync()) return "";
    var bytes = file.readAsBytesSync();
    return md5.convert(bytes).toString();
  }
}
