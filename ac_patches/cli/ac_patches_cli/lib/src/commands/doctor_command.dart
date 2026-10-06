import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:ac_patches_core/ac_patches_core.dart';
import '../config/ac_patches_project_config.dart';
import '../tools/flutter_tool.dart';

class DoctorCommand extends Command {
  @override
  final String name = 'doctor';

  @override
  final String description = 'Diagnoses the local development environment and server connectivity.';

  @override
  Future<void> run() async {
    print('🩺 Running ac_patches doctor diagnostics...\n');
    final currentDir = Directory.current;

    // 1. Flutter & Dart Environment
    final info = await FlutterTool.getFlutterInfo();
    print('[$_tick] Flutter SDK:');
    print('    • Framework Version: ${info.flutterVersion}');
    print('    • Dart SDK Version:  ${info.dartVersion}');
    print('    • Engine Revision:   ${info.engineRevision}');

    // 2. Project Pubspec
    final pubspecFile = File('${currentDir.path}${Platform.pathSeparator}pubspec.yaml');
    if (pubspecFile.existsSync()) {
      print('[$_tick] Project pubspec.yaml found');
    } else {
      print('[$_cross] No pubspec.yaml found in current working directory');
    }

    // 3. ac_patches.yaml Configuration
    final config = AcPatchesProjectConfig.load(currentDir);
    if (config != null) {
      print('[$_tick] ac_patches.yaml configuration loaded:');
      print('    • App ID:     ${config.appId}');
      print('    • Server URL: ${config.serverUrl}');
      print('    • Track:      ${config.track}');
    } else {
      print('[$_cross] ac_patches.yaml not found. Run "ac_patches init" to configure.');
    }

    // 4. Signing Keys
    final privKeyFile = File('${currentDir.path}${Platform.pathSeparator}ac_patches_key.priv');
    if (privKeyFile.existsSync()) {
      try {
        final privBytes = base64Decode(privKeyFile.readAsStringSync().trim());
        final keyPair = await AcPatchCrypto.keyPairFromSeed(privBytes);
        final pub = await keyPair.extractPublicKey();
        final pubB64 = base64Encode(pub.bytes);
        if (config != null && config.publicKey.isNotEmpty && config.publicKey != pubB64) {
          print('[$_cross] Public key in ac_patches.yaml does NOT match ac_patches_key.priv!');
        } else {
          print('[$_tick] Ed25519 signing keypair valid and matched.');
        }
      } catch (e) {
        print('[$_cross] Error reading private key: $e');
      }
    } else {
      print('[$_warn] ac_patches_key.priv not found. You will need to provide --private-key to build patches.');
    }

    // 5. Server Connectivity
    if (config != null && config.serverUrl.isNotEmpty) {
      try {
        final client = http.Client();
        final checkUri = Uri.parse('${config.serverUrl}/api/v1/patch/check');
        final resp = await client.post(
          checkUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(AcPatchCheckRequest(
            appId: config.appId,
            releaseId: '0.0.0+0',
            buildNumber: 0,
            platform: AcEnumPatchPlatform.windows,
            architecture: AcEnumPatchArchitecture.x86_64,
            installationId: 'doctor_probe',
          ).toJson()),
        ).timeout(const Duration(seconds: 4));

        if (resp.statusCode == 200) {
          print('[$_tick] ac_patches server connected: ${config.serverUrl} (HTTP 200)');
        } else {
          print('[$_warn] Server reachable at ${config.serverUrl}, but returned HTTP ${resp.statusCode}');
        }
        client.close();
      } catch (e) {
        print('[$_cross] Cannot reach ac_patches server at ${config.serverUrl}: $e');
      }
    }

    print('\n🏁 Diagnostics complete.');
  }

  static const String _tick = '✓';
  static const String _cross = '✗';
  static const String _warn = '!';
}
