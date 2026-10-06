import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import '../config/ac_patches_project_config.dart';
import '../tools/flutter_tool.dart';
import '../tools/hash_utils.dart';
import '../tools/native_change_detector.dart';

class PatchCommand extends Command {
  @override
  final String name = 'patch';

  @override
  final String description = 'Compiles, signs, packages, and uploads an OTA patch for a target platform.';

  PatchCommand() {
    argParser.addFlag('publish', help: 'Automatically publish the patch after upload.', defaultsTo: false);
    argParser.addOption('track', abbr: 't', help: 'Target track (e.g. stable, beta).');
    argParser.addOption('rollout', abbr: 'r', help: 'Staged rollout percentage (1-100).', defaultsTo: '100');
    argParser.addFlag('force', help: 'Force compilation even if native changes are detected.', defaultsTo: false);
    argParser.addOption('target', abbr: 'f', help: 'Target Dart file.', defaultsTo: 'lib/main.dart');
    argParser.addOption('private-key', abbr: 'k', help: 'Path or base64 of private signing key.');
    argParser.addOption('patch-number', abbr: 'p', help: 'Explicit patch sequence number.');
    argParser.addOption('assets-dir', abbr: 'a', help: 'Path to directory containing assets to patch.');
    argParser.addOption('patch-type', help: 'Type of patch: dart or asset.', defaultsTo: 'dart');
  }

  @override
  Future<void> run() async {
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      print('❌ Error: Platform argument required. Example: ac_patches patch windows');
      exitCode = 1;
      return;
    }

    final platformStr = args.first.toLowerCase();
    final platform = AcEnumPatchPlatform.fromValue(platformStr);
    if (platform == null) {
      print('❌ Error: Unsupported platform: $platformStr');
      exitCode = 1;
      return;
    }

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
    final buildNumber = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
    final releaseId = fullVersion;

    print('⚡ Preparing OTA Patch for $releaseId ($platformStr)...');

    // 1. Guard Rail: Native Change Detection
    final force = argResults?['force'] as bool? ?? false;
    final changeResult = NativeChangeDetector.checkForChanges(
      projectDir: currentDir,
      releaseId: releaseId,
      platform: platformStr,
    );

    if (changeResult.hasChanges) {
      print('⚠️ -------------------------------------------------------------');
      print('❌ NATIVE CODE MODIFICATION DETECTED:');
      print(changeResult.message ?? '');
      print('-------------------------------------------------------------');
      if (!force) {
        print('Aborting patch creation. OTA patches only apply to Dart application code.');
        print('If you modified Kotlin/Swift/C++/plugins, build a new base release instead:');
        print('   ac_patches release $platformStr');
        print('Or rerun with --force if you know what you are doing.');
        exitCode = 1;
        return;
      } else {
        print('⚠️ Overriding warning due to --force.');
      }
    }

    // 2. Resolve Base Release Hash
    String? baseReleaseHash = NativeChangeDetector.getRecordedBaseReleaseHash(
      projectDir: currentDir,
      releaseId: releaseId,
      platform: platformStr,
    );
    if (baseReleaseHash == null) {
      // Try to find local base snapshot
      final baseAot = FlutterTool.findBaseAotFile(projectDir: currentDir, platform: platformStr);
      if (baseAot != null && baseAot.existsSync()) {
        baseReleaseHash = HashUtils.hashFile(baseAot);
      } else {
        baseReleaseHash = 'sha256:unknown';
      }
    }

    final patchTypeStr = (argResults?['patch-type'] as String?)?.toLowerCase() ?? 'dart';
    final assetsDirArg = argResults?['assets-dir'] as String?;
    final isAssetPatch = patchTypeStr == 'asset' || (assetsDirArg != null && patchTypeStr != 'dart');

    final AcEnumPatchType patchType = isAssetPatch
        ? AcEnumPatchType.asset
        : AcEnumPatchType.dartApplication;

    // 3. Prepare payload (AOT snapshot or Asset bundle)
    final Uint8List payloadBytes;
    if (patchType == AcEnumPatchType.asset) {
      final assetsPath = assetsDirArg ?? 'assets';
      final resolvedAssetsDir = Directory('${currentDir.path}${Platform.pathSeparator}$assetsPath');
      if (!resolvedAssetsDir.existsSync()) {
        print('❌ Error: Assets directory not found at: ${resolvedAssetsDir.path}');
        exitCode = 1;
        return;
      }
      print('📦 Packaging assets from ${resolvedAssetsDir.path} into ACAS bundle...');
      payloadBytes = await AcAssetArchive.packDirectory(resolvedAssetsDir);
      print('✅ Packaged assets (${payloadBytes.length} bytes).');
    } else {
      final targetFile = argResults?['target'] as String? ?? 'lib/main.dart';
      print('🔨 Compiling Dart AOT snapshot with flutter assemble (takes ~5s)...');
      final stopwatch = Stopwatch()..start();
      File compiledAotFile;
      try {
        compiledAotFile = await FlutterTool.assembleAotPatch(
          projectDir: currentDir,
          platform: platformStr,
          targetFile: targetFile,
        );
      } catch (e) {
        print('❌ AOT compilation failed: $e');
        exitCode = 1;
        return;
      }
      stopwatch.stop();
      print('✅ Compiled ${compiledAotFile.path} in ${stopwatch.elapsedMilliseconds}ms.');
      payloadBytes = compiledAotFile.readAsBytesSync();
    }

