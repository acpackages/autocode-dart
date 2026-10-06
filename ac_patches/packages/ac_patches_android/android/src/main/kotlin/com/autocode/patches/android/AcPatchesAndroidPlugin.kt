package com.autocode.patches.android

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/**
 * ac_patches Android Plugin
 */
class AcPatchesAndroidPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ac_patches/android")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getActivePatchPath" -> {
                val path = getActivePatchPath(context)
                result.success(path)
            }
            "isPatchInstalled" -> {
                val path = getActivePatchPath(context)
                result.success(path != null)
            }
            "getFilesDir" -> {
                result.success(context.filesDir.absolutePath)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        fun getActivePatchPath(context: Context): String? {
            val patchFile = File(context.filesDir, "patches/active/libapp.so")
            if (patchFile.exists() && patchFile.canRead() && patchFile.length() > 0) {
                return patchFile.absolutePath
            }
            return null
        }
    }
}
