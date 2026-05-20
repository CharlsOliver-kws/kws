import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/config/design_tokens.dart';
import '../../data/local/prefs_manager.dart';
import '../../providers/theme_provider.dart';
import '../../core/services/widget_update_service.dart';
import '../../core/services/lockscreen_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lockScreenEnabled = false;
  bool _widgetEnabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final lockScreen = await PrefsManager.getLockScreenEnabled();
    if (mounted) {
      setState(() {
        _lockScreenEnabled = lockScreen;
        _widgetEnabled = false;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fg),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('设置', style: TextStyle(
          fontSize: AppText.displaySm,
          fontWeight: FontWeight.w600,
          color: AppColors.fg,
        )),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _loaded ? _buildContent() : const Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );
  }

  Widget _buildContent() {
    return Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeModeProvider);
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            // ── Account ──
            const _SectionHeader(title: '账号'),
            _SettingsTile(
              icon: Icons.person_outline,
              title: '登录 / 注册',
              onTap: () => _showSnackBar('功能开发中'),
            ),
            const _Divider(),

            // ── Notifications ──
            const _SectionHeader(title: '通知'),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: '通知权限',
              onTap: () => openAppSettings(),
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: '锁屏通知',
              trailing: Switch(
                value: _lockScreenEnabled,
                onChanged: (v) => _toggleLockScreen(v, ref),
                activeColor: AppColors.accent,
              ),
            ),
            _SettingsTile(
              icon: Icons.widgets_outlined,
              title: '桌面小组件',
              subtitle: _widgetEnabled ? '已添加' : '未添加',
              onTap: _showWidgetGuide,
            ),
            const _Divider(),

            // ── Appearance ──
            const _SectionHeader(title: '外观'),
            _ThemeSelector(
              value: themeMode,
              onChanged: (mode) async {
                final modeStr = switch (mode) {
                  ThemeMode.light => 'light',
                  ThemeMode.dark => 'dark',
                  _ => 'system',
                };
                await PrefsManager.setThemeMode(modeStr);
                ref.read(themeModeProvider.notifier).state = mode;
              },
            ),
            const _Divider(),

            // ── Data ──
            const _SectionHeader(title: '数据'),
            _SettingsTile(
              icon: Icons.backup_outlined,
              title: '数据备份',
              onTap: () => _showSnackBar('功能开发中'),
            ),
            _SettingsTile(
              icon: Icons.restore_outlined,
              title: '数据恢复',
              onTap: () => _showSnackBar('功能开发中'),
            ),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: '清除所有数据',
              titleColor: AppColors.danger,
              onTap: _showClearDialog,
            ),
            const _Divider(),

            // ── About ──
            const _SectionHeader(title: '关于'),
            _SettingsTile(
              icon: Icons.info_outline,
              title: '版本号',
              trailing: const Text('1.0.0', style: TextStyle(
                fontSize: AppText.bodySm, color: AppColors.muted,
              )),
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              title: '使用帮助',
              onTap: _showHelpDialog,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }

  Future<void> _toggleLockScreen(bool value, WidgetRef ref) async {
    setState(() => _lockScreenEnabled = value);
    await PrefsManager.setLockScreenEnabled(value);
    if (value) {
      await LockScreenService.show(
        todayAmount: '0.00',
        todayCount: 0,
        monthlyAmount: '0.00',
        monthlyCount: 0,
      );
      // 实际数据由 records_provider 的 _updateLockScreen 更新
    } else {
      LockScreenService.hide();
    }
  }

  void _showWidgetGuide() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: const Text('添加桌面小组件', style: TextStyle(
          fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
        )),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. 长按手机桌面空白处'),
            SizedBox(height: 8),
            Text('2. 选择"小组件"'),
            SizedBox(height: 8),
            Text('3. 找到"VoiceLedger"拖拽到桌面'),
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

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: const Text('确认清除', style: TextStyle(
          fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
        )),
        content: const Text('此操作将清空所有记账数据，不可恢复。',
          style: TextStyle(fontSize: AppText.bodyMd, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PrefsManager.clearAll();
              await WidgetUpdateService.updateWidget();
              LockScreenService.hide();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('数据已清除')),
                );
              }
            },
            child: const Text('确认清除', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        title: const Text('使用帮助', style: TextStyle(
          fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
        )),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpItem('语音记账', '长按底部"语音"按钮开始录音，松开后自动识别金额和分类。'),
              _HelpItem('手动记账', '点击右上角"+"按钮，填写金额、选择分类和日期后保存。'),
              _HelpItem('查看记录', '点击底部"记录"按钮查看全部记账历史。'),
              _HelpItem('删除记录', '在首页列表左滑记录条，点击删除按钮确认。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }
}

// ── Internal widgets ──────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(title, style: const TextStyle(
        fontSize: AppText.label,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.04,
      )),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: titleColor ?? AppColors.muted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: AppText.bodyMd,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? AppColors.fg,
                  )),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(subtitle!, style: const TextStyle(
                        fontSize: AppText.bodySm, color: AppColors.muted,
                      )),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode value;
  final void Function(ThemeMode) onChanged;

  const _ThemeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, size: 20, color: AppColors.muted),
              const SizedBox(width: AppSpacing.md),
              const Text('主题模式', style: TextStyle(
                fontSize: AppText.bodyMd, fontWeight: FontWeight.w500, color: AppColors.fg,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('跟随系统')),
                ButtonSegment(value: ThemeMode.light, label: Text('浅色')),
                ButtonSegment(value: ThemeMode.dark, label: Text('深色')),
              ],
              selected: {value},
              onSelectionChanged: (set) => onChanged(set.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.accent;
                  return AppColors.muted;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String title;
  final String body;
  const _HelpItem(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: AppText.bodyMd,
            fontWeight: FontWeight.w600,
            color: AppColors.fg,
          )),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: const TextStyle(
            fontSize: AppText.bodySm,
            color: AppColors.muted,
          )),
        ],
      ),
    );
  }
}
