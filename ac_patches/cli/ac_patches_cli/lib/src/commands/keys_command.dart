import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:ac_patches_core/ac_patches_core.dart';

class KeysCommand extends Command {
  @override
  final String name = 'keys';

  @override
  final String description = 'Manage cryptographic signing keys for OTA patches.';

  KeysCommand() {
    addSubcommand(KeysGenerateSubcommand());
  }
}

class KeysGenerateSubcommand extends Command {
  @override
  final String name = 'generate';

  @override
  final String description = 'Generates a new Ed25519 signing keypair.';

  KeysGenerateSubcommand() {
    argParser.addOption('output-dir', abbr: 'o', help: 'Directory to save keys.');
  }

  @override
  Future<void> run() async {
    print('🔑 Generating new Ed25519 keypair...');
    final keyPair = await AcPatchCrypto.generateKeyPair();
    final pubKey = await keyPair.extractPublicKey();
    final privBytes = await keyPair.extractPrivateKeyBytes();

    final pubBase64 = base64Encode(pubKey.bytes);
    final privBase64 = base64Encode(privBytes);

    final outDirStr = argResults?['output-dir'] as String?;
    if (outDirStr != null) {
      final outDir = Directory(outDirStr);
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
      final privFile = File('${outDir.path}${Platform.pathSeparator}ac_patches_key.priv');
      final pubFile = File('${outDir.path}${Platform.pathSeparator}ac_patches_key.pub');
      privFile.writeAsStringSync(privBase64);
      pubFile.writeAsStringSync(pubBase64);
      print('✅ Keys saved to:');
      print('   Private: ${privFile.path}');
      print('   Public:  ${pubFile.path}');
    } else {
      print('');
      print('Private Key (keep secret!):');
      print(privBase64);
      print('');
      print('Public Key (configure in ac_patches.yaml):');
      print(pubBase64);
    }
  }
}
