package com.autocode.patches.android

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterShellArgs

/**
 * Drop-in FlutterActivity replacement that automatically configures
 * the Flutter engine to boot from the active OTA patch if present.
 */
open class AcPatchesActivity : FlutterActivity() {
    override fun getFlutterShellArgs(): FlutterShellArgs {
        val shellArgs = super.getFlutterShellArgs()
        val activePatchPath = AcPatchesAndroidPlugin.getActivePatchPath(applicationContext)
        if (activePatchPath != null) {
            shellArgs.add("--aot-shared-library-name=$activePatchPath")
        }
        return shellArgs
    }
}
