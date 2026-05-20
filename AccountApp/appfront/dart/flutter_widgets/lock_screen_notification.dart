/// 锁屏通知 / 下拉通知栏 — Lock Screen Notification
/// platform: Android (NotificationManager + Foreground Service) / iOS (UNNotification)
///
/// @dataSource LockScreenService — 每次记账后自动刷新
///
/// @component LockScreenNotification
///   @props todayAmount: double — 今日支出
///   @props todayCount: int — 今日笔数
///   @props monthlyAmount: double — 本月累计
///   @props monthlyCount: int — 本月笔数
///
/// @interaction
///   点击通知 → 打开 App 首页
///   滑动清除 → 移除通知（下次记账时重新显示）
///   设置页关闭开关 → 立即隐藏通知

import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// 锁屏通知卡片 — 模拟系统通知样式
class LockScreenNotification extends StatelessWidget {
  final double todayAmount;
  final int todayCount;
  final double monthlyAmount;
  final int monthlyCount;

  const LockScreenNotification({
    super.key,
    required this.todayAmount,
    required this.todayCount,
    required this.monthlyAmount,
    required this.monthlyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.95),
          borderRadius: AppRadius.lgAll,
          boxShadow: AppShadows.lg,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0,
              ),
              child: Row(
                children: [
                  // app icon
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: const Icon(Icons.mic, size: 11, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('VoiceLedger', style: TextStyle(
                    fontSize: AppText.label,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fg,
                  )),
                  const Spacer(),
                  Text('刚刚', style: TextStyle(
                    fontSize: AppText.label,
                    color: AppColors.muted.withOpacity(0.7),
                  )),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
                ],
              ),
            ),
            // summary row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _SummaryBadge(
                    label: '今日',
                    amount: todayAmount,
                    count: todayCount,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryBadge(
                    label: '本月',
                    amount: monthlyAmount,
                    count: monthlyCount,
                    highlight: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final double amount;
  final int count;
  final bool highlight;

  const _SummaryBadge({
    required this.label,
    required this.amount,
    required this.count,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: AppRadius.smAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
              fontSize: AppText.label,
              fontWeight: FontWeight.w600,
              color: AppColors.muted.withOpacity(0.8),
            )),
            const SizedBox(height: 2),
            Text('¥${amount.toStringAsFixed(2)}', style: TextStyle(
              fontSize: AppText.bodyLg,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.accent : AppColors.fg,
              letterSpacing: -0.02,
            )),
            Text('$count笔', style: const TextStyle(
              fontSize: AppText.label,
              color: AppColors.muted,
            )),
          ],
        ),
      ),
    );
  }
}