package com.autocode.patches

import android.content.Context
import io.flutter.embedding.engine.FlutterShellArgs
import java.io.File

/**
 * ac_patches Android Runtime Loader
 * 
 * Configures the FlutterLoader / FlutterShellArgs with the path to the active
 * OTA patch library before the FlutterEngine or Dart VM boots.
 */
object AcPatchesLoader {
    private const val PATCHES_DIR = "patches"
    private const val ACTIVE_DIR = "active"
    private const val SNAPSHOT_NAME = "libapp.so"

    /**
     * Resolves the active OTA patch path, or null if running base release.
     */
    fun getActivePatchPath(context: Context): String? {
        val patchFile = File(context.filesDir, "$PATCHES_DIR/$ACTIVE_DIR/$SNAPSHOT_NAME")
        if (patchFile.exists() && patchFile.canRead() && patchFile.length() > 0) {
            return patchFile.absolutePath
        }
        return null
    }

    /**
     * Injects the active OTA patch into FlutterShellArgs for FlutterActivity or FlutterEngine.
     */
    fun configureShellArgs(context: Context, shellArgs: FlutterShellArgs) {
        val patchPath = getActivePatchPath(context)
        if (patchPath != null) {
            shellArgs.add("--aot-shared-library-name=$patchPath")
        }
    }
}
