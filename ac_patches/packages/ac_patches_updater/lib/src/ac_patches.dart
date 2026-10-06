import 'dart:convert';
import 'dart:io';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_format/ac_patches_format.dart';
import 'ac_patch_client.dart';
import 'ac_patch_storage.dart';

class AcPatches {
  static final AcPatches instance = AcPatches._internal();
  AcPatches._internal();

  late AcPatchStorage _storage;
  late AcPatchClient _client;
  late String _appId;
  late String _releaseId;
  late int _buildNumber;
  late String _baseReleaseHash;
  late String _publicKeyBase64;
  late AcEnumPatchPlatform _platform;
  late AcEnumPatchArchitecture _architecture;
  late AcEnumPatchTrack _track;
  late String _installationId;
  late String _snapshotFileName;

  bool _initialized = false;
  AcEnumClientPatchState _status = AcEnumClientPatchState.none;
  AcPatchCheckResponse? _availableUpdate;

  AcEnumClientPatchState get status => _status;
  AcPatchState get state => _storage.loadState();
  AcPatchCheckResponse? get availableUpdate => _availableUpdate;
  AcPatchStorage get storage => _storage;
  Directory? get activeDirectory => _initialized ? _storage.activeDir : null;

  /// Initializes the AcPatches runtime.
  /// This must be called at app startup before any background checks.
  Future<void> initialize({
    required String serverUrl,
    required String appId,
    required String releaseId,
    required int buildNumber,
    required String baseReleaseHash,
    required String publicKeyBase64,
    required AcEnumPatchPlatform platform,
    required AcEnumPatchArchitecture architecture,
    required Directory patchesDirectory,
    AcEnumPatchTrack track = AcEnumPatchTrack.stable,
    String? installationId,
    String snapshotFileName = 'app.so',
    int maxFailuresThreshold = 3,
  }) async {
    _appId = appId;
    _releaseId = releaseId;
    _buildNumber = buildNumber;
    _baseReleaseHash = baseReleaseHash;
    _publicKeyBase64 = publicKeyBase64;
    _platform = platform;
    _architecture = architecture;
    _track = track;
    _snapshotFileName = snapshotFileName;
    _installationId = installationId ?? 'device_${Platform.localHostname}';

    _storage = AcPatchStorage(baseDir: patchesDirectory);
    await _storage.initialize();

    _client = AcPatchClient(serverUrl: serverUrl);

    // 1. Check local state & crash counter
    final currentState = _storage.loadState();
    currentState.maxFailuresThreshold = maxFailuresThreshold;

    if (currentState.activePatchId != null) {
      if (currentState.failureCount >= currentState.maxFailuresThreshold) {
        // Crash threshold exceeded -> Automatic rollback!
        await _storage.rollback(_snapshotFileName);
        _status = AcEnumClientPatchState.rolledBack;

        // Report telemetry
        await _client.reportEvent(
          AcPatchReportRequest(
            installationId: _installationId,
            appId: _appId,
            patchId: currentState.activePatchId!,
            releaseId: _releaseId,
            eventType: 'rolled_back',
            errorMessage: 'Crash threshold exceeded (${currentState.failureCount} failed launches)',
          ),
        );
      } else {
        // Increment launch failure counter (will be reset when markHealthy() is called)
        currentState.failureCount += 1;
        currentState.lastLaunchTime = DateTime.now().toUtc();
        await _storage.saveState(currentState);
        _status = AcEnumClientPatchState.active;
      }
    } else {
      _status = AcEnumClientPatchState.none;
    }

    _initialized = true;
  }

  /// Confirms that the current active patch launched and functioned properly.
  /// Resets the failure counter to 0 and marks the patch healthy.
  Future<void> markHealthy() async {
    if (!_initialized) return;

    final currentState = _storage.loadState();
    if (currentState.activePatchId != null) {
      currentState.failureCount = 0;
      currentState.isHealthy = true;
      currentState.knownGoodPatchId = currentState.activePatchId;
      await _storage.saveState(currentState);
      _status = AcEnumClientPatchState.healthy;

      // Report healthy activation
      await _client.reportEvent(
        AcPatchReportRequest(
          installationId: _installationId,
          appId: _appId,
          patchId: currentState.activePatchId!,
          releaseId: _releaseId,
          eventType: 'healthy',
        ),
      );
    }
  }

