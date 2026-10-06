import '../enums/ac_enum_patch_architecture.dart';
import '../enums/ac_enum_patch_platform.dart';

class AcPatchRelease {
  final String releaseId;
  final String appId;
  final String version;
  final int buildNumber;
  final AcEnumPatchPlatform platform;
  final AcEnumPatchArchitecture architecture;
  final String flutterVersion;
  final String dartVersion;
  final String engineRevision;
  final String baseReleaseHash;
  final DateTime createdAt;

  AcPatchRelease({
    required this.releaseId,
    required this.appId,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.architecture,
    required this.flutterVersion,
    required this.dartVersion,
    required this.engineRevision,
    required this.baseReleaseHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() {
    return {
      'releaseId': releaseId,
      'appId': appId,
      'version': version,
      'buildNumber': buildNumber,
      'platform': platform.value,
      'architecture': architecture.value,
      'flutterVersion': flutterVersion,
      'dartVersion': dartVersion,
      'engineRevision': engineRevision,
      'baseReleaseHash': baseReleaseHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AcPatchRelease.fromJson(Map<String, dynamic> json) {
    return AcPatchRelease(
      releaseId: json['releaseId'] as String,
      appId: json['appId'] as String,
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as int,
      platform: AcEnumPatchPlatform.fromValue(json['platform'] as String?) ??
          AcEnumPatchPlatform.windows,
      architecture:
          AcEnumPatchArchitecture.fromValue(json['architecture'] as String?) ??
              AcEnumPatchArchitecture.x86_64,
      flutterVersion: json['flutterVersion'] as String? ?? '',
      dartVersion: json['dartVersion'] as String? ?? '',
      engineRevision: json['engineRevision'] as String? ?? '',
      baseReleaseHash: json['baseReleaseHash'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
    );
  }
}
