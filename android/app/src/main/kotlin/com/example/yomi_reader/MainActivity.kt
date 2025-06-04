package com.example.app

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.app/sudachi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initSudachi" -> {
                    try {
                        SudachiTokenizer.init(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", "Failed to init Sudachi", e.message)
                    }
                }

                "tokenize" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        val tokens = SudachiTokenizer.tokenize(text)
                        result.success(tokens)
                    } else {
                        result.error("TOKENIZE_ERROR", "No text provided", null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
