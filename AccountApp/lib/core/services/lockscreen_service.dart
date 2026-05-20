import 'package:flutter/services.dart';

class LockScreenService {
  static const _channel = MethodChannel('com.example.account_app/lockscreen');

  static Future<void> show({
    required String todayAmount,
    required int todayCount,
    required String monthlyAmount,
    required int monthlyCount,
  }) async {
    try {
      await _channel.invokeMethod('show', {
        'todayAmount': todayAmount,
        'todayCount': todayCount,
        'monthlyAmount': monthlyAmount,
        'monthlyCount': monthlyCount,
      });
    } catch (e) {
      // ignore - service not available on web/emulator
    }
  }

  static Future<void> hide() async {
    try {
      await _channel.invokeMethod('hide');
    } catch (e) {
      // ignore
    }
  }
}
