import '../../core/config/design_tokens.dart';

class Record {
  final int? id;
  final double amount;
  final String category; // 英文ID: food, transport, shopping, etc.
  final DateTime date;
  final String note;
  final String voiceText;
  final String? voiceFile;
  final DateTime createdAt;
  final DateTime updatedAt;

  Record({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note = '',
    this.voiceText = '',
    this.voiceFile,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 便捷方法：获取分类枚举
  CategoryId get categoryEnum => CategoryId.fromId(category);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'voice_text': voiceText,
      'voice_file': voiceFile,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String? ?? '',
      voiceText: map['voice_text'] as String? ?? '',
      voiceFile: map['voice_file'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Record copyWith({
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? voiceText,
    String? voiceFile,
  }) {
    return Record(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      voiceText: voiceText ?? this.voiceText,
      voiceFile: voiceFile ?? this.voiceFile,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
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
    final key = DateTime(r.date.year, r.date.month, r.date.day);
    map.putIfAbsent(key, () => []).add(r);
  }
  final groups = map.entries
      .map((e) => RecordGroup(date: e.key, records: e.value))
      .toList();
  groups.sort((a, b) => b.date.compareTo(a.date));
  return groups;
}
