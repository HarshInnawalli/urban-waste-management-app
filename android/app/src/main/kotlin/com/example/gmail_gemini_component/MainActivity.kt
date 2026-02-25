package com.example.gmail_gemini_component   

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.harsh.garbage/email"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "sendEmail") {

                    val to = call.argument<String>("to")
                    val subject = call.argument<String>("subject")
                    val body = call.argument<String>("body")
                    val imagePath = call.argument<String>("imagePath")

                    try {
                        val file = File(imagePath!!)
                        val uri: Uri = FileProvider.getUriForFile(
                            this,
                            "${packageName}.provider",
                            file
                        )

                        val intent = Intent(Intent.ACTION_SEND).apply {
                            type = "image/jpeg"
                            setPackage("com.google.android.gm")  // 🔥 FORCE GMAIL
                            putExtra(Intent.EXTRA_EMAIL, arrayOf(to))
                            putExtra(Intent.EXTRA_SUBJECT, subject)
                            putExtra(Intent.EXTRA_TEXT, body)
                            putExtra(Intent.EXTRA_STREAM, uri)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        startActivity(intent)
                        result.success(null)

                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
            }
    }
}

