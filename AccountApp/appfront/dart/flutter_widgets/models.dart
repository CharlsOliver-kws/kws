/// VoiceLedger 数据模型
/// 被所有 screen / widget 文件共享引用

import 'design_tokens.dart';

/// 一条记账记录 — 与 SQLite Record 表对齐
class Record {
  final String id;
  final CategoryId category;
  final String note;
  final double amount;
  final DateTime time;

  const Record({
    required this.id,
    required this.category,
    required this.note,
    required this.amount,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.id,
    'note': note,
    'amount': amount,
    'time': time.toIso8601String(),
  };

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    id: json['id'] as String,
    category: CategoryId.fromId(json['category'] as String),
    note: json['note'] as String? ?? '',
    amount: (json['amount'] as num).toDouble(),
    time: DateTime.parse(json['time'] as String),
  );
}

/// 按日期分组的记录
class RecordGroup {
  final DateTime date;
  final List<Record> records;

  const RecordGroup({required this.date, required this.records});

  double get total => records.fold(0, (s, r) => s + r.amount);

  String get label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateStart = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateStart).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    return '${date.month}月${date.day}日';
  }
}

/// 根据 Record 列表生成分组
List<RecordGroup> groupRecords(Iterable<Record> records) {
  final map = <DateTime, List<Record>>{};
  for (final r in records) {
    final key = DateTime(r.time.year, r.time.month, r.time.day);
    map.putIfAbsent(key, () => []).add(r);
  }
  final groups = map.entries
      .map((e) => RecordGroup(date: e.key, records: e.value))
      .toList();
  groups.sort((a, b) => b.date.compareTo(a.date));
  return groups;
}