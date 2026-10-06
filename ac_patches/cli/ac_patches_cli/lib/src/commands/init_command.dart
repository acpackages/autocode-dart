import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:yaml/yaml.dart';
import '../config/ac_patches_project_config.dart';

class InitCommand extends Command {
  @override
  final String name = 'init';

  @override
  final String description = 'Initializes ac_patches configuration and Ed25519 keys for this Flutter project.';

  InitCommand() {
    argParser.addOption('app-id', abbr: 'a', help: 'Unique application identifier (e.g. com.example.myapp).');
    argParser.addOption('server-url', abbr: 's', defaultsTo: 'http://localhost:8080', help: 'ac_patches server URL.');
    argParser.addOption('track', abbr: 't', defaultsTo: 'stable', help: 'Default update track.');
  }

  @override
  Future<void> run() async {
    final currentDir = Directory.current;
    final pubspecFile = File('${currentDir.path}${Platform.pathSeparator}pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('❌ Error: No pubspec.yaml found in current directory. Please run ac_patches init inside a Flutter project.');
      exitCode = 1;
      return;
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final pubspecYaml = loadYaml(pubspecContent) as Map?;
    final projectName = (pubspecYaml?['name'] as String?) ?? 'myapp';

    final appId = argResults?['app-id'] as String? ?? 'com.example.$projectName';
    final serverUrl = argResults?['server-url'] as String? ?? 'http://localhost:8080';
    final track = argResults?['track'] as String? ?? 'stable';

    print('🚀 Initializing ac_patches for $appId...');

    // 1. Generate Ed25519 signing keypair
    final privKeyFile = File('${currentDir.path}${Platform.pathSeparator}ac_patches_key.priv');
    final pubKeyFile = File('${currentDir.path}${Platform.pathSeparator}ac_patches_key.pub');

    String pubKeyBase64;
    if (!privKeyFile.existsSync()) {
      print('🔑 Generating new Ed25519 signing keypair...');
      final keyPair = await AcPatchCrypto.generateKeyPair();
      final pubKey = await keyPair.extractPublicKey();
      final privBytes = await keyPair.extractPrivateKeyBytes();

      pubKeyBase64 = base64Encode(pubKey.bytes);
      final privKeyBase64 = base64Encode(privBytes);

      privKeyFile.writeAsStringSync(privKeyBase64);
      pubKeyFile.writeAsStringSync(pubKeyBase64);
      print('   Saved private key: ${privKeyFile.path}');
      print('   Saved public key:  ${pubKeyFile.path}');

      // Append private key to .gitignore if present
      final gitignoreFile = File('${currentDir.path}${Platform.pathSeparator}.gitignore');
      if (gitignoreFile.existsSync()) {
        final gitignoreContent = gitignoreFile.readAsStringSync();
        if (!gitignoreContent.contains('ac_patches_key.priv')) {
          gitignoreFile.writeAsStringSync('\n# ac_patches private signing key\nac_patches_key.priv\n', mode: FileMode.append);
          print('   Added ac_patches_key.priv to .gitignore');
        }
      }
    } else {
      pubKeyBase64 = pubKeyFile.existsSync() ? pubKeyFile.readAsStringSync().trim() : '';
      print('ℹ️ Using existing signing key: ${privKeyFile.path}');
    }

    // 2. Write ac_patches.yaml
    final config = AcPatchesProjectConfig(
      appId: appId,
      serverUrl: serverUrl,
      track: track,
      publicKey: pubKeyBase64,
    );
    config.save(currentDir);
    print('✅ Created ${AcPatchesProjectConfig.configFileName} successfully.');
    print('');
    print('Next steps:');
    print('1. Build your first base release:');
    print('   ac_patches release windows');
    print('2. When you modify Dart code, build and ship an OTA patch:');
    print('   ac_patches patch windows --publish');
  }
}
