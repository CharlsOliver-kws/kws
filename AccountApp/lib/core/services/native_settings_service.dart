import 'package:flutter/services.dart';

class NativeSettingsService {
  static const _channel = MethodChannel('com.example.account_app/settings');

  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      // ignore
    }
  }
}
