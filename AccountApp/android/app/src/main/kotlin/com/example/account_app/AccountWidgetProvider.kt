package com.example.account_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.widget.RemoteViews

class AccountWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val SHARED_PREFS_NAME = "HomeWidgetPreferences"

        fun updateWidget(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val widgetIds = manager.getAppWidgetIds(
                android.content.ComponentName(context, AccountWidgetProvider::class.java)
            )

            val prefs = context.getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE)
            val todayAmount = prefs.getString("today_amount", "0.00") ?: "0.00"
            val todayCount = prefs.getInt("today_count", 0)
            val monthlyAmount = prefs.getString("monthly_amount", "0.00") ?: "0.00"
            val monthlyCount = prefs.getInt("monthly_count", 0)

            for (widgetId in widgetIds) {
                val views = RemoteViews(context.packageName, R.layout.widget_account)

                views.setTextViewText(R.id.widget_today_label, "今日支出")
                views.setTextViewText(R.id.widget_today_amount, "¥$todayAmount")
                views.setTextViewText(R.id.widget_today_count, "${todayCount} 笔")
                views.setTextViewText(R.id.widget_month_label, "本月累计")
                views.setTextViewText(R.id.widget_monthly_amount, "¥$monthlyAmount")
                views.setTextViewText(R.id.widget_month_count, "${monthlyCount} 笔")

                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context, 0, intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_today_label, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_today_amount, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_month_label, pendingIntent)
                views.setOnClickPendingIntent(R.id.widget_monthly_amount, pendingIntent)

                manager.updateAppWidget(widgetId, views)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        updateWidget(context)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        updateWidget(context)
    }
}