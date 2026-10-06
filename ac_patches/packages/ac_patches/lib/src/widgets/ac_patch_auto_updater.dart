import 'package:flutter/widgets.dart';
import 'package:ac_patches_core/ac_patches_core.dart';
import 'package:ac_patches_updater/ac_patches_updater.dart';
import '../bundle/ac_patch_asset_bundle.dart';

/// A widget that automatically checks for OTA patches on app startup and when returning to foreground.
class AcPatchAutoUpdater extends StatefulWidget {
  final Widget child;
  final bool autoDownload;
  final bool enableAssetPatching;
  final void Function(AcPatchCheckResponse response)? onUpdateAvailable;
  final void Function(AcPatchState state)? onDownloadComplete;
  final void Function(Object error)? onError;

  const AcPatchAutoUpdater({
    super.key,
    required this.child,
    this.autoDownload = true,
    this.enableAssetPatching = true,
    this.onUpdateAvailable,
    this.onDownloadComplete,
    this.onError,
  });

  @override
  State<AcPatchAutoUpdater> createState() => _AcPatchAutoUpdaterState();
}

class _AcPatchAutoUpdaterState extends State<AcPatchAutoUpdater> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdate();
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final hasUpdate = await AcPatches.instance.checkForUpdate();
      if (hasUpdate) {
        final update = AcPatches.instance.availableUpdate;
        if (update != null) {
          widget.onUpdateAvailable?.call(update);
        }
        if (widget.autoDownload) {
          final success = await AcPatches.instance.downloadUpdate();
          if (success) {
            widget.onDownloadComplete?.call(AcPatches.instance.state);
          }
        }
      }
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDir = AcPatches.instance.activeDirectory;
    if (widget.enableAssetPatching && activeDir != null) {
      return DefaultAssetBundle(
        bundle: AcPatchAssetBundle(activePatchesDir: activeDir),
        child: widget.child,
      );
    }
    return widget.child;
  }
}

