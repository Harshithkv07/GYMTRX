package com.harshithkv.gymtrx

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth's BiometricPrompt.
class MainActivity : FlutterFragmentActivity() {

    // Created with the activity: their permission launchers must be registered
    // before it starts.
    private val health = HealthBridge(this)
    private val calendar = CalendarBridge(this)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestHighestRefreshRate()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gymtrx/system")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Hides the app's content in the Recents switcher while app lock is on.
                    // Screenshots stay allowed (unlike FLAG_SECURE).
                    "setRecentsHidden" -> {
                        val hidden = call.arguments as? Boolean ?: false
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            setRecentsScreenshotEnabled(!hidden)
                        }
                        result.success(null)
                    }
                    // GYMTRX's page in Android settings, to allow a permission it was refused.
                    "openAppSettings" -> {
                        startActivity(
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null))
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gymtrx/health").setMethodCallHandler(health)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gymtrx/calendar").setMethodCallHandler(calendar)
    }

    // Some OEMs keep apps at 60 Hz unless they ask for more. Pick the fastest
    // mode at the current resolution so animations run at 90/120 Hz.
    private fun requestHighestRefreshRate() {
        val display = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
        } ?: return
        val current = display.mode
        val best = display.supportedModes
            .filter {
                it.physicalWidth == current.physicalWidth &&
                    it.physicalHeight == current.physicalHeight
            }
            .maxByOrNull { it.refreshRate } ?: return
        if (best.modeId != current.modeId) {
            window.attributes = window.attributes.apply { preferredDisplayModeId = best.modeId }
        }
    }
}
