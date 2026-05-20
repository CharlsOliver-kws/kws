/// 全部记录页 — All Records Screen
/// route: /all-records
///
/// @dataSource recordsProvider (Riverpod AsyncValue<List<Record>>)
///
/// @component AllRecordsScreen
///   @props recordGroups: List<RecordGroup> — 全部记录按日期降序分组
///   @props onBack: VoidCallback — 返回首页
///
/// 与首页的区别：无数量截断、只读列表（无左滑删除）

import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'home_screen.dart' show RecordGroup, RecordItem;

/// 全部记录页
class AllRecordsScreen extends StatelessWidget {
  final List<RecordGroup> recordGroups;
  final VoidCallback onBack;

  const AllRecordsScreen({
    super.key,
    required this.recordGroups,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fg),
          onPressed: onBack,
        ),
        title: const Text('全部记录', style: TextStyle(
          fontSize: AppText.displaySm,
          fontWeight: FontWeight.w600,
          color: AppColors.fg,
        )),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: recordGroups.isEmpty
        ? const _AllRecordsEmpty()
        : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: recordGroups.length,
            itemBuilder: (_, i) {
              final group = recordGroups[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // group header
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(group.label, style: const TextStyle(
                          fontSize: AppText.bodyMd,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        )),
                        Text('${group.records.length}笔 · ¥${group.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: AppText.bodySm,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // records
                  ...group.records.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: RecordItem(
                      category: r.category,
                      note: r.note,
                      time: '${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')}',
                      amount: r.amount,
                    ),
                  )),
                ],
              );
            },
          ),
    );
  }
}

/// 全部记录空状态
class _AllRecordsEmpty extends StatelessWidget {
  const _AllRecordsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.muted),
            const SizedBox(height: AppSpacing.md),
            const Text('暂无记录', style: TextStyle(
              fontSize: AppText.displaySm,
              fontWeight: FontWeight.w600,
              color: AppColors.fg,
            )),
            const SizedBox(height: AppSpacing.xs),
            Text('返回首页开始记账', style: TextStyle(
              fontSize: AppText.bodySm,
              color: AppColors.muted,
            )),
          ],
        ),
      ),
    );
  }
}