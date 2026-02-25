package com.example.gmail_gemini_component

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.gmail_gemini_component/email"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "sendEmail") {

                val to = call.argument<String>("to")
                val subject = call.argument<String>("subject")
                val body = call.argument<String>("body")
                val imagePath = call.argument<String>("imagePath")

                if (to == null || subject == null || body == null || imagePath == null) {
                    result.error("INVALID_ARGUMENT", "Missing arguments", null)
                    return@setMethodCallHandler
                }

                try {
                    val file = File(imagePath)

                    val uri: Uri = FileProvider.getUriForFile(
                        this,
                        "${applicationContext.packageName}.provider",
                        file
                    )

                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = "image/*"
                        putExtra(Intent.EXTRA_EMAIL, arrayOf(to))
                        putExtra(Intent.EXTRA_SUBJECT, subject)
                        putExtra(Intent.EXTRA_TEXT, body)
                        putExtra(Intent.EXTRA_STREAM, uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)

                        // ✅ Force open Gmail only
                        setPackage("com.google.android.gm")
                    }

                    startActivity(intent)
                    result.success(null)

                } catch (e: Exception) {
                    result.error(
                        "GMAIL_NOT_FOUND",
                        "Gmail app is not installed or failed to open: ${e.message}",
                        null
                    )
                }

            } else {
                result.notImplemented()
            }
        }
    }
}