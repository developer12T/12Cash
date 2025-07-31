package com.onetwotrading.onetwocashapp

import io.flutter.embedding.android.FlutterActivity

import android.content.ContentResolver
import android.provider.Settings
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity()
{
    private val CHANNEL = "com.onetwotrading.onetwocashapp/dev_mode"
    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "isDeveloperMode") {
                val contentResolver: ContentResolver = applicationContext.contentResolver
                val devMode = Settings.Secure.getInt(contentResolver, Settings.Secure.DEVELOPMENT_SETTINGS_ENABLED, 0)
                result.success(devMode == 1)
            }
        }
    }
}
