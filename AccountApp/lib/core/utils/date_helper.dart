import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MM-dd HH:mm').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDayGroup(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (isSameDay(date, today)) {
      return '今天';
    } else if (isSameDay(date, yesterday)) {
      return '昨天';
    } else {
      final weekday = DateFormat('EEEE').format(date);
      return '${date.month}月${date.day}日 $weekday';
    }
  }

  static DateTime parseDateTime(String str) {
    // Try "YYYY-MM-DD HH:mm" first
    try {
      final parts = str.trim().split(RegExp(r'[\s]+'));
      final dateParts = parts[0].split('-').map(int.parse).toList();
      final hour = parts.length > 1 ? int.parse(parts[1].split(':')[0]) : 12;
      final minute = parts.length > 1 ? int.parse(parts[1].split(':')[1]) : 0;
      return DateTime(dateParts[0], dateParts[1], dateParts[2], hour, minute);
    } catch (_) {
      // Fallback: just date
      try {
        final parts = str.trim().split('-').map(int.parse).toList();
        return DateTime(parts[0], parts[1], parts[2]);
      } catch (_) {
        return DateTime.now();
      }
    }
  }
}
