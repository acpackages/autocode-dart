import '../enums/ac_enum_patch_architecture.dart';
import '../enums/ac_enum_patch_platform.dart';
import '../enums/ac_enum_patch_track.dart';

class AcPatchCheckRequest {
  final String appId;
  final AcEnumPatchPlatform platform;
  final AcEnumPatchArchitecture architecture;
  final String releaseId;
  final int buildNumber;
  final String? currentPatchId;
  final int currentPatchNumber;
  final AcEnumPatchTrack track;
  final String installationId;

  AcPatchCheckRequest({
    required this.appId,
    required this.platform,
    required this.architecture,
    required this.releaseId,
    required this.buildNumber,
    this.currentPatchId,
    this.currentPatchNumber = 0,
    this.track = AcEnumPatchTrack.stable,
    required this.installationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'platform': platform.value,
      'architecture': architecture.value,
      'releaseId': releaseId,
      'buildNumber': buildNumber,
      'currentPatchId': currentPatchId,
      'currentPatchNumber': currentPatchNumber,
      'track': track.value,
      'installationId': installationId,
    };
  }

  factory AcPatchCheckRequest.fromJson(Map<String, dynamic> json) {
    return AcPatchCheckRequest(
      appId: json['appId'] as String,
      platform: AcEnumPatchPlatform.fromValue(json['platform'] as String?) ??
          AcEnumPatchPlatform.windows,
      architecture:
          AcEnumPatchArchitecture.fromValue(json['architecture'] as String?) ??
              AcEnumPatchArchitecture.x86_64,
      releaseId: json['releaseId'] as String,
      buildNumber: json['buildNumber'] as int,
      currentPatchId: json['currentPatchId'] as String?,
      currentPatchNumber: json['currentPatchNumber'] as int? ?? 0,
      track: AcEnumPatchTrack.fromValue(json['track'] as String?) ??
          AcEnumPatchTrack.stable,
      installationId: json['installationId'] as String? ?? 'unknown',
    );
  }
}

class AcPatchCheckResponse {
  final bool available;
  final String? patchId;
  final int? patchNumber;
  final String? releaseId;
  final String? downloadUrl;
  final int? size;
  final String? hash;
  final String? signature;
  final bool mandatory;
  final String? minRuntimeVersion;

  AcPatchCheckResponse({
    required this.available,
    this.patchId,
    this.patchNumber,
    this.releaseId,
    this.downloadUrl,
    this.size,
    this.hash,
    this.signature,
    this.mandatory = false,
    this.minRuntimeVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      if (patchId != null) 'patchId': patchId,
      if (patchNumber != null) 'patchNumber': patchNumber,
      if (releaseId != null) 'releaseId': releaseId,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      if (size != null) 'size': size,
      if (hash != null) 'hash': hash,
      if (signature != null) 'signature': signature,
      'mandatory': mandatory,
      if (minRuntimeVersion != null) 'minRuntimeVersion': minRuntimeVersion,
    };
  }

  factory AcPatchCheckResponse.fromJson(Map<String, dynamic> json) {
    return AcPatchCheckResponse(
      available: json['available'] as bool? ?? false,
      patchId: json['patchId'] as String?,
      patchNumber: json['patchNumber'] as int?,
      releaseId: json['releaseId'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      size: json['size'] as int?,
      hash: json['hash'] as String?,
      signature: json['signature'] as String?,
      mandatory: json['mandatory'] as bool? ?? false,
      minRuntimeVersion: json['minRuntimeVersion'] as String?,
    );
  }

  factory AcPatchCheckResponse.noUpdate() {
    return AcPatchCheckResponse(available: false);
  }
}
