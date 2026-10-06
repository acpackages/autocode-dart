# Asset Patching Architecture & Feasibility Design

## 1. Overview
In Flutter, application assets (images, fonts, JSON configs, shaders) are packaged inside `data/flutter_assets/` (Windows/Linux) or `assets/flutter_assets/` (Android APK/AAB).

The initial version of `ac_patches` focuses strictly on **Dart application code updates** (`app.so`). This document describes how asset patching can be implemented in future iterations using the existing `ACP1` format and protocol.

---

## 2. Technical Mechanisms for Asset Patching

### Approach A: Custom `AssetBundle` Provider (Client-Side, No Native Changes)
Flutter provides a pluggable asset loading architecture through `DefaultAssetBundle`:
```dart
class AcPatchAssetBundle extends PlatformAssetBundle {
  final Directory activePatchesDir;
  AcPatchAssetBundle({required this.activePatchesDir});

  @override
  Future<ByteData> load(String key) async {
    final patchFile = File('${activePatchesDir.path}/assets/$key');
    if (patchFile.existsSync()) {
      final bytes = await patchFile.readAsBytes();
      return ByteData.sublistView(bytes);
    }
    // Fall back to original base assets
    return super.load(key);
  }
}
```
Injecting this at the top of the widget tree:
```dart
DefaultAssetBundle(
  bundle: AcPatchAssetBundle(activePatchesDir: patchesDir),
  child: const MyApp(),
);
```
* **Pros**: 100% cross-platform, zero native engine modifications required, works on all platforms including iOS.
* **Cons**: Does not automatically patch fonts registered at the OS level or native app icons.

### Approach B: Native Embedder Asset Directory Override (Desktop/Android)
On desktop (Windows, Linux, macOS) and Android, the C++ / Java embedding allows overriding the `assets_path` passed to `flutter::DartProject(assets_path, icu_path, aot_path)`.
* By combining patched assets and base assets into a cached folder or using symlinks/overlayfs, the engine loads all assets natively.

---

## 3. Protocol & Format Support in `ac_patches`

The `ac_patches` core architecture is already designed to support asset patches:
1. **`AcEnumPatchType`**:
   ```dart
   enum AcEnumPatchType {
     dartApplicationPatch('dart_application'),
     assetPatch('asset'),
     hybridPatch('hybrid');
   }
   ```
2. **`AcPatchManifest`**: Contains `patchType` field.
3. **`ACP1` Binary Envelope**: Can encapsulate a ZIP/tar.gz archive of patched assets as payload instead of `app.so`.

---

## 4. Rollout Strategy
When asset patching is released, it will reuse the exact same:
- Server endpoints (`/check`, `/upload`, `/publish`, `/download`, `/rollback`)
- Ed25519 cryptographic signing
- Rollout percentage logic
- Crash protection and rollback mechanism
