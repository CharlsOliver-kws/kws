package com.example.account_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.Context
import android.os.IBinder
import android.widget.RemoteViews
import android.util.Log

class AccountLockScreenService : Service() {

    companion object {
        private const val TAG = "LockScreenService"
        const val CHANNEL_ID = "account_lockscreen"
        const val NOTIFICATION_ID = 1001

        const val EXTRA_TODAY_AMOUNT = "today_amount"
        const val EXTRA_TODAY_COUNT = "today_count"
        const val EXTRA_MONTHLY_AMOUNT = "monthly_amount"
        const val EXTRA_MONTHLY_COUNT = "monthly_count"

        fun start(
            context: Context,
            todayAmount: String,
            todayCount: Int,
            monthlyAmount: String,
            monthlyCount: Int,
        ) {
            try {
                val intent = Intent(context, AccountLockScreenService::class.java).apply {
                    putExtra(EXTRA_TODAY_AMOUNT, todayAmount)
                    putExtra(EXTRA_TODAY_COUNT, todayCount)
                    putExtra(EXTRA_MONTHLY_AMOUNT, monthlyAmount)
                    putExtra(EXTRA_MONTHLY_COUNT, monthlyCount)
                }
                context.startForegroundService(intent)
                Log.d(TAG, "LockScreenService start requested")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start service", e)
            }
        }

        fun stop(context: Context) {
            try {
                val intent = Intent(context, AccountLockScreenService::class.java)
                context.stopService(intent)
                Log.d(TAG, "LockScreenService stop requested")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to stop service", e)
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val todayAmount = intent?.getStringExtra(EXTRA_TODAY_AMOUNT) ?: "0.00"
        val todayCount = intent?.getIntExtra(EXTRA_TODAY_COUNT, 0) ?: 0
        val monthlyAmount = intent?.getStringExtra(EXTRA_MONTHLY_AMOUNT) ?: "0.00"
        val monthlyCount = intent?.getIntExtra(EXTRA_MONTHLY_COUNT, 0) ?: 0

        Log.d(TAG, "onStart: today=$todayAmount ($todayCount), month=$monthlyAmount ($monthlyCount)")

        createChannel()

        val openAppIntent = Intent(this, MainActivity::class.java)
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Open Design style custom notification layout
        val views = RemoteViews(packageName, R.layout.notif_lockscreen)
        views.setTextViewText(R.id.notif_today_amount, "¥$todayAmount")
        views.setTextViewText(R.id.notif_today_count, "${todayCount}笔")
        views.setTextViewText(R.id.notif_monthly_amount, "¥$monthlyAmount")
        views.setTextViewText(R.id.notif_monthly_count, "${monthlyCount}笔")

        val notification = Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(views)
            .setCustomBigContentView(views)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()

        startForeground(NOTIFICATION_ID, notification)
        Log.d(TAG, "startForeground with custom layout success")
        return START_STICKY
    }

    private fun createChannel() {
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "记账锁屏",
            NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            description = "显示记账摘要到锁屏"
            setShowBadge(false)
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            enableLights(false)
            enableVibration(false)
            setSound(null, null)
        }
        manager.createNotificationChannel(channel)
    }
}