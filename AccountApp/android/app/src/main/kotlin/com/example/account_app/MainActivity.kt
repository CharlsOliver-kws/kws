package com.example.account_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

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
