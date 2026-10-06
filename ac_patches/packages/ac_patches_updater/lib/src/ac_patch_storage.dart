import 'dart:io';
import 'package:ac_patches_core/ac_patches_core.dart';

class AcPatchStorage {
  final Directory baseDir;

  AcPatchStorage({required this.baseDir});

  Directory get activeDir => Directory('${baseDir.path}${Platform.pathSeparator}active');
  Directory get pendingDir => Directory('${baseDir.path}${Platform.pathSeparator}pending');
  Directory get previousDir => Directory('${baseDir.path}${Platform.pathSeparator}previous');
  Directory get tempDir => Directory('${baseDir.path}${Platform.pathSeparator}temp');

  Directory get activeAssetsDir => Directory('${activeDir.path}${Platform.pathSeparator}assets');
  Directory get pendingAssetsDir => Directory('${pendingDir.path}${Platform.pathSeparator}assets');
  Directory get previousAssetsDir => Directory('${previousDir.path}${Platform.pathSeparator}assets');

  File get stateFile => File('${baseDir.path}${Platform.pathSeparator}ac_patches_state.json');

  /// Ensures necessary directories exist.
  Future<void> initialize() async {
    if (!baseDir.existsSync()) await baseDir.create(recursive: true);
    if (!activeDir.existsSync()) await activeDir.create(recursive: true);
    if (!pendingDir.existsSync()) await pendingDir.create(recursive: true);
    if (!previousDir.existsSync()) await previousDir.create(recursive: true);
    if (!tempDir.existsSync()) await tempDir.create(recursive: true);
  }

  /// Loads current persistent state or initializes a clean default state.
  AcPatchState loadState() {
    if (!stateFile.existsSync()) {
      final defaultState = AcPatchState();
      saveStateSync(defaultState);
      return defaultState;
    }
    try {
      final jsonStr = stateFile.readAsStringSync();
      return AcPatchState.fromJsonString(jsonStr);
    } catch (_) {
      final fallbackState = AcPatchState();
      saveStateSync(fallbackState);
      return fallbackState;
    }
  }

  /// Saves state atomically by writing to a temporary file and renaming it.
  Future<void> saveState(AcPatchState state) async {
    final tempFile = File('${baseDir.path}${Platform.pathSeparator}state_tmp.json');
    await tempFile.writeAsString(state.toJsonString(), flush: true);
    if (stateFile.existsSync()) {
      await stateFile.delete();
    }
    await tempFile.rename(stateFile.path);
  }

  /// Synchronous atomic state save.
  void saveStateSync(AcPatchState state) {
    final tempFile = File('${baseDir.path}${Platform.pathSeparator}state_tmp.json');
    tempFile.writeAsStringSync(state.toJsonString(), flush: true);
    if (stateFile.existsSync()) {
      stateFile.deleteSync();
    }
    tempFile.renameSync(stateFile.path);
  }

  /// Promotes a pending patch to active:
  /// Moves active -> previous, then pending -> active.
  Future<bool> promotePendingToActive(String snapshotFileName) async {
    final pendingSnapshot = File('${pendingDir.path}${Platform.pathSeparator}$snapshotFileName');
    final activeSnapshot = File('${activeDir.path}${Platform.pathSeparator}$snapshotFileName');
    final previousSnapshot = File('${previousDir.path}${Platform.pathSeparator}$snapshotFileName');

    final hasPendingSnapshot = pendingSnapshot.existsSync();
    final hasPendingAssets = pendingAssetsDir.existsSync();
    if (!hasPendingSnapshot && !hasPendingAssets) return false;

    // 1. Move active to previous (if exists)
    if (activeSnapshot.existsSync()) {
      if (previousSnapshot.existsSync()) {
        await previousSnapshot.delete();
      }
      await activeSnapshot.rename(previousSnapshot.path);
    }
    if (activeAssetsDir.existsSync()) {
      if (previousAssetsDir.existsSync()) {
        await previousAssetsDir.delete(recursive: true);
      }
      await activeAssetsDir.rename(previousAssetsDir.path);
    }

    // 2. Move pending to active
    if (hasPendingSnapshot) {
      await pendingSnapshot.rename(activeSnapshot.path);
    }
    if (hasPendingAssets) {
      await pendingAssetsDir.rename(activeAssetsDir.path);
    }

    // 3. Update state
    final state = loadState();
    state.knownGoodPatchId = state.activePatchId;
    state.activePatchId = state.pendingPatchId;
    state.activePatchNumber = state.pendingPatchNumber;
    state.pendingPatchId = null;
    state.pendingPatchNumber = 0;
    state.failureCount = 0;
    state.isHealthy = false; // Must be verified healthy after startup
    await saveState(state);

    return true;
  }

  /// Performs a rollback to the known-good previous patch or base release.
  Future<void> rollback(String snapshotFileName) async {
    final activeSnapshot = File('${activeDir.path}${Platform.pathSeparator}$snapshotFileName');
    final previousSnapshot = File('${previousDir.path}${Platform.pathSeparator}$snapshotFileName');

    // Delete broken active snapshot & active assets
    if (activeSnapshot.existsSync()) {
      await activeSnapshot.delete();
    }
    if (activeAssetsDir.existsSync()) {
      await activeAssetsDir.delete(recursive: true);
    }

    final state = loadState();

    // If previous snapshot or assets exist, restore them as active
    final hasPreviousSnapshot = previousSnapshot.existsSync();
    final hasPreviousAssets = previousAssetsDir.existsSync();

    if (hasPreviousSnapshot || hasPreviousAssets) {
      if (hasPreviousSnapshot) {
        await previousSnapshot.rename(activeSnapshot.path);
      }
      if (hasPreviousAssets) {
        await previousAssetsDir.rename(activeAssetsDir.path);
      }
      state.activePatchId = state.knownGoodPatchId;
      state.activePatchNumber = 1; // Or previous number
    } else {
      // Revert completely to base release
      state.activePatchId = null;
      state.activePatchNumber = 0;
      state.knownGoodPatchId = null;
    }

    state.failureCount = 0;
    state.isHealthy = true;
    state.pendingPatchId = null;
    await saveState(state);
  }

  /// Cleans temporary files.
  Future<void> cleanTemp() async {
    if (tempDir.existsSync()) {
      final files = tempDir.listSync();
      for (final f in files) {
        try {
          f.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  }
}
