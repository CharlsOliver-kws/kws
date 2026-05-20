import 'package:home_widget/home_widget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WidgetUpdateService {
  static Future<void> updateWidget() async {
    final today = await _getTodayStats();
    final monthly = await _getMonthlyStats();

    await HomeWidget.saveWidgetData<String>(
      'today_amount',
      today['amount']!.toStringAsFixed(2),
    );
    await HomeWidget.saveWidgetData<int>('today_count', today['count']!.toInt());
    await HomeWidget.saveWidgetData<String>(
      'monthly_amount',
      monthly['amount']!.toStringAsFixed(2),
    );
    await HomeWidget.saveWidgetData<int>('monthly_count', monthly['count']!.toInt());
    await HomeWidget.updateWidget(
      name: 'AccountWidgetProvider',
      androidName: 'AccountWidgetProvider',
      qualifiedAndroidName: 'com.example.account_app.AccountWidgetProvider',
    );
  }

  static Future<Map<String, double>> _getTodayStats() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _openDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total FROM records WHERE date >= ? AND date < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return {
      'count': (result.first['count'] as num).toDouble(),
      'amount': (result.first['total'] as num).toDouble(),
    };
  }

  static Future<Map<String, double>> _getMonthlyStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    final db = await _openDb();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total FROM records WHERE date >= ? AND date < ?',
      [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch],
    );
    return {
      'count': (result.first['count'] as num).toDouble(),
      'amount': (result.first['total'] as num).toDouble(),
    };
  }

  static Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'account.db');
    return openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date INTEGER NOT NULL,
          note TEXT,
          voiceText TEXT,
          voiceFile TEXT,
          createdAt INTEGER
        )
      ''');
    });
  }
}
