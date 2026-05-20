import 'package:sqflite/sqflite.dart';
import '../local/database.dart';
import '../models/record.dart';

class RecordRepository {
  Future<Database> get _db async => DatabaseHelper.database;

  Future<Record> insert(Record record) async {
    final db = await _db;
    final id = await db.insert('records', record.toMap());
    final newRecord = Record(
      id: id,
      amount: record.amount,
      category: record.category,
      date: record.date,
      note: record.note,
      voiceText: record.voiceText,
      voiceFile: record.voiceFile,
      createdAt: record.createdAt,
    );
    return newRecord;
  }

  Future<int> update(Record record) async {
    final db = await _db;
    return db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _db;
    return db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Record>> getAll({String? category, DateTime? from, DateTime? to}) async {
    final db = await _db;
    String where = '';
    List<dynamic> whereArgs = [];

    if (category != null && category != '全部') {
      where += 'category = ?';
      whereArgs.add(category);
    }
    if (from != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'date >= ?';
      whereArgs.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'date <= ?';
      whereArgs.add(to.millisecondsSinceEpoch);
    }

    final maps = await db.query(
      'records',
      where: where.isNotEmpty ? where : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Record.fromMap(m)).toList();
  }

  Future<double> getTotal({DateTime? from, DateTime? to}) async {
    final records = await getAll(from: from, to: to);
    return records.fold<double>(0, (sum, r) => sum + r.amount);
  }

  Future<Map<String, double>> getTotalsByCategory({DateTime? from, DateTime? to}) async {
    final records = await getAll(from: from, to: to);
    final map = <String, double>{};
    for (final r in records) {
      map[r.category] = (map[r.category] ?? 0) + r.amount;
    }
    return map;
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('records');
  }
}
