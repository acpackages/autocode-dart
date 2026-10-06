import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import '../config/ac_patches_project_config.dart';

class StatusCommand extends Command {
  @override
  final String name = 'status';

  @override
  final String description = 'Displays the current releases, active tracks, patches, and deployment statistics.';

  StatusCommand() {
    argParser.addOption('app-id', abbr: 'a', help: 'Target application ID (defaults to ac_patches.yaml).');
  }

  @override
  Future<void> run() async {
    final currentDir = Directory.current;
    final config = AcPatchesProjectConfig.load(currentDir);
    final appId = (argResults?['app-id'] as String?) ?? config?.appId;

    if (config == null && (appId == null || appId.isEmpty)) {
      print('❌ Error: No ${AcPatchesProjectConfig.configFileName} found and no --app-id specified.');
      exitCode = 1;
      return;
    }

    final serverUrl = config?.serverUrl ?? 'http://localhost:8080';
    print('📊 Fetching ac_patches status for "$appId" from $serverUrl...\n');

    try {
      final uri = Uri.parse('$serverUrl/api/v1/patch/status?appId=$appId');
      final resp = await http.get(uri).timeout(const Duration(seconds: 5));

      if (resp.statusCode != 200) {
        print('❌ Server returned HTTP ${resp.statusCode}: ${resp.body}');
        exitCode = 1;
        return;
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final releases = (data['releases'] as List?) ?? [];
      final tracks = (data['tracks'] as List?) ?? [];
      final patches = (data['patches'] as List?) ?? [];
      final deviceCount = data['deviceCount'] ?? 0;
      final recentEvents = (data['recentEvents'] as List?) ?? [];

      print('===============================================================');
      print('📱 APPLICATION: $appId');
      print('👥 Total Active Devices: $deviceCount');
      print('===============================================================\n');

      print('🚀 RELEASE TRACKS:');
      if (tracks.isEmpty) {
        print('   (No tracks configured)');
      } else {
        for (final t in tracks) {
          final trackName = t['name'] ?? 'default';
          final currPatch = (t['current_patch_id'] as String?) ?? 'None (Base Release)';
          final rollout = t['rollout_percentage'] ?? 100;
          print('   • Track: ${trackName.toString().padRight(12)} Active Patch: ${currPatch.padRight(20)} Rollout: $rollout%');
        }
      }
      print('');

      print('📦 RELEASES:');
      if (releases.isEmpty) {
        print('   (No base releases registered)');
      } else {
        for (final r in releases) {
          final relId = r['release_id'] ?? '';
          final plat = r['platform'] ?? '';
          final baseHash = (r['base_release_hash'] as String?) ?? '';
          final shortHash = baseHash.length > 20 ? '${baseHash.substring(0, 19)}...' : baseHash;
          print('   • Release: ${relId.padRight(12)} Platform: ${plat.padRight(10)} Base Hash: $shortHash');
        }
      }
      print('');

      print('⚡ PATCHES:');
      if (patches.isEmpty) {
        print('   (No patches uploaded)');
      } else {
        for (final p in patches) {
          final patchId = p['patch_id'] ?? '';
          final relId = p['release_id'] ?? '';
          final size = p['size_bytes'] ?? 0;
          final status = p['status'] ?? 'unknown';
          print('   • Patch: ${patchId.padRight(18)} Base: ${relId.padRight(12)} Size: ${(size / 1024).toStringAsFixed(1)} KB   Status: $status');
        }
      }
      print('');

      if (recentEvents.isNotEmpty) {
        print('📜 RECENT TELEMETRY EVENTS:');
        for (final e in recentEvents.take(5)) {
          final type = e['event_type'] ?? '';
          final patch = e['patch_id'] ?? '';
          final time = e['created_at'] ?? '';
          print('   [$time] Event: ${type.toString().padRight(12)} Patch: $patch');
        }
        print('');
      }
    } catch (e) {
      print('❌ Failed to connect to server: $e');
      exitCode = 1;
    }
  }
}
