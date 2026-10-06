import 'dart:convert';
import 'dart:io';
import 'hash_utils.dart';

class NativeChangeResult {
  final bool hasChanges;
  final String? message;
  final String? oldHash;
  final String? newHash;

  NativeChangeResult({
    required this.hasChanges,
    this.message,
    this.oldHash,
    this.newHash,
  });
}

class NativeChangeDetector {
  static const String metadataDirName = '.ac_patches';

  static Directory getMetadataDir(Directory projectDir) {
    final dir = Directory('${projectDir.path}${Platform.pathSeparator}$metadataDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  static String getNativeDirPath(Directory projectDir, String platform) {
    switch (platform.toLowerCase()) {
      case 'windows':
        return '${projectDir.path}${Platform.pathSeparator}windows';
      case 'android':
        return '${projectDir.path}${Platform.pathSeparator}android';
      case 'ios':
        return '${projectDir.path}${Platform.pathSeparator}ios';
      case 'macos':
        return '${projectDir.path}${Platform.pathSeparator}macos';
      case 'linux':
        return '${projectDir.path}${Platform.pathSeparator}linux';
      default:
        return '';
    }
  }

  /// Records the native snapshot metadata for a base release.
  static void recordReleaseSnapshot({
    required Directory projectDir,
    required String releaseId,
    required String platform,
    required String baseReleaseHash,
  }) {
    final metaDir = getMetadataDir(projectDir);
    final sanitizedRelease = releaseId.replaceAll('+', '_').replaceAll(':', '_');
    final file = File('${metaDir.path}${Platform.pathSeparator}release_${platform}_$sanitizedRelease.json');

    final nativePath = getNativeDirPath(projectDir, platform);
    final nativeDir = Directory(nativePath);
    final nativeDirHash = nativeDir.existsSync()
        ? HashUtils.hashDirectory(nativeDir, ignorePatterns: ['.git', 'build', '.dart_tool'])
        : '';

    final lockFile = File('${projectDir.path}${Platform.pathSeparator}pubspec.lock');
    final lockHash = lockFile.existsSync() ? HashUtils.hashFile(lockFile) : '';

    final data = {
      'releaseId': releaseId,
      'platform': platform,
      'baseReleaseHash': baseReleaseHash,
      'nativeDirHash': nativeDirHash,
      'pubspecLockHash': lockHash,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  /// Compares current workspace against the recorded release snapshot.
  static NativeChangeResult checkForChanges({
    required Directory projectDir,
    required String releaseId,
    required String platform,
  }) {
    final metaDir = getMetadataDir(projectDir);
    final sanitizedRelease = releaseId.replaceAll('+', '_').replaceAll(':', '_');
    final file = File('${metaDir.path}${Platform.pathSeparator}release_${platform}_$sanitizedRelease.json');

    if (!file.existsSync()) {
      return NativeChangeResult(
        hasChanges: false,
        message: 'No previous release snapshot found for $releaseId on $platform. Proceeding with caution.',
      );
    }

    try {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final expectedNativeHash = (json['nativeDirHash'] as String?) ?? '';

      final nativePath = getNativeDirPath(projectDir, platform);
      final nativeDir = Directory(nativePath);
      final currentNativeHash = nativeDir.existsSync()
          ? HashUtils.hashDirectory(nativeDir, ignorePatterns: ['.git', 'build', '.dart_tool'])
          : '';

      if (expectedNativeHash.isNotEmpty && currentNativeHash.isNotEmpty && expectedNativeHash != currentNativeHash) {
        return NativeChangeResult(
          hasChanges: true,
          message: 'Native source code modifications detected in "$platform/" directory.\n'
              'Native code cannot be updated via OTA and requires a new store/base release.',
          oldHash: expectedNativeHash,
          newHash: currentNativeHash,
        );
      }

      return NativeChangeResult(hasChanges: false);
    } catch (e) {
      return NativeChangeResult(
        hasChanges: false,
        message: 'Could not read snapshot: $e',
      );
    }
  }

  static String? getRecordedBaseReleaseHash({
    required Directory projectDir,
    required String releaseId,
    required String platform,
  }) {
    final metaDir = getMetadataDir(projectDir);
    final sanitizedRelease = releaseId.replaceAll('+', '_').replaceAll(':', '_');
    final file = File('${metaDir.path}${Platform.pathSeparator}release_${platform}_$sanitizedRelease.json');
    if (!file.existsSync()) return null;
    try {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      return json['baseReleaseHash'] as String?;
    } catch (_) {
      return null;
    }
  }
}
