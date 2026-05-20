package com.example.account_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = context.getSharedPreferences("account_prefs", Context.MODE_PRIVATE)
            val todayAmount   = prefs.getString("today_amount", "0.00") ?: "0.00"
            val todayCount    = prefs.getInt("today_count", 0)
            val monthlyAmount = prefs.getString("monthly_amount", "0.00") ?: "0.00"
            val monthlyCount  = prefs.getInt("monthly_count", 0)
            AccountLockScreenService.start(context, todayAmount, todayCount, monthlyAmount, monthlyCount)
        }
    }
}
