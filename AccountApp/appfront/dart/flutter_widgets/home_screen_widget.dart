/// 桌面小组件 — Home Screen Widget
/// platform: Android (Kotlin AccountWidgetProvider) / iOS (WidgetKit)
///
/// @dataSource HomeWidget.saveWidgetData() — 每次记账后更新
///
/// @component HomeScreenWidget
///   @props todayAmount: double — 今日支出
///   @props todayCount: int — 今日笔数
///   @props monthlyAmount: double — 本月累计
///   @props monthlyCount: int — 本月笔数
///   @props lastNote: String? — 最近一笔备注（可选）
///
/// @tapBehavior 点击 → 打开 App 首页
/// @size Android: 4×2 grid (approx 280×140dp)
/// @size iOS: systemSmall (158×158pt) / systemMedium (329×158pt)

import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// 桌面小组件 — 中号 (Android 4×2 / iOS systemMedium)
class HomeScreenWidget extends StatelessWidget {
  final double todayAmount;
  final int todayCount;
  final double monthlyAmount;
  final int monthlyCount;
  final String? lastNote;

  const HomeScreenWidget({
    super.key,
    required this.todayAmount,
    required this.todayCount,
    required this.monthlyAmount,
    required this.monthlyCount,
    this.lastNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // left: today
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('今日支出', style: TextStyle(
                  fontSize: AppText.label,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted.withOpacity(0.8),
                  letterSpacing: 0.04,
                )),
                const SizedBox(height: AppSpacing.xs),
                Text('¥${todayAmount.toStringAsFixed(2)}', style: const TextStyle(
                  fontSize: AppText.amountMd,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fg,
                  letterSpacing: -0.02,
                )),
                const SizedBox(height: 2),
                Text('$todayCount笔', style: const TextStyle(
                  fontSize: AppText.label,
                  color: AppColors.muted,
                )),
              ],
            ),
          ),
          // divider
          Container(
            width: 1, height: 56,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            color: AppColors.border,
          ),
          // right: monthly
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('本月累计', style: TextStyle(
                  fontSize: AppText.label,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted.withOpacity(0.8),
                  letterSpacing: 0.04,
                )),
                const SizedBox(height: AppSpacing.xs),
                Text('¥${monthlyAmount.toStringAsFixed(2)}', style: const TextStyle(
                  fontSize: AppText.displayMd,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: -0.02,
                )),
                const SizedBox(height: 2),
                Text('$monthlyCount笔', style: const TextStyle(
                  fontSize: AppText.label,
                  color: AppColors.muted,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 桌面小组件 — 小号 (iOS systemSmall)
class HomeScreenWidgetSmall extends StatelessWidget {
  final double todayAmount;
  final int todayCount;

  const HomeScreenWidgetSmall({
    super.key,
    required this.todayAmount,
    required this.todayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadows.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.smAll,
                ),
                child: const Icon(Icons.mic, size: 11, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('今天', style: TextStyle(
                fontSize: AppText.label,
                fontWeight: FontWeight.w600,
                color: AppColors.muted.withOpacity(0.8),
                letterSpacing: 0.04,
              )),
            ],
          ),
          const Spacer(),
          Text('¥${todayAmount.toStringAsFixed(2)}', style: const TextStyle(
            fontSize: AppText.amountMd,
            fontWeight: FontWeight.w700,
            color: AppColors.fg,
            letterSpacing: -0.02,
          )),
          const SizedBox(height: 2),
          Text('共 $todayCount 笔支出', style: const TextStyle(
            fontSize: AppText.label,
            color: AppColors.muted,
          )),
        ],
      ),
    );
  }
}