import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/design_tokens.dart';
import '../../core/utils/date_helper.dart';
import '../../data/models/record.dart';
import '../../providers/records_provider.dart';
import '../../providers/voice_provider.dart';
import '../../core/services/ai_parser.dart';
import '../../core/services/image_bill_service.dart';
import 'widgets/voice_button.dart';
import 'widgets/recording_overlay.dart';
import 'widgets/manual_entry_dialog.dart';
import 'widgets/image_bill_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
    });
  }

  Future<void> _checkAndShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('seen_widget_guide') ?? false;
    if (!hasSeen && mounted) {
      _showGuide();
      prefs.setBool('seen_widget_guide', true);
    }
  }

  void _showGuide() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: const Text('提示', style: TextStyle(
          fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
        )),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('桌面小组件'),
            SizedBox(height: 4),
            Text('长按手机桌面空白处 → 选择"小组件" → 找到"VoiceLedger"添加到桌面',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text('锁屏常驻通知'),
            SizedBox(height: 4),
            Text('添加记录后会自动显示锁屏通知，可在设置中关闭',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('知道了', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final recordsAsync = ref.watch(recordsProvider);
        final voiceState = ref.watch(voiceStateProvider);
        final isRecording = voiceState.state == RecordingState.recording;

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
              margin: const EdgeInsets.all(12),
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
                onPressed: () => _showManualEntry(context, ref),
              ),
            ],
          ),
          body: Stack(
            children: [
              recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return _EmptyState();
                  }
                  final todayTotal = _calcTodayTotal(records);
                  final monthTotal = _calcMonthTotal(records);
                  final groups = groupRecords(records);
                  final visibleGroups = <RecordGroup>[];
                  int count = 0;
                  for (final group in groups) {
                    if (count >= 6) break;
                    final take = (6 - count).clamp(0, group.records.length);
                    if (take < group.records.length) {
                      visibleGroups.add(RecordGroup(
                        date: group.date,
                        records: group.records.take(take).toList(),
                      ));
                    } else {
                      visibleGroups.add(group);
                    }
                    count += take;
                  }

                  return Column(
                    children: [
                      _SummaryCard(
                        todayAmount: todayTotal,
                        monthlyAmount: monthTotal,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: _RecordList(
                            groups: visibleGroups,
                            onDismiss: (id) async {
                              await ref.read(recordsProvider.notifier).deleteRecord(id);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                error: (e, _) => Center(child: Text('加载失败: $e', style: const TextStyle(color: AppColors.danger))),
              ),
              if (isRecording) const RecordingOverlay(),
            ],
          ),
          bottomNavigationBar: _BottomNav(
            onRecordsTap: () => context.push('/all-records'),
            onRecordingComplete: (path) => _processVoice(context, ref, path),
            onImageTap: () => _processImageBill(context, ref),
            onSettingsTap: () => context.push('/settings'),
          ),
        );
      },
    );
  }

  void _showManualEntry(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => ManualEntrySheet(
        onSave: (record) async {
          Navigator.pop(context);
          await ref.read(recordsProvider.notifier).addRecord(record);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('记录已添加')),
            );
          }
        },
      ),
    );
  }

  Future<void> _processVoice(BuildContext context, WidgetRef ref, String path) async {
    final notifier = ref.read(voiceStateProvider.notifier);
    notifier.setProcessing();

    try {
      final parser = AiParserService();
      final record = await parser.processVoice(path);
      await ref.read(recordsProvider.notifier).addRecord(record);
      notifier.setSuccess();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('记录已添加')),
        );
      }
      await Future.delayed(const Duration(milliseconds: 800));
      notifier.reset();
    } catch (e) {
      notifier.setError(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理失败: $e')),
        );
      }
    }
  }

  Future<void> _processImageBill(BuildContext context, WidgetRef ref) async {
    final service = ImageBillService();
    final source = await _pickImageSource(context);
    if (source == null) return;

    final xFile = await service.pickImage(fromCamera: source);
    if (xFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );

    try {
      final records = await service.recognizeBills(xFile.path);
      if (context.mounted) {
        Navigator.of(context).pop();

        if (records.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未能识别到账单信息，请重试')),
          );
          return;
        }

        final confirmedRecords = await showDialog<List<Record>>(
          context: context,
          builder: (_) => ImageBillDialog(records: records),
        );

        if (confirmedRecords != null && confirmedRecords.isNotEmpty) {
          for (final record in confirmedRecords) {
            await ref.read(recordsProvider.notifier).addRecord(record);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已添加 ${confirmedRecords.length} 条记录')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('识别失败: $e')),
        );
      }
    }
  }

  Future<bool?> _pickImageSource(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: const Text('选择图片来源', style: TextStyle(
          fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.accent),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, false),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.accent),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }

  double _calcTodayTotal(List<Record> records) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return records
        .where((r) => r.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && r.date.isBefore(endOfDay))
        .fold<double>(0, (sum, r) => sum + r.amount);
  }

  double _calcMonthTotal(List<Record> records) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return records
        .where((r) => r.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))))
        .fold<double>(0, (sum, r) => sum + r.amount);
  }
}

