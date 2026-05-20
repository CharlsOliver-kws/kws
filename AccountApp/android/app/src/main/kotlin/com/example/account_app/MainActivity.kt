package com.example.account_app

import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onResume() {
        super.onResume()
        requestBatteryOptimizationExemption()
    }

    private fun requestBatteryOptimizationExemption() {
        val pm = getSystemService(PowerManager::class.java)
        if (!pm.isIgnoringBatteryOptimizations(packageName)) {
            try {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                }
                startActivity(intent)
            } catch (e: Exception) {
                // 设备不支持则忽略
            }
        }
    }

    private val CHANNEL = "com.example.account_app/lockscreen"
    private val SETTINGS_CHANNEL = "com.example.account_app/settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> {
                    val todayAmount = call.argument<String>("todayAmount") ?: "0.00"
                    val todayCount = call.argument<Int>("todayCount") ?: 0
                    val monthlyAmount = call.argument<String>("monthlyAmount") ?: "0.00"
                    val monthlyCount = call.argument<Int>("monthlyCount") ?: 0

                    AccountLockScreenService.start(
                        applicationContext, todayAmount, todayCount, monthlyAmount, monthlyCount
                    )
                    result.success(null)
                }
                "hide" -> {
                    AccountLockScreenService.stop(applicationContext)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // Settings channel for system navigation
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    try {
                        val intent = android.content.Intent().apply {
                            action = android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS
                            putExtra(android.provider.Settings.EXTRA_APP_PACKAGE, packageName)
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
