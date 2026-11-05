package com.protegelink.mobile

import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.protegelink.mobile/shared_links"
    private var channel: MethodChannel? = null
    private var pendingLinkText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingLinkText = linkTextFrom(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialSharedText" -> {
                        result.success(pendingLinkText)
                        pendingLinkText = null
                    }
                    "openLinkSettings" -> {
                        try {
                            startActivity(Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS))
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == Intent.ACTION_SEND || intent.action == Intent.ACTION_VIEW) {
            val text = linkTextFrom(intent) ?: ""
            if (channel == null) {
                pendingLinkText = text
            } else {
                channel?.invokeMethod("sharedText", text)
            }
        }
    }

    override fun onDestroy() {
        channel?.setMethodCallHandler(null)
        channel = null
        super.onDestroy()
    }

    private fun linkTextFrom(intent: Intent?): String? {
        return when {
            intent?.action == Intent.ACTION_SEND && intent.type == "text/plain" ->
                intent.getStringExtra(Intent.EXTRA_TEXT) ?: ""
            intent?.action == Intent.ACTION_VIEW -> intent.dataString
            else -> null
        }
    }
}
