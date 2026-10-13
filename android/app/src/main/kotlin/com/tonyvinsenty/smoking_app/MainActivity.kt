package com.tonyvinsenty.smoking_app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "zero/app_icon").setMethodCallHandler { call, result ->
            when (call.method) {
                "set" -> {
                    val id = call.arguments as? String
                    if (id !in ICONS) {
                        result.error("bad_icon", "Unknown icon $id", null)
                    } else {
                        setIcon(id!!)
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Each icon is an activity-alias `.Icon<id>` in the manifest; exactly one is enabled. */
    private fun setIcon(id: String) {
        // Enable the new alias before disabling the old one, so the launcher never sees zero entries.
        val ordered = listOf(id) + ICONS.filter { it != id }
        for (icon in ordered) {
            val state = if (icon == id) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            packageManager.setComponentEnabledSetting(
                ComponentName(packageName, "${javaClass.`package`!!.name}.Icon$icon"),
                state,
                PackageManager.DONT_KILL_APP,
            )
        }
    }

    private companion object {
        val ICONS = listOf("9a", "9b", "7a", "7b")
    }
}
