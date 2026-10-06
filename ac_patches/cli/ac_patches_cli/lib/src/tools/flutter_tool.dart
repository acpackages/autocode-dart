import 'dart:convert';
import 'dart:io';

class FlutterInfo {
  final String flutterVersion;
  final String dartVersion;
  final String engineRevision;

  FlutterInfo({
    required this.flutterVersion,
    required this.dartVersion,
    required this.engineRevision,
  });
}

class FlutterTool {
  static Future<FlutterInfo> getFlutterInfo() async {
    try {
      final result = await Process.run('flutter', ['--version', '--machine'], runInShell: true);
      if (result.exitCode == 0) {
        final data = jsonDecode(result.stdout as String) as Map<String, dynamic>;
        return FlutterInfo(
          flutterVersion: (data['frameworkVersion'] as String?) ?? 'unknown',
          dartVersion: (data['dartSdkVersion'] as String?) ?? 'unknown',
          engineRevision: (data['engineRevision'] as String?) ?? 'unknown',
        );
      }
    } catch (_) {}

    return FlutterInfo(
      flutterVersion: '3.44.4',
      dartVersion: '3.12.2',
      engineRevision: 'unknown',
    );
  }

  /// Builds a full native base release for the given platform.
  static Future<ProcessResult> buildBaseRelease({
    required Directory projectDir,
    required String platform,
  }) async {
    List<String> args;
    switch (platform.toLowerCase()) {
      case 'windows':
        args = ['build', 'windows', '--release'];
        break;
      case 'android':
        args = ['build', 'apk', '--release'];
        break;
      case 'linux':
        args = ['build', 'linux', '--release'];
        break;
      case 'macos':
        args = ['build', 'macos', '--release'];
        break;
      case 'ios':
        args = ['build', 'ios', '--release', '--no-codesign'];
        break;
      default:
        throw ArgumentError('Unsupported platform: $platform');
    }

    return await Process.run('flutter', args, workingDirectory: projectDir.path, runInShell: true);
  }

  /// Compiles a standalone Dart AOT snapshot for OTA patching in seconds using `flutter assemble`.
  static Future<File> assembleAotPatch({
    required Directory projectDir,
    required String platform,
    String targetFile = 'lib/main.dart',
  }) async {
    List<String> assembleArgs;
    List<String> candidatePaths;

    switch (platform.toLowerCase()) {
      case 'windows':
        assembleArgs = [
          'assemble',
          '-dTargetPlatform=windows-x64',
          '-dBuildMode=release',
          '-dTargetFile=$targetFile',
          'release_bundle_windows-x64_assets',
        ];
        candidatePaths = [
          '${projectDir.path}/build/windows/x64/runner/Release/data/app.so',
          '${projectDir.path}/build/native_assets/windows/app.so',
          '${projectDir.path}/build/windows/runner/Release/data/app.so',
        ];
        break;

      case 'android':
        assembleArgs = [
          'assemble',
          '-dTargetPlatform=android-arm64',
          '-dBuildMode=release',
          '-dTargetFile=$targetFile',
          'android_aot_bundle_release_android-arm64',
        ];
        candidatePaths = [
          '${projectDir.path}/build/app/intermediates/flutter/release/arm64-v8a/app.so',
          '${projectDir.path}/build/native_assets/android/app.so',
        ];
        break;

      case 'linux':
        assembleArgs = [
          'assemble',
          '-dTargetPlatform=linux-x64',
          '-dBuildMode=release',
          '-dTargetFile=$targetFile',
          'release_bundle_linux-x64_assets',
        ];
        candidatePaths = [
          '${projectDir.path}/build/linux/x64/release/bundle/lib/libapp.so',
        ];
        break;

      default:
        throw ArgumentError('AOT assembly for $platform is not yet supported in this version.');
    }

    final result = await Process.run(
      'flutter',
      assembleArgs,
      workingDirectory: projectDir.path,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw Exception('flutter assemble failed with exit code ${result.exitCode}:\n${result.stderr}\n${result.stdout}');
    }

    for (final path in candidatePaths) {
      final file = File(path.replaceAll('/', Platform.pathSeparator));
      if (file.existsSync()) {
        return file;
      }
    }

    throw Exception('Could not locate compiled app.so after flutter assemble. Checked: $candidatePaths');
  }

  /// Locates the base release AOT snapshot / binary in a built project.
  static File? findBaseAotFile({
    required Directory projectDir,
    required String platform,
  }) {
    List<String> candidatePaths;
    switch (platform.toLowerCase()) {
      case 'windows':
        candidatePaths = [
          '${projectDir.path}/build/windows/x64/runner/Release/data/app.so',
          '${projectDir.path}/build/windows/runner/Release/data/app.so',
        ];
        break;
      case 'android':
        candidatePaths = [
          '${projectDir.path}/build/app/intermediates/flutter/release/arm64-v8a/app.so',
        ];
        break;
      default:
        candidatePaths = [];
    }

    for (final path in candidatePaths) {
      final file = File(path.replaceAll('/', Platform.pathSeparator));
      if (file.existsSync()) {
        return file;
      }
    }
    return null;
  }
}
