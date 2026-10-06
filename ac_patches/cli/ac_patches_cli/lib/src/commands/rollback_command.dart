import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import '../config/ac_patches_project_config.dart';

class RollbackCommand extends Command {
  @override
  final String name = 'rollback';

  @override
  final String description = 'Rolls back a patch track to a previous patch or base release.';

  RollbackCommand() {
    argParser.addOption('track', abbr: 't', defaultsTo: 'stable', help: 'Release track to roll back.');
    argParser.addOption('target-patch-id', abbr: 'p', help: 'Target patch ID to roll back to (leave blank to revert to base release).');
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

    final track = (argResults?['track'] as String?) ?? config.track;
    final targetPatchId = argResults?['target-patch-id'] as String?;

    print('⏪ Initiating rollback for track "$track" of ${config.appId}...');

    try {
      final rollbackUri = Uri.parse('${config.serverUrl}/api/v1/patch/rollback');
      final resp = await http.post(
        rollbackUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appId': config.appId,
          'track': track,
          'targetPatchId': targetPatchId,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (targetPatchId != null && targetPatchId.isNotEmpty) {
          print('✅ Track "$track" rolled back to patch: $targetPatchId');
        } else {
          print('✅ Track "$track" rolled back to base release (all patches deactivated)!');
        }
      } else {
        print('❌ Rollback failed (${resp.statusCode}): ${resp.body}');
        exitCode = 1;
      }
    } catch (e) {
      print('❌ Error connecting to server: $e');
      exitCode = 1;
    }
  }
}
