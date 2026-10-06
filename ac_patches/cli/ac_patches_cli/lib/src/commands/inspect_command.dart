import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import '../config/ac_patches_project_config.dart';

class InspectCommand extends Command {
  @override
  final String name = 'inspect';

  @override
  final String description = 'Inspects an ACP1 patch archive file and verifies its cryptographic signature.';

  InspectCommand() {
    argParser.addOption('public-key', abbr: 'k', help: 'Base64 Ed25519 public key to verify against.');
  }

  @override
  Future<void> run() async {
    final args = argResults?.rest ?? [];
    if (args.isEmpty) {
      print('❌ Error: Path to an .acp1 patch archive required. Example: ac_patches inspect build/ac_patches/1.0.0+1-p1.acp1');
      exitCode = 1;
      return;
    }

    final filePath = args.first;
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ Error: File not found: $filePath');
      exitCode = 1;
      return;
    }

    print('🔍 Inspecting patch archive: ${file.path} (${file.lengthSync()} bytes)...\n');

    try {
      final bytes = file.readAsBytesSync();
      final package = AcPatchArchive.unpack(bytes);
      final manifest = package.manifest;

      print('===============================================================');
      print('📦 ACP1 PATCH ENVELOPE DETAILS');
      print('===============================================================');
      print('Format Version:    ${manifest.formatVersion}');
      print('Patch ID:          ${manifest.patchId}');
      print('Patch Number:      ${manifest.patchNumber}');
      print('Target App ID:     ${manifest.appId}');
      print('Target Release:    ${manifest.releaseId} (Build: ${manifest.baseBuildNumber})');
      print('Target Platform:   ${manifest.platform.value} (${manifest.architecture.value})');
      print('Flutter Version:   ${manifest.flutterVersion}');
      print('Dart Version:      ${manifest.dartVersion}');
      print('Engine Revision:   ${manifest.engineRevision}');
      print('Base Release Hash: ${manifest.baseReleaseHash}');
      print('Payload Hash:      ${manifest.payloadHash}');
      print('Payload Size:      ${package.payload.length} bytes (uncompressed)');
      print('Compression:       ${package.compression == 1 ? "GZIP" : "NONE"}');
      print('Created At:        ${manifest.createdAt}');
      print('');

      // Public key verification
      final currentDir = Directory.current;
      final config = AcPatchesProjectConfig.load(currentDir);
      final pubKeyArg = (argResults?['public-key'] as String?) ?? config?.publicKey;

      if (pubKeyArg != null && pubKeyArg.isNotEmpty) {
        print('🔐 Verifying Ed25519 Cryptographic Signature...');
        final pubKeyBytes = base64Decode(pubKeyArg.trim());
        final isValid = await package.verifySignature(pubKeyBytes);

        if (isValid) {
          print('✅ SIGNATURE VERIFIED: Patch is authentic and unaltered!');
        } else {
          print('❌ SIGNATURE INVALID: Patch payload or manifest does NOT match public key!');
          exitCode = 1;
        }
      } else {
        print('ℹ️ No public key provided. Pass --public-key or run within an initialized project to verify signature.');
      }
    } catch (e) {
      print('❌ Error unpacking archive: $e');
      exitCode = 1;
    }
  }
}
