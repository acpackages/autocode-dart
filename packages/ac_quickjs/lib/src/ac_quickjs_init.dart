import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'frb/frb_generated.dart';

/// Manages native library resolution and initialization for `ac_quickjs`.
class AcQuickJs {
  AcQuickJs._();

  /// Returns whether the underlying native QuickJS library is loaded and initialized.
  static bool get isInitialized => LibFjs.instance.initialized;

  /// Initializes the QuickJS engine native bindings.
  ///
  /// You can optionally provide a custom [libraryPath] or [externalLibrary].
  /// If omitted, [AcQuickJs] automatically searches:
  /// 1. `AC_QUICKJS_LIB_PATH` environment variable
  /// 2. `FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR` environment variable
  /// 3. Bundled `native/<platform>/<arch>/` directories relative to the script or package
  /// 4. Current working directory
  /// 5. Standard OS system dynamic library lookup paths
  static Future<void> init({
    String? libraryPath,
    ExternalLibrary? externalLibrary,
    bool forceSameCodegenVersion = false,
  }) async {
    if (LibFjs.instance.initialized) return;

    if (externalLibrary != null) {
      await LibFjs.init(
        externalLibrary: externalLibrary,
        forceSameCodegenVersion: forceSameCodegenVersion,
      );
      return;
    }

    if (libraryPath != null) {
      await LibFjs.init(
        externalLibrary: ExternalLibrary.open(libraryPath),
        forceSameCodegenVersion: forceSameCodegenVersion,
      );
      return;
    }

    final resolved = _resolveNativeLibrary();
    if (resolved != null) {
      await LibFjs.init(
        externalLibrary: resolved,
        forceSameCodegenVersion: forceSameCodegenVersion,
      );
    } else {
      await LibFjs.init(
        forceSameCodegenVersion: forceSameCodegenVersion,
      );
    }
  }

  /// Automatically resolves the bundled or platform native library.
  static ExternalLibrary? _resolveNativeLibrary() {
    // 1. Environment variable override
    final envPath = Platform.environment['AC_QUICKJS_LIB_PATH'];
    if (envPath != null && File(envPath).existsSync()) {
      return ExternalLibrary.open(envPath);
    }

    // Determine platform library name & subdirectories
    final String libName;
    final List<String> relativeSubpaths;

    if (Platform.isWindows) {
      libName = 'ac_quickjs.dll';
      relativeSubpaths = [
        'native/windows/x64/ac_quickjs.dll',
        'ac_quickjs.dll',
        'native/windows/x64/fjs.dll',
        'fjs.dll',
      ];
    } else if (Platform.isLinux) {
      libName = 'libac_quickjs.so';
      relativeSubpaths = [
        'native/linux/x64/libac_quickjs.so',
        'libac_quickjs.so',
        'native/linux/x64/libfjs.so',
        'libfjs.so',
      ];
    } else if (Platform.isMacOS) {
      libName = 'libac_quickjs.dylib';
      relativeSubpaths = [
        'native/macos/arm64/libac_quickjs.dylib',
        'native/macos/x64/libac_quickjs.dylib',
        'libac_quickjs.dylib',
        'native/macos/arm64/libfjs.dylib',
        'native/macos/x64/libfjs.dylib',
        'libfjs.dylib',
      ];
    } else if (Platform.isAndroid) {
      libName = 'libac_quickjs.so';
      relativeSubpaths = [
        'native/android/arm64-v8a/libac_quickjs.so',
        'libac_quickjs.so',
        'native/android/arm64-v8a/libfjs.so',
        'libfjs.so',
      ];
    } else {
      return null;
    }

    // 2. Search root paths (script dir, current working dir, package dirs)
    final searchRoots = <String>[];

    try {
      final scriptDir = File(Platform.script.toFilePath()).parent;
      searchRoots.add(scriptDir.path);
      var parent = scriptDir;
      for (var i = 0; i < 6; i++) {
        parent = parent.parent;
        searchRoots.add(parent.path);
      }
    } catch (_) {}

    final cwd = Directory.current.path;
    searchRoots.add(cwd);
    var cwdParent = Directory(cwd);
    for (var i = 0; i < 6; i++) {
      cwdParent = cwdParent.parent;
      searchRoots.add(cwdParent.path);
    }

    for (final root in searchRoots) {
      for (final rel in relativeSubpaths) {
        // Direct root/rel
        final candidate = File('$root/$rel');
        if (candidate.existsSync()) {
          return ExternalLibrary.open(candidate.path);
        }
        // Under packages/ac_quickjs/rel
        final candidateInPkg = File('$root/packages/ac_quickjs/$rel');
        if (candidateInPkg.existsSync()) {
          return ExternalLibrary.open(candidateInPkg.path);
        }
      }
    }

    // 3. Try opening by name via system lookup
    try {
      return ExternalLibrary.open(libName);
    } catch (_) {
      return null;
    }
  }
}