// ── Summary Card ────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double todayAmount;
  final double monthlyAmount;

  const _SummaryCard({required this.todayAmount, required this.monthlyAmount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

class _RecordItem extends StatelessWidget {
  final Record record;
  final VoidCallback onDismiss;

  const _RecordItem({required this.record, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cat = record.categoryEnum;
    return Dismissible(
      key: Key('record_${record.id ?? record.date.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: AppRadius.mdAll,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
            title: const Text('确认删除', style: TextStyle(
              fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
            )),
            content: const Text('确定要删除这条记录吗？', style: TextStyle(
              fontSize: AppText.bodyMd, color: AppColors.muted,
            )),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消', style: TextStyle(color: AppColors.muted)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDismiss(),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    record.note,
                    style: const TextStyle(
                      fontSize: AppText.bodyMd,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fg,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateHelper.formatTime(record.date),
                    style: const TextStyle(
                      fontSize: AppText.bodySm,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text('¥${record.amount.toStringAsFixed(2)}', style: const TextStyle(
              fontSize: AppText.bodyMd,
              fontWeight: FontWeight.w600,
              color: AppColors.fg,
            )),
          ],
        ),
      ),
    );
  }
}

// ── Record List ─────────────────────────────────────

class _RecordList extends StatelessWidget {
  final List<RecordGroup> groups;
  final void Function(int id) onDismiss;

  const _RecordList({required this.groups, required this.onDismiss});

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
            ...group.records.map((record) => _RecordItem(
              record: record,
              onDismiss: record.id != null ? () => onDismiss(record.id!) : () {},
            )),
          ],
        );
      }).toList(),
    );
  }
}

// ── Bottom Navigation ───────────────────────────────

class _BottomNav extends StatelessWidget {
  final VoidCallback onRecordsTap;
  final ValueChanged<String> onRecordingComplete;
  final VoidCallback onImageTap;
  final VoidCallback onSettingsTap;

  const _BottomNav({
    required this.onRecordsTap,
    required this.onRecordingComplete,
    required this.onImageTap,
    required this.onSettingsTap,
  });

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
        children: [
          _NavItem(label: '记录', icon: Icons.list_alt, onTap: onRecordsTap),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VoiceButton(onRecordingComplete: onRecordingComplete),
                  const SizedBox(height: AppSpacing.xs),
                  Text('语音', style: TextStyle(
                    fontSize: AppText.label,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  )),
                ],
              ),
            ),
          ),
          _NavItem(label: '识图', icon: Icons.photo_camera, onTap: onImageTap),
          _NavItem(label: '设置', icon: Icons.settings, onTap: onSettingsTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isPrimary ? AppHitTargets.bottomNav : 44,
                height: isPrimary ? AppHitTargets.bottomNav : 44,
                decoration: BoxDecoration(
                  color: isPrimary ? AppColors.accent : AppColors.accentPale,
                  shape: BoxShape.circle,
                  boxShadow: isPrimary ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : AppColors.accent,
                  size: isPrimary ? 26 : 22,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: TextStyle(
                fontSize: AppText.label,
                fontWeight: FontWeight.w500,
                color: isPrimary ? AppColors.accent : AppColors.muted,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty State ─────────────────────────────────────

class _EmptyState extends StatelessWidget {
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
            Text('点击底部按钮开始记账', style: TextStyle(
              fontSize: AppText.bodySm,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
            )),
          ],
        ),
      ),
    );
  }
}
