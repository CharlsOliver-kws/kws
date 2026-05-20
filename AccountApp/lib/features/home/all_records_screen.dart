import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/design_tokens.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/record.dart';
import '../../providers/records_provider.dart';

class AllRecordsScreen extends ConsumerWidget {
  const AllRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fg),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('全部记录', style: TextStyle(
          fontSize: AppText.displaySm,
          fontWeight: FontWeight.w600,
          color: AppColors.fg,
        )),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: recordsAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const _AllRecordsEmpty();
          }
          final groups = groupRecords(records);
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: groups.length,
            itemBuilder: (_, i) {
              final group = groups[i];
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
                  ...group.records.map((r) {
                    final cat = r.categoryEnum;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: cat.backgroundColor,
                                borderRadius: AppRadius.smAll,
                              ),
                              child: Icon(cat.icon, size: 18, color: cat.color),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.note,
                                    style: const TextStyle(
                                      fontSize: AppText.bodyMd,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.fg,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(DateHelper.formatTime(r.date),
                                    style: const TextStyle(
                                      fontSize: AppText.bodySm,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text('¥${r.amount.toStringAsFixed(2)}', style: const TextStyle(
                              fontSize: AppText.bodyMd,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fg,
                            )),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('加载失败: $e', style: const TextStyle(color: AppColors.danger))),
      ),
    );
  }
}

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
