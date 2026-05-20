import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/record.dart';
import '../../data/repositories/record_repository.dart';
import '../core/services/widget_update_service.dart';
import '../core/services/lockscreen_service.dart';

final recordRepositoryProvider = Provider((ref) => RecordRepository());

final recordsProvider = StateNotifierProvider<RecordsNotifier, AsyncValue<List<Record>>>((ref) {
  return RecordsNotifier(ref.watch(recordRepositoryProvider));
});

class RecordsNotifier extends StateNotifier<AsyncValue<List<Record>>> {
  final RecordRepository _repository;

  RecordsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      final records = await _repository.getAll();
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecord(Record record) async {
    await _repository.insert(record);
    await WidgetUpdateService.updateWidget();
    await _updateLockScreen();
    await loadRecords();
  }

  Future<void> deleteRecord(int id) async {
    await _repository.delete(id);
    await WidgetUpdateService.updateWidget();
    await _updateLockScreen();
    await loadRecords();
  }

  Future<void> _updateLockScreen() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final startOfMonth = DateTime(today.year, today.month, 1);

    final todayRecords = await _repository.getAll(from: startOfDay, to: endOfDay);
    final todayTotal = todayRecords.fold<double>(0, (sum, r) => sum + r.amount);

    final monthRecords = await _repository.getAll(from: startOfMonth, to: today);
    final monthTotal = monthRecords.fold<double>(0, (sum, r) => sum + r.amount);

    await LockScreenService.show(
      todayAmount: todayTotal.toStringAsFixed(2),
      todayCount: todayRecords.length,
      monthlyAmount: monthTotal.toStringAsFixed(2),
      monthlyCount: monthRecords.length,
    );
  }
}
