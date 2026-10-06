import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import '../config/ac_patches_project_config.dart';

class PublishCommand extends Command {
  @override
  final String name = 'publish';

  @override
  final String description = 'Publishes an uploaded patch to a release track.';

  PublishCommand() {
    argParser.addOption('patch-id', abbr: 'p', help: 'Patch identifier to publish.');
    argParser.addOption('track', abbr: 't', defaultsTo: 'stable', help: 'Release track name.');
    argParser.addOption('rollout', abbr: 'r', defaultsTo: '100', help: 'Rollout percentage (1-100).');
  }

  @override
  Future<void> run() async {
    final currentDir = Directory.current;
    final config = AcPatchesProjectConfig.load(currentDir);
    if (config == null) {
      print('❌ Error: No ${AcPatchesProjectConfig.configFileName} found. Run ac_patches init first.');
      exitCode = 1;
      return;
    }

    final patchId = argResults?['patch-id'] as String?;
    if (patchId == null || patchId.isEmpty) {
      print('❌ Error: Missing --patch-id option.');
      exitCode = 1;
      return;
    }

    final track = (argResults?['track'] as String?) ?? config.track;
    final rollout = int.tryParse(argResults?['rollout'] as String? ?? '100') ?? 100;

    print('🚀 Promoting patch $patchId to "$track" track ($rollout% rollout)...');

    try {
      final publishUri = Uri.parse('${config.serverUrl}/api/v1/patch/publish');
      final resp = await http.post(
        publishUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patchId': patchId,
          'track': track,
          'rolloutPercentage': rollout,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('✅ Patch $patchId is now LIVE on track "$track" at $rollout% rollout!');
      } else {
        print('❌ Failed to publish (${resp.statusCode}): ${resp.body}');
        exitCode = 1;
      }
    } catch (e) {
      print('❌ Error connecting to server: $e');
      exitCode = 1;
    }
  }
}