    // 4. Resolve Signing Key
    final privKeyArg = argResults?['private-key'] as String?;
    Uint8List privKeyBytes;
    if (privKeyArg != null && privKeyArg.isNotEmpty) {
      final keyFile = File(privKeyArg);
      if (keyFile.existsSync()) {
        privKeyBytes = base64Decode(keyFile.readAsStringSync().trim());
      } else {
        privKeyBytes = base64Decode(privKeyArg.trim());
      }
    } else {
      final defaultKeyFile = File('${currentDir.path}${Platform.pathSeparator}ac_patches_key.priv');
      if (defaultKeyFile.existsSync()) {
        privKeyBytes = base64Decode(defaultKeyFile.readAsStringSync().trim());
      } else if (config.privateKey != null && config.privateKey!.isNotEmpty) {
        privKeyBytes = base64Decode(config.privateKey!.trim());
      } else {
        print('❌ Error: No private signing key found. Specify --private-key or run ac_patches init.');
        exitCode = 1;
        return;
      }
    }

    // 5. Determine Patch Sequence Number
    int patchNumber = 1;
    final patchNumArg = argResults?['patch-number'] as String?;
    if (patchNumArg != null) {
      patchNumber = int.tryParse(patchNumArg) ?? 1;
    } else {
      // Query server or local count
      try {
        final checkUri = Uri.parse('${config.serverUrl}/api/v1/patch/check');
        final resp = await http.post(
          checkUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(AcPatchCheckRequest(
            appId: config.appId,
            releaseId: releaseId,
            buildNumber: buildNumber,
            platform: platform,
            architecture: platform == AcEnumPatchPlatform.windows
                ? AcEnumPatchArchitecture.x86_64
                : AcEnumPatchArchitecture.arm64_v8a,
            installationId: 'cli_probe',
          ).toJson()),
        );
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body) as Map<String, dynamic>;
          final currNum = (data['patchNumber'] as int?) ?? 0;
          patchNumber = currNum + 1;
        }
      } catch (_) {
        patchNumber = 1;
      }
    }

    final patchId = '$releaseId-p$patchNumber';
    final flutterInfo = await FlutterTool.getFlutterInfo();
    final payloadHash = AcPatchCrypto.sha256Hex(payloadBytes);

    // 6. Sign payload with Ed25519
    print('🔏 Signing patch payload with Ed25519...');
    final keyPair = await AcPatchCrypto.keyPairFromSeed(privKeyBytes);
    final signature = await AcPatchCrypto.signBase64(data: payloadBytes, keyPair: keyPair);

    // 7. Create Manifest and ACP1 Archive
    final manifest = AcPatchManifest(
      appId: config.appId,
      releaseId: releaseId,
      patchId: patchId,
      patchNumber: patchNumber,
      patchType: patchType,
      platform: platform,
      architecture: platform == AcEnumPatchPlatform.windows
          ? AcEnumPatchArchitecture.x86_64
          : AcEnumPatchArchitecture.arm64_v8a,
      flutterVersion: flutterInfo.flutterVersion,
      dartVersion: flutterInfo.dartVersion,
      engineRevision: flutterInfo.engineRevision,
      baseBuildNumber: buildNumber,
      baseReleaseHash: baseReleaseHash,
      payloadHash: payloadHash,
      payloadSize: payloadBytes.length,
      signature: signature,
    );

    print('📦 Packaging ACP1 archive...');
    final archiveBytes = await AcPatchArchive.pack(
      manifest: manifest,
      payload: payloadBytes,
      keyPair: keyPair,
      compress: true,
    );

    // Save archive to build directory
    final outDir = Directory('${currentDir.path}/build/ac_patches'.replaceAll('/', Platform.pathSeparator));
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
    final archiveFile = File('${outDir.path}${Platform.pathSeparator}$patchId.acp1');
    archiveFile.writeAsBytesSync(archiveBytes);
    print('✅ Saved patch archive: ${archiveFile.path} (${archiveBytes.length} bytes)');

    // 8. Upload to ac_patches server
    print('🌐 Uploading patch to ${config.serverUrl}...');
    try {
      final uploadUri = Uri.parse('${config.serverUrl}/api/v1/patch/upload');
      final resp = await http.post(
        uploadUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bytesBase64': base64Encode(archiveBytes)}),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('✅ Patch $patchId uploaded successfully!');
      } else {
        print('❌ Server upload error (${resp.statusCode}): ${resp.body}');
        exitCode = 1;
        return;
      }
    } catch (e) {
      print('❌ Failed to connect to server: $e');
      exitCode = 1;
      return;
    }

    // 9. Publish if requested
    final shouldPublish = argResults?['publish'] as bool? ?? false;
    final targetTrack = (argResults?['track'] as String?) ?? config.track;
    final rollout = int.tryParse(argResults?['rollout'] as String? ?? '100') ?? 100;

    if (shouldPublish) {
      print('🚀 Publishing $patchId to track "$targetTrack" ($rollout% rollout)...');
      try {
        final publishUri = Uri.parse('${config.serverUrl}/api/v1/patch/publish');
        final resp = await http.post(
          publishUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'patchId': patchId,
            'track': targetTrack,
            'rolloutPercentage': rollout,
          }),
        );
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          print('✅ Patch published successfully and is now active for users!');
        } else {
          print('⚠️ Publish failed (${resp.statusCode}): ${resp.body}');
        }
      } catch (e) {
        print('⚠️ Publish request failed: $e');
      }
    } else {
      print('');
      print('ℹ️ Patch uploaded. To promote to users:');
      print('   ac_patches publish --patch-id $patchId --track $targetTrack');
    }
  }
}
