import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _instance;

  static Future<Database> get database async {
    _instance ??= await _initDatabase();
    return _instance!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'account.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            category TEXT NOT NULL DEFAULT 'other',
            date INTEGER NOT NULL,
            note TEXT DEFAULT '',
            voice_text TEXT DEFAULT '',
            voice_file TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_records_date ON records(date)');
        await db.execute(
          'CREATE INDEX idx_records_category ON records(category)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // 中文分类 → 英文ID
          await db.execute('''
            UPDATE records SET category = CASE
              WHEN category = '餐饮' THEN 'food'
              WHEN category = '交通' THEN 'transport'
              WHEN category = '购物' THEN 'shopping'
              WHEN category = '娱乐' THEN 'entertain'
              WHEN category = '医疗' THEN 'medical'
              WHEN category = '教育' THEN 'education'
              WHEN category = '住房' THEN 'housing'
              WHEN category = '其他' THEN 'other'
              ELSE 'other'
            END
          ''');
        }
      },
    );
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
