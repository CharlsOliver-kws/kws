package com.example.account_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.widget.RemoteViews

class AccountLockScreenService : Service() {

    companion object {
        private const val TAG = "LockScreenService"
        const val FG_CHANNEL_ID = "account_fg_v1"
        const val LOCK_CHANNEL_ID = "account_lock_v1"
        const val SHADE_CHANNEL_ID = "account_shade_v1"
        const val FG_NOTIFICATION_ID = 1001
        const val LOCK_NOTIFICATION_ID = 1003
        const val SHADE_NOTIFICATION_ID = 1002

        const val EXTRA_TODAY_AMOUNT = "today_amount"
        const val EXTRA_TODAY_COUNT = "today_count"
        const val EXTRA_MONTHLY_AMOUNT = "monthly_amount"
        const val EXTRA_MONTHLY_COUNT = "monthly_count"

        fun start(context: Context, todayAmount: String, todayCount: Int,
                  monthlyAmount: String, monthlyCount: Int) {
            try {
                val intent = Intent(context, AccountLockScreenService::class.java).apply {
                    putExtra(EXTRA_TODAY_AMOUNT, todayAmount)
                    putExtra(EXTRA_TODAY_COUNT, todayCount)
                    putExtra(EXTRA_MONTHLY_AMOUNT, monthlyAmount)
                    putExtra(EXTRA_MONTHLY_COUNT, monthlyCount)
                }
                context.startForegroundService(intent)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start service", e)
            }
        }

        fun stop(context: Context) {
            try {
                context.stopService(Intent(context, AccountLockScreenService::class.java))
            } catch (e: Exception) {
                Log.e(TAG, "Failed to stop service", e)
            }
        }
    }

    private var todayAmount = "0.00"
    private var todayCount = 0
    private var monthlyAmount = "0.00"
    private var monthlyCount = 0

    private val handler = Handler(Looper.getMainLooper())

    private val screenReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                Intent.ACTION_SCREEN_OFF  -> handler.postDelayed({ postLockScreenNotification() }, 200)
                Intent.ACTION_USER_PRESENT -> cancelLockScreenNotification()
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(screenReceiver, filter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences("account_prefs", MODE_PRIVATE)
        if (intent != null) {
            todayAmount   = intent.getStringExtra(EXTRA_TODAY_AMOUNT)  ?: todayAmount
            todayCount    = intent.getIntExtra(EXTRA_TODAY_COUNT, todayCount)
            monthlyAmount = intent.getStringExtra(EXTRA_MONTHLY_AMOUNT) ?: monthlyAmount
            monthlyCount  = intent.getIntExtra(EXTRA_MONTHLY_COUNT, monthlyCount)
            prefs.edit()
                .putString("today_amount", todayAmount)
                .putInt("today_count", todayCount)
                .putString("monthly_amount", monthlyAmount)
                .putInt("monthly_count", monthlyCount)
                .apply()
        } else {
            todayAmount   = prefs.getString("today_amount", "0.00") ?: "0.00"
            todayCount    = prefs.getInt("today_count", 0)
            monthlyAmount = prefs.getString("monthly_amount", "0.00") ?: "0.00"
            monthlyCount  = prefs.getInt("monthly_count", 0)
        }

        Log.d(TAG, "onStart: today=$todayAmount ($todayCount), month=$monthlyAmount ($monthlyCount)")

        createChannels()

        // 前台服务保活通知（极简，不干扰通知栏）
        val fgNotification = Notification.Builder(this, FG_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("VoiceLedger 运行中")
            .setOngoing(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_SECRET)
            .build()
        startForeground(FG_NOTIFICATION_ID, fgNotification)

        // 通知栏卡片（自定义布局）
        postShadeNotification()

        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        val restart = Intent(applicationContext, AccountLockScreenService::class.java)
        applicationContext.startForegroundService(restart)
        Log.d(TAG, "Task removed, restarting service")
    }

    override fun onDestroy() {
        unregisterReceiver(screenReceiver)
        val nm = getSystemService(NotificationManager::class.java)
        nm.cancel(LOCK_NOTIFICATION_ID)
        nm.cancel(SHADE_NOTIFICATION_ID)
        super.onDestroy()
    }

    private fun buildPendingIntent(): PendingIntent {
        val openAppIntent = Intent(this, MainActivity::class.java)
            .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(this, 0, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    private fun buildRemoteViews(): RemoteViews {
        return RemoteViews(packageName, R.layout.notif_lockscreen).also { v ->
            v.setTextViewText(R.id.notif_today_amount, "¥$todayAmount")
            v.setTextViewText(R.id.notif_today_count, "${todayCount}笔")
            v.setTextViewText(R.id.notif_monthly_amount, "¥$monthlyAmount")
            v.setTextViewText(R.id.notif_monthly_count, "${monthlyCount}笔")
        }
    }

    /** 息屏时推送到锁屏 */
    private fun postLockScreenNotification() {
        val notification = Notification.Builder(this, LOCK_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(buildRemoteViews())
            .setCustomBigContentView(buildRemoteViews())
            .setContentIntent(buildPendingIntent())
            .setOngoing(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
        getSystemService(NotificationManager::class.java)
            .notify(LOCK_NOTIFICATION_ID, notification)
        Log.d(TAG, "Lock screen notification posted")
    }

    /** 亮屏时取消锁屏通知，保持通知栏干净 */
    private fun cancelLockScreenNotification() {
        getSystemService(NotificationManager::class.java).cancel(LOCK_NOTIFICATION_ID)
        Log.d(TAG, "Lock screen notification cancelled")
    }

    /** 通知栏常驻卡片 */
    private fun postShadeNotification() {
        val notification = Notification.Builder(this, SHADE_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(buildRemoteViews())
            .setCustomBigContentView(buildRemoteViews())
            .setContentIntent(buildPendingIntent())
            .setOngoing(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
        getSystemService(NotificationManager::class.java)
            .notify(SHADE_NOTIFICATION_ID, notification)
    }

    private fun createChannels() {
        val manager = getSystemService(NotificationManager::class.java)

        // 前台保活通道（最低优先级，用户几乎看不到）
        manager.createNotificationChannel(NotificationChannel(
            FG_CHANNEL_ID, "后台保活", NotificationManager.IMPORTANCE_MIN
        ).apply { setShowBadge(false); enableLights(false); enableVibration(false); setSound(null, null) })

        // 锁屏通道（息屏时推送）
        manager.createNotificationChannel(NotificationChannel(
            LOCK_CHANNEL_ID, "记账锁屏", NotificationManager.IMPORTANCE_HIGH
        ).apply {
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setShowBadge(false); enableLights(false); enableVibration(false); setSound(null, null)
        })

        // 通知栏通道
        manager.createNotificationChannel(NotificationChannel(
            SHADE_CHANNEL_ID, "记账摘要", NotificationManager.IMPORTANCE_DEFAULT
        ).apply {
            lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            setShowBadge(false); enableLights(false); enableVibration(false); setSound(null, null)
        })
    }
}