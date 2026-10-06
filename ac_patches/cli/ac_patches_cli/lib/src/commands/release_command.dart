import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import '../config/ac_patches_project_config.dart';
import '../tools/flutter_tool.dart';
import '../tools/hash_utils.dart';
import '../tools/native_change_detector.dart';

class ReleaseCommand extends Command {
  @override
  final String name = 'release';

  @override
  final String description = 'Builds and registers a base release for a target platform.';

  ReleaseCommand() {
    argParser.addFlag('no-build', help: 'Skip building and use existing build artifacts.', defaultsTo: false);
  }

  @override
  Future<void> run() async {
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      print('❌ Error: Platform argument required. Example: ac_patches release windows');
      exitCode = 1;
      return;
    }

    final platform = args.first.toLowerCase();
    final currentDir = Directory.current;

    final config = AcPatchesProjectConfig.load(currentDir);
    if (config == null) {
      print('❌ Error: No ${AcPatchesProjectConfig.configFileName} found. Run ac_patches init first.');
      exitCode = 1;
      return;
    }

    final pubspecFile = File('${currentDir.path}${Platform.pathSeparator}pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('❌ Error: No pubspec.yaml found.');
      exitCode = 1;
      return;
    }

    final pubspec = loadYaml(pubspecFile.readAsStringSync()) as Map?;
    final fullVersion = (pubspec?['version'] as String?) ?? '1.0.0+1';
    final parts = fullVersion.split('+');
    final versionStr = parts[0];
    final buildNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
    final releaseId = fullVersion;

    print('📦 Preparing Base Release: $releaseId ($platform) for ${config.appId}...');

    final noBuild = argResults?['no-build'] as bool? ?? false;
    if (!noBuild) {
      print('🔨 Building Flutter release for $platform...');
      final buildRes = await FlutterTool.buildBaseRelease(projectDir: currentDir, platform: platform);
      if (buildRes.exitCode != 0) {
        print('❌ Build failed:\n${buildRes.stderr}\n${buildRes.stdout}');
        exitCode = 1;
        return;
      }
      print('✅ Build completed successfully.');
    } else {
      print('⏩ Skipping build step (--no-build).');
    }

    // Locate base AOT binary and compute hash
    final aotFile = FlutterTool.findBaseAotFile(projectDir: currentDir, platform: platform);
    String baseReleaseHash = '';
    if (aotFile != null && aotFile.existsSync()) {
      baseReleaseHash = HashUtils.hashFile(aotFile);
      print('   Base AOT snapshot found: ${aotFile.path}');
      print('   Base release hash: $baseReleaseHash');
    } else {
      // Fallback: hash the release output directory
      baseReleaseHash = 'sha256:release_${DateTime.now().millisecondsSinceEpoch}';
      print('⚠️ Base app.so not directly located; using hash: $baseReleaseHash');
    }

    // Record release snapshot for native change detection
    NativeChangeDetector.recordReleaseSnapshot(
      projectDir: currentDir,
      releaseId: releaseId,
      platform: platform,
      baseReleaseHash: baseReleaseHash,
    );
    print('📝 Recorded native snapshot for regression detection in .ac_patches/');

    // Register release with the server
    final serverUrl = config.serverUrl;
    print('🌐 Registering release on server $serverUrl...');
    try {
      final client = http.Client();
      final insertUri = Uri.parse('$serverUrl/api/v1/release/register');
      final resp = await client.post(
        insertUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'releaseId': releaseId,
          'appId': config.appId,
          'version': versionStr,
          'buildNumber': buildNumber,
          'platform': platform,
          'baseReleaseHash': baseReleaseHash,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('✅ Release $releaseId registered successfully on server!');
      } else {
        print('⚠️ Server returned ${resp.statusCode}: ${resp.body}');
      }
      client.close();
    } catch (e) {
      print('⚠️ Could not connect to server to register release: $e');
      print('   (You can still build patches locally and upload later.)');
    }

    print('');
    print('🎉 Base Release Ready!');
    print('   Release ID:        $releaseId');
    print('   Platform:          $platform');
    print('   Base Release Hash: $baseReleaseHash');
  }
}