  /// Checks the update server for a compatible new patch.
  Future<bool> checkForUpdate() async {
    if (!_initialized) return false;

    _status = AcEnumClientPatchState.checking;
    final currentState = _storage.loadState();

    try {
      final response = await _client.checkForUpdate(
        AcPatchCheckRequest(
          appId: _appId,
          platform: _platform,
          architecture: _architecture,
          releaseId: _releaseId,
          buildNumber: _buildNumber,
          currentPatchId: currentState.activePatchId,
          currentPatchNumber: currentState.activePatchNumber,
          track: _track,
          installationId: _installationId,
        ),
      );

      if (response.available && response.downloadUrl != null) {
        _availableUpdate = response;
        _status = AcEnumClientPatchState.available;
        return true;
      } else {
        _availableUpdate = null;
        _status = currentState.activePatchId != null
            ? AcEnumClientPatchState.active
            : AcEnumClientPatchState.none;
        return false;
      }
    } catch (_) {
      _status = currentState.activePatchId != null
          ? AcEnumClientPatchState.active
          : AcEnumClientPatchState.none;
      return false;
    }
  }

  /// Downloads the available update, verifies signature and compatibility, and marks it pending.
  Future<bool> downloadUpdate() async {
    if (!_initialized || _availableUpdate == null) return false;

    final update = _availableUpdate!;
    _status = AcEnumClientPatchState.downloading;

    final tempFile = File('${_storage.tempDir.path}${Platform.pathSeparator}update.acp1');
    try {
      await _client.downloadPatch(
        downloadUrl: update.downloadUrl!,
        targetFile: tempFile,
      );

      _status = AcEnumClientPatchState.downloaded;

      // 1. Unpack archive
      final package = await AcPatchArchive.unpackFromFile(tempFile);

      // 2. Verify Ed25519 signature
      final pubKeyBytes = base64Decode(_publicKeyBase64.trim());
      final isSigValid = await package.verifySignature(pubKeyBytes);
      if (!isSigValid) {
        throw Exception('Patch signature verification failed!');
      }

      // 3. Verify compatibility
      final baseRelease = AcPatchRelease(
        releaseId: _releaseId,
        appId: _appId,
        version: _releaseId.split('+').first,
        buildNumber: _buildNumber,
        platform: _platform,
        architecture: _architecture,
        flutterVersion: '',
        dartVersion: '',
        engineRevision: '',
        baseReleaseHash: _baseReleaseHash,
      );

      final currentState = _storage.loadState();
      final compat = AcPatchCompatibilityChecker.validate(
        manifest: package.manifest,
        currentAppId: _appId,
        currentPlatform: _platform,
        currentArchitecture: _architecture,
        baseRelease: baseRelease,
        currentActivePatchNumber: currentState.activePatchNumber,
      );

      if (!compat.isCompatible) {
        throw Exception('Patch incompatible: ${compat.reason}');
      }

      // 4. Write payload to pending directory
      if (package.manifest.patchType == AcEnumPatchType.asset) {
        final pendingAssets = _storage.pendingAssetsDir;
        if (pendingAssets.existsSync()) {
          await pendingAssets.delete(recursive: true);
        }
        await pendingAssets.create(recursive: true);
        final bundle = AcAssetArchive.unpack(package.payload);
        await bundle.extractToDirectory(pendingAssets);
      } else {
        final pendingSnapshot = File('${_storage.pendingDir.path}${Platform.pathSeparator}$_snapshotFileName');
        await pendingSnapshot.writeAsBytes(package.payload, flush: true);
      }

      // 5. Update state to pending
      currentState.pendingPatchId = package.manifest.patchId;
      currentState.pendingPatchNumber = package.manifest.patchNumber;
      await _storage.saveState(currentState);

      _status = AcEnumClientPatchState.pending;

      // Report downloaded event
      await _client.reportEvent(
        AcPatchReportRequest(
          installationId: _installationId,
          appId: _appId,
          patchId: package.manifest.patchId,
          releaseId: _releaseId,
          eventType: 'downloaded',
        ),
      );

      await _storage.cleanTemp();
      return true;
    } catch (e) {
      _status = AcEnumClientPatchState.failed;
      await _storage.cleanTemp();
      return false;
    }
  }

  /// Promotes any pending patch so that it becomes active upon next application restart.
  Future<bool> activateOnRestart() async {
    if (!_initialized) return false;
    return await _storage.promotePendingToActive(_snapshotFileName);
  }
}
