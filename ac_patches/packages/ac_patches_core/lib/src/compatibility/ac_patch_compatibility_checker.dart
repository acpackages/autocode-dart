import '../enums/ac_enum_patch_architecture.dart';
import '../enums/ac_enum_patch_platform.dart';
import '../models/ac_patch_manifest.dart';
import '../models/ac_patch_release.dart';

class AcPatchCompatibilityResult {
  final bool isCompatible;
  final String? reason;

  const AcPatchCompatibilityResult.compatible()
      : isCompatible = true,
        reason = null;

  const AcPatchCompatibilityResult.incompatible(this.reason)
      : isCompatible = false;

  @override
  String toString() => isCompatible ? 'Compatible' : 'Incompatible: $reason';
}

class AcPatchCompatibilityChecker {
  /// Validates whether a patch manifest is compatible with the current running environment and base release.
  static AcPatchCompatibilityResult validate({
    required AcPatchManifest manifest,
    required String currentAppId,
    required AcEnumPatchPlatform currentPlatform,
    required AcEnumPatchArchitecture currentArchitecture,
    required AcPatchRelease baseRelease,
    int? currentActivePatchNumber,
  }) {
    if (manifest.formatVersion != 1) {
      return AcPatchCompatibilityResult.incompatible(
        'Unsupported patch format version: ${manifest.formatVersion}',
      );
    }

    if (manifest.appId != currentAppId) {
      return AcPatchCompatibilityResult.incompatible(
        'App ID mismatch: expected $currentAppId, got ${manifest.appId}',
      );
    }

    if (manifest.platform != currentPlatform) {
      return AcPatchCompatibilityResult.incompatible(
        'Platform mismatch: running on ${currentPlatform.value}, patch is for ${manifest.platform.value}',
      );
    }

    if (manifest.architecture != currentArchitecture) {
      return AcPatchCompatibilityResult.incompatible(
        'Architecture mismatch: running on ${currentArchitecture.value}, patch is for ${manifest.architecture.value}',
      );
    }

    if (manifest.releaseId != baseRelease.releaseId) {
      return AcPatchCompatibilityResult.incompatible(
        'Release ID mismatch: base is ${baseRelease.releaseId}, patch targets ${manifest.releaseId}',
      );
    }

    if (manifest.baseBuildNumber != baseRelease.buildNumber) {
      return AcPatchCompatibilityResult.incompatible(
        'Build number mismatch: base is ${baseRelease.buildNumber}, patch requires ${manifest.baseBuildNumber}',
      );
    }

    if (manifest.baseReleaseHash.isNotEmpty &&
        baseRelease.baseReleaseHash.isNotEmpty &&
        manifest.baseReleaseHash != baseRelease.baseReleaseHash) {
      return AcPatchCompatibilityResult.incompatible(
        'Base release hash mismatch: base=${baseRelease.baseReleaseHash}, patch expects=${manifest.baseReleaseHash}',
      );
    }

    if (currentActivePatchNumber != null &&
        manifest.patchNumber <= currentActivePatchNumber) {
      return AcPatchCompatibilityResult.incompatible(
        'Downgrade rejected: active patch number is $currentActivePatchNumber, incoming patch is ${manifest.patchNumber}',
      );
    }

    return const AcPatchCompatibilityResult.compatible();
  }
}
