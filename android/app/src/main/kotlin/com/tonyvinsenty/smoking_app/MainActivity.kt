package com.tonyvinsenty.smoking_app

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Coming back after the process was dropped (or from Recents), Android hands over the intent that first
        // started the task: an old SOS from the icon menu or a widget must not open again.
        if (savedInstanceState != null || intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) {
            intent.removeExtra(ZeroWidgets.SHORTCUT_EXTRA)
        }
        super.onCreate(savedInstanceState)
    }


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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "zero/home_widget").setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    ZeroWidgets.save(applicationContext, call.arguments as String)
                    result.success(null)
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
