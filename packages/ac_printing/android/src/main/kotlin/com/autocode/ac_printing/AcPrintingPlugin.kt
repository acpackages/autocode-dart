package com.autocode.ac_printing

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.print.PageRange
import android.print.PrintAttributes
import android.print.PrintDocumentAdapter
import android.print.PrintDocumentInfo
import android.print.PrintManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class AcPrintingPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "plugins.autocode.run/ac_printing")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPrinters" -> {
                val list = ArrayList<Map<String, Any>>()
                val defaultPrinter = HashMap<String, Any>()
                defaultPrinter["name"] = "Default Print Service"
                defaultPrinter["url"] = "android://print_service"
                defaultPrinter["location"] = ""
                defaultPrinter["comment"] = "Android System Print Spooler"
                defaultPrinter["isDefault"] = true
                defaultPrinter["isAvailable"] = true
                list.add(defaultPrinter)
                result.success(list)
            }
            "printPdf" -> {
                val bytes = call.argument<ByteArray>("bytes")
                val jobName = call.argument<String>("jobName") ?: "Document"
                if (bytes == null) {
                    result.error("INVALID_ARGUMENT", "Bytes must not be null", null)
                    return
                }

                try {
                    val printManager = context.getSystemService(Context.PRINT_SERVICE) as? PrintManager
                    if (printManager == null) {
                        result.error("PRINT_UNAVAILABLE", "PrintManager not available", null)
                        return
                    }

                    val adapter = object : PrintDocumentAdapter() {
                        override fun onLayout(
                            oldAttributes: PrintAttributes?,
                            newAttributes: PrintAttributes?,
                            cancellationSignal: CancellationSignal?,
                            callback: LayoutResultCallback?,
                            extras: Bundle?
                        ) {
                            if (cancellationSignal?.isCanceled == true) {
                                callback?.onLayoutCancelled()
                                return
                            }
                            val info = PrintDocumentInfo.Builder(jobName)
                                .setContentType(PrintDocumentInfo.CONTENT_TYPE_DOCUMENT)
                                .build()
                            callback?.onLayoutFinished(info, true)
                        }

                        override fun onWrite(
                            pages: Array<out PageRange>?,
                            destination: ParcelFileDescriptor?,
                            cancellationSignal: CancellationSignal?,
                            callback: WriteResultCallback?
                        ) {
                            if (destination == null) {
                                callback?.onWriteFailed("Destination is null")
                                return
                            }
                            try {
                                val output = FileOutputStream(destination.fileDescriptor)
                                output.write(bytes)
                                output.flush()
                                output.close()
                                callback?.onWriteFinished(arrayOf(PageRange.ALL_PAGES))
                            } catch (e: IOException) {
                                callback?.onWriteFailed(e.message)
                            }
                        }
                    }

                    val widthMm = (call.argument<Double>("widthMm") ?: 210.0).toFloat()
                    val heightMm = (call.argument<Double>("heightMm") ?: 297.0).toFloat()
                    val isPortrait = call.argument<Boolean>("isPortrait") ?: true
                    val paperName = (call.argument<String>("paperName") ?: "A4").uppercase()

                    val widthMils = if (isPortrait) (widthMm * 1000f / 25.4f).toInt() else (heightMm * 1000f / 25.4f).toInt()
                    val heightMils = if (isPortrait) (heightMm * 1000f / 25.4f).toInt() else (widthMm * 1000f / 25.4f).toInt()

                    val mediaSize: PrintAttributes.MediaSize = when (paperName) {
                        "A4" -> if (isPortrait) PrintAttributes.MediaSize.ISO_A4 else PrintAttributes.MediaSize.ISO_A4.asLandscape()
                        "A3" -> if (isPortrait) PrintAttributes.MediaSize.ISO_A3 else PrintAttributes.MediaSize.ISO_A3.asLandscape()
                        "A5" -> if (isPortrait) PrintAttributes.MediaSize.ISO_A5 else PrintAttributes.MediaSize.ISO_A5.asLandscape()
                        "A6" -> if (isPortrait) PrintAttributes.MediaSize.ISO_A6 else PrintAttributes.MediaSize.ISO_A6.asLandscape()
                        "LETTER" -> if (isPortrait) PrintAttributes.MediaSize.NA_LETTER else PrintAttributes.MediaSize.NA_LETTER.asLandscape()
                        "LEGAL" -> if (isPortrait) PrintAttributes.MediaSize.NA_LEGAL else PrintAttributes.MediaSize.NA_LEGAL.asLandscape()
                        "EXECUTIVE" -> if (isPortrait) PrintAttributes.MediaSize.NA_EXECUTIVE else PrintAttributes.MediaSize.NA_EXECUTIVE.asLandscape()
                        else -> {
                            val safeId = "custom_${widthMils}_${heightMils}"
                            PrintAttributes.MediaSize(safeId, "$paperName ($widthMm x $heightMm mm)", widthMils, heightMils)
                        }
                    }

                    val printAttributesBuilder = PrintAttributes.Builder()
                        .setMediaSize(mediaSize)

                    val marginLeftMm = (call.argument<Double>("marginLeftMm") ?: 0.0).toFloat()
                    val marginRightMm = (call.argument<Double>("marginRightMm") ?: 0.0).toFloat()
                    val marginTopMm = (call.argument<Double>("marginTopMm") ?: 0.0).toFloat()
                    val marginBottomMm = (call.argument<Double>("marginBottomMm") ?: 0.0).toFloat()

                    if (marginLeftMm > 0 || marginRightMm > 0 || marginTopMm > 0 || marginBottomMm > 0) {
                        val margins = PrintAttributes.Margins(
                            (marginLeftMm * 1000f / 25.4f).toInt(),
                            (marginTopMm * 1000f / 25.4f).toInt(),
                            (marginRightMm * 1000f / 25.4f).toInt(),
                            (marginBottomMm * 1000f / 25.4f).toInt()
                        )
                        printAttributesBuilder.setMinMargins(margins)
                    }

                    val printAttributes = printAttributesBuilder.build()

                    printManager.print(jobName, adapter, printAttributes)
                    result.success(true)
                } catch (e: Exception) {
                    result.error("PRINT_ERROR", e.message, null)
                }
            }
            "sharePdf" -> {
                val bytes = call.argument<ByteArray>("bytes")
                val name = call.argument<String>("name") ?: "document.pdf"
                if (bytes == null) {
                    result.error("INVALID_ARGUMENT", "Bytes must not be null", null)
                    return
                }
                try {
                    val cacheFile = File(context.cacheDir, name)
                    val fos = FileOutputStream(cacheFile)
                    fos.write(bytes)
                    fos.flush()
                    fos.close()

                    val uri = Uri.fromFile(cacheFile)
                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "application/pdf"
                        putExtra(Intent.EXTRA_STREAM, uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    context.startActivity(Intent.createChooser(shareIntent, "Share PDF").apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    })
                    result.success(true)
                } catch (e: Exception) {
                    result.error("SHARE_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }
}
