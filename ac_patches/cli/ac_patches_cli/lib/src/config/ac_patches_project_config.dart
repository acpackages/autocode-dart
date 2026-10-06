import 'dart:io';
import 'package:yaml/yaml.dart';

class AcPatchesProjectConfig {
  final String appId;
  final String serverUrl;
  final String track;
  final String publicKey;
  final String? privateKey;

  AcPatchesProjectConfig({
    required this.appId,
    required this.serverUrl,
    this.track = 'stable',
    required this.publicKey,
    this.privateKey,
  });

  static const String configFileName = 'ac_patches.yaml';

  static AcPatchesProjectConfig? load(Directory projectDir) {
    final configFile = File('${projectDir.path}${Platform.pathSeparator}$configFileName');
    if (!configFile.existsSync()) {
      return null;
    }

    final content = configFile.readAsStringSync();
    final yaml = loadYaml(content) as Map?;
    if (yaml == null) return null;

    return AcPatchesProjectConfig(
      appId: (yaml['app_id'] as String?) ?? '',
      serverUrl: (yaml['server_url'] as String?) ?? 'http://localhost:8080',
      track: (yaml['track'] as String?) ?? 'stable',
      publicKey: (yaml['public_key'] as String?) ?? '',
      privateKey: yaml['private_key'] as String?,
    );
  }

  void save(Directory projectDir) {
    final configFile = File('${projectDir.path}${Platform.pathSeparator}$configFileName');
    final buffer = StringBuffer();
    buffer.writeln('# ac_patches project configuration');
    buffer.writeln('app_id: $appId');
    buffer.writeln('server_url: $serverUrl');
    buffer.writeln('track: $track');
    buffer.writeln('public_key: $publicKey');
    if (privateKey != null && privateKey!.isNotEmpty) {
      buffer.writeln('private_key: $privateKey');
    }
    configFile.writeAsStringSync(buffer.toString());
  }
}
