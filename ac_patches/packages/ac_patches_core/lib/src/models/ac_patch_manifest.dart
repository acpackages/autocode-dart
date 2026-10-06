import 'dart:convert';
import 'dart:typed_data';
import '../enums/ac_enum_patch_architecture.dart';
import '../enums/ac_enum_patch_platform.dart';
import '../enums/ac_enum_patch_type.dart';

class AcPatchManifest {
  final int formatVersion;
  final String appId;
  final String releaseId;
  final String patchId;
  final int patchNumber;
  final AcEnumPatchType patchType;
  final AcEnumPatchPlatform platform;
  final AcEnumPatchArchitecture architecture;
  final String flutterVersion;
  final String dartVersion;
  final String engineRevision;
  final int baseBuildNumber;
  final String baseReleaseHash;
  final String payloadHash;
  final int payloadSize;
  final DateTime createdAt;
  final String minRuntimeVersion;
  final String? maxRuntimeVersion;
  final bool mandatory;
  String signature;

  AcPatchManifest({
    this.formatVersion = 1,
    required this.appId,
    required this.releaseId,
    required this.patchId,
    required this.patchNumber,
    this.patchType = AcEnumPatchType.dartApplication,
    required this.platform,
    required this.architecture,
    required this.flutterVersion,
    required this.dartVersion,
    required this.engineRevision,
    required this.baseBuildNumber,
    required this.baseReleaseHash,
    required this.payloadHash,
    required this.payloadSize,
    DateTime? createdAt,
    this.minRuntimeVersion = '1.0.0',
    this.maxRuntimeVersion,
    this.mandatory = false,
    this.signature = '',
  }) : createdAt = createdAt ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson({bool includeSignature = true}) {
    final map = <String, dynamic>{
      'formatVersion': formatVersion,
      'appId': appId,
      'releaseId': releaseId,
      'patchId': patchId,
      'patchNumber': patchNumber,
      'patchType': patchType.value,
      'platform': platform.value,
      'architecture': architecture.value,
      'flutterVersion': flutterVersion,
      'dartVersion': dartVersion,
      'engineRevision': engineRevision,
      'baseBuildNumber': baseBuildNumber,
      'baseReleaseHash': baseReleaseHash,
      'payloadHash': payloadHash,
      'payloadSize': payloadSize,
      'createdAt': createdAt.toIso8601String(),
      'minRuntimeVersion': minRuntimeVersion,
      'maxRuntimeVersion': maxRuntimeVersion,
      'mandatory': mandatory,
    };
    if (includeSignature) {
      map['signature'] = signature;
    }
    return map;
  }

  /// Returns UTF-8 bytes of canonical JSON for signing and verification (without the signature field).
  Uint8List toSignableBytes() {
    final jsonStr = jsonEncode(toJson(includeSignature: false));
    return Uint8List.fromList(utf8.encode(jsonStr));
  }

  factory AcPatchManifest.fromJson(Map<String, dynamic> json) {
    return AcPatchManifest(
      formatVersion: json['formatVersion'] as int? ?? 1,
      appId: json['appId'] as String,
      releaseId: json['releaseId'] as String,
      patchId: json['patchId'] as String,
      patchNumber: json['patchNumber'] as int? ?? 1,
      patchType: AcEnumPatchType.fromValue(json['patchType'] as String?) ??
          AcEnumPatchType.dartApplication,
      platform: AcEnumPatchPlatform.fromValue(json['platform'] as String?) ??
          AcEnumPatchPlatform.windows,
      architecture:
          AcEnumPatchArchitecture.fromValue(json['architecture'] as String?) ??
              AcEnumPatchArchitecture.x86_64,
      flutterVersion: json['flutterVersion'] as String? ?? '',
      dartVersion: json['dartVersion'] as String? ?? '',
      engineRevision: json['engineRevision'] as String? ?? '',
      baseBuildNumber: json['baseBuildNumber'] as int? ?? 0,
      baseReleaseHash: json['baseReleaseHash'] as String? ?? '',
      payloadHash: json['payloadHash'] as String? ?? '',
      payloadSize: json['payloadSize'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
      minRuntimeVersion: json['minRuntimeVersion'] as String? ?? '1.0.0',
      maxRuntimeVersion: json['maxRuntimeVersion'] as String?,
      mandatory: json['mandatory'] as bool? ?? false,
      signature: json['signature'] as String? ?? '',
    );
  }
}
