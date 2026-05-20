import 'package:shared_preferences/shared_preferences.dart';

class PrefsManager {
  static const _themeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _lockScreenKey = 'lock_screen_enabled';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(_themeKey) ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    final prefs = await _instance;
    await prefs.setString(_themeKey, mode);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_notificationsKey, value);
  }

  static Future<bool> getLockScreenEnabled() async {
    final prefs = await _instance;
    return prefs.getBool(_lockScreenKey) ?? false;
  }

  static Future<void> setLockScreenEnabled(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_lockScreenKey, value);
  }

  static Future<bool> remove(String key) async {
    final prefs = await _instance;
    return prefs.remove(key);
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
