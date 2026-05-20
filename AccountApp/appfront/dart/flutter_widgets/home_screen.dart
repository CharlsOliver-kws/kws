/// 首页 — Home Screen
/// route: /
///
/// @dataSource RecordRepository → recordsProvider (Riverpod AsyncValue)
///
/// @component SummaryCard
///   @props todayAmount: double, monthlyAmount: double
/// @component RecordList (max 6 items)
///   @props records: List<Record> — 按日期降序分组
/// @component RecordItem
///   @props category: CategoryId, note: String, time: String, amount: double
/// @component BottomNav
///   @props onRecordsTap, onVoiceTap, onImageTap, onSettingsTap
/// @interaction SwipeDelete
///   RecordItem 左滑 → 确认弹窗 → RecordRepository.delete(id) → 刷新列表
/// @state EmptyState
///   records.isEmpty → 引导图标 + "暂无记录"

import 'package:flutter/material.dart';
import 'design_tokens.dart';

// ── Models ──────────────────────────────────────────

/// 一条记账记录
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
    final diff = today.difference(date).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    return '${date.month}月${date.day}日';
  }
}

// ── Summary Card ────────────────────────────────────

/// 首页汇总卡片
/// @props todayAmount: 今日支出总额, monthlyAmount: 本月累计支出总额
class SummaryCard extends StatelessWidget {
  final double todayAmount;
  final double monthlyAmount;

  const SummaryCard({
    super.key,
    required this.todayAmount,
    required this.monthlyAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.fg,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日支出', style: TextStyle(
                  color: AppColors.surface.withOpacity(0.7),
                  fontSize: AppText.caption,
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: AppSpacing.xs),
                Text('¥${todayAmount.toStringAsFixed(2)}', style: const TextStyle(
                  color: AppColors.surface,
                  fontSize: AppText.amountMd,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                )),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            color: AppColors.surface.withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本月累计', style: TextStyle(
                  color: AppColors.surface.withOpacity(0.7),
                  fontSize: AppText.caption,
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: AppSpacing.xs),
                Text('¥${monthlyAmount.toStringAsFixed(2)}', style: TextStyle(
                  color: AppColors.surface.withOpacity(0.85),
                  fontSize: AppText.displaySm,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.02,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Record Item ─────────────────────────────────────

/// 单条记录条目
/// @props category: 分类, note: 备注, time: 时间, amount: 金额
class RecordItem extends StatelessWidget {
  final CategoryId category;
  final String note;
  final String time;
  final double amount;

  const RecordItem({
    super.key,
    required this.category,
    required this.note,
    required this.time,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.backgroundColor,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(category.icon, size: 18, color: category.color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note, style: const TextStyle(
                  fontSize: AppText.bodyMd,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fg,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(
                  fontSize: AppText.bodySm,
                  fontWeight: FontWeight.w400,
                  color: AppColors.muted,
                )),
              ],
            ),
          ),
          Text('¥${amount.toStringAsFixed(2)}', style: const TextStyle(
            fontSize: AppText.bodyMd,
            fontWeight: FontWeight.w600,
            color: AppColors.fg,
          )),
        ],
      ),
    );
  }
}

// ── Record List ─────────────────────────────────────

/// 按日期分组的记录列表
/// @props groups: 分组记录列表
class RecordList extends StatelessWidget {
  final List<RecordGroup> groups;

  const RecordList({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: groups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            ...group.records.map((record) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: RecordItem(
                category: record.category,
                note: record.note,
                time: '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')}',
                amount: record.amount,
              ),
            )),
          ],
        );
      }).toList(),
    );
  }
}

// ── Bottom Navigation ───────────────────────────────

class BottomNavItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });
}

/// 底部导航栏
class BottomNav extends StatelessWidget {
  final List<BottomNavItem> items;

  const BottomNav({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: items.map((item) {
          return Expanded(
            child: InkWell(
              onTap: item.onTap,
              borderRadius: AppRadius.mdAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: item.isPrimary ? AppHitTargets.bottomNav : 44,
                      height: item.isPrimary ? AppHitTargets.bottomNav : 44,
                      decoration: BoxDecoration(
                        color: item.isPrimary ? AppColors.accent : AppColors.accentPale,
                        shape: BoxShape.circle,
                        boxShadow: item.isPrimary ? [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.isPrimary ? Colors.white : AppColors.accent,
                        size: item.isPrimary ? 26 : 22,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(item.label, style: TextStyle(
                      fontSize: AppText.label,
                      fontWeight: FontWeight.w500,
                      color: item.isPrimary ? AppColors.accent : AppColors.muted,
                    )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────

/// 空状态
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.muted),
          const SizedBox(height: AppSpacing.md),
          const Text('暂无记录', style: TextStyle(
            fontSize: AppText.displaySm,
            fontWeight: FontWeight.w600,
            color: AppColors.fg,
          )),
          const SizedBox(height: AppSpacing.xs),
          Text('点击底部按钮开始记账', style: TextStyle(
            fontSize: AppText.bodySm,
            fontWeight: FontWeight.w400,
            color: AppColors.muted,
          )),
        ],
      ),
    );
  }
}

// ── Home Screen ─────────────────────────────────────

/// 首页
class HomeScreen extends StatelessWidget {
  final List<RecordGroup> recordGroups;
  final double todayAmount;
  final double monthlyAmount;
  final VoidCallback onVoiceTap;
  final VoidCallback onImageTap;
  final VoidCallback onRecordsTap;
  final VoidCallback onSettingsTap;

  const HomeScreen({
    super.key,
    required this.recordGroups,
    required this.todayAmount,
    required this.monthlyAmount,
    required this.onVoiceTap,
    required this.onImageTap,
    required this.onRecordsTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceLedger', style: TextStyle(
          fontSize: AppText.displaySm,
          fontWeight: FontWeight.w600,
          color: AppColors.fg,
        )),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppRadius.smAll,
          ),
          child: const Icon(Icons.mic, size: 18, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.fg),
            onPressed: () {
              // 手动记账入口
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  SummaryCard(
                    todayAmount: todayAmount,
                    monthlyAmount: monthlyAmount,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (recordGroups.isEmpty)
                    const EmptyState()
                  else
                    RecordList(groups: recordGroups),
                ],
              ),
            ),
          ),
          BottomNav(items: [
            BottomNavItem(
              label: '记录',
              icon: Icons.list_alt,
              onTap: onRecordsTap,
            ),
            BottomNavItem(
              label: '语音',
              icon: Icons.mic,
              onTap: onVoiceTap,
              isPrimary: true,
            ),
            BottomNavItem(
              label: '识图',
              icon: Icons.photo_camera,
              onTap: onImageTap,
            ),
            BottomNavItem(
              label: '设置',
              icon: Icons.settings,
              onTap: onSettingsTap,
            ),
          ]),
        ],
      ),
    );
  }
}