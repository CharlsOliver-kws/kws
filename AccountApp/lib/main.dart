import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'data/local/prefs_manager.dart';
import 'providers/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read saved theme synchronously — don't block on permission
  final themeModeStr = await PrefsManager.getThemeMode();
  final themeMode = switch (themeModeStr) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => themeMode),
      ],
      child: const AccountApp(),
    ),
  );

  // Request notification permission AFTER app is rendered
  // This prevents black screen if permission dialog hangs
  _requestNotificationPermission();
}

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isGranted) return;

  final result = await Permission.notification.request();
  if (result.isPermanentlyDenied) {
    // User permanently denied, show guide dialog
    // We'll handle this via a global key in the app
    debugPrint('Notification permanently denied, need to show guide');
  }
}

// Global key to show notification guide dialog after app starts
final GlobalKey<NavigatorState> notificationGuideKey =
    GlobalKey<NavigatorState>();

class NotificationGuideDialog extends StatelessWidget {
  const NotificationGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('需要通知权限'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('此应用需要通知权限才能实现锁屏通知功能：'),
          SizedBox(height: 8),
          Text('• 长按手机桌面可添加数据小组件'),
          Text('• 记账后会在锁屏/AOD显示今日摘要'),
          SizedBox(height: 12),
          Text('请点击"去设置"→ 找到"语音记账"→ 开启通知'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await openAppSettings();
          },
          child: const Text('去设置'),
        ),
      ],
    );
  }
}
