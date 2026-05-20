/// 手动记账弹窗 — Manual Entry Sheet
/// route: shown as bottom sheet when user taps "+" on AppBar
///
/// @dataSource category list is static (8 categories)
/// @dataSink RecordRepository.insert(record) → recordsProvider.refresh()
///
/// @component ManualEntrySheet
///   @props onSave: void Function({amount, category, date, time, note})
///
/// @validation amount != null && amount > 0
/// @states amountInvalid: 金额为空或 ≤0 时显示错误提示

import 'package:flutter/material.dart';
import 'design_tokens.dart';

// ── Entry Data ────────────────────────────────────────

/// 手动记账数据
class ManualEntryData {
  final double amount;
  final CategoryId category;
  final DateTime date;
  final TimeOfDay time;
  final String note;

  const ManualEntryData({
    required this.amount,
    required this.category,
    required this.date,
    required this.time,
    this.note = '',
  });
}

// ── Sheet ─────────────────────────────────────────────

/// 手动记账底部弹窗
/// @props onSave: 保存回调，传入完整记账数据
class ManualEntrySheet extends StatefulWidget {
  final void Function(ManualEntryData data) onSave;

  const ManualEntrySheet({super.key, required this.onSave});

  @override
  State<ManualEntrySheet> createState() => _ManualEntrySheetState();
}

class _ManualEntrySheetState extends State<ManualEntrySheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  CategoryId _category = CategoryId.food;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _amountError = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _handleSave() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = true);
      return;
    }
    setState(() => _amountError = false);
    widget.onSave(ManualEntryData(
      amount: amount,
      category: _category,
      date: _date,
      time: _time,
      note: _noteCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // title
            const Text('手动记账', style: TextStyle(
              fontSize: AppText.displaySm,
              fontWeight: FontWeight.w600,
              color: AppColors.fg,
            )),
            const SizedBox(height: AppSpacing.lg),
            // 1. amount input
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '金额',
                hintText: '0.00',
                prefixText: '¥ ',
                errorText: _amountError ? '金额不能为空且必须大于 0' : null,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: const BorderSide(color: AppColors.danger),
                ),
              ),
              style: const TextStyle(
                fontSize: AppText.amountMd,
                fontWeight: FontWeight.w700,
                color: AppColors.fg,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 2. category selector
            const Text('分类', style: TextStyle(
              fontSize: AppText.bodySm,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            )),
            const SizedBox(height: AppSpacing.sm),
            _CategoryGrid(
              selected: _category,
              onSelect: (cat) => setState(() => _category = cat),
            ),
            const SizedBox(height: AppSpacing.md),
            // 3. date & time row
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    label: '日期',
                    displayText: '${_date.month}月${_date.day}日',
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _date = date);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DatePickerButton(
                    label: '时间',
                    displayText: _time.format(context),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (time != null) setState(() => _time = time);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // 4. note input
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                labelText: '备注（选填）',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdAll,
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: AppText.bodyMd, color: AppColors.fg),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 5. save button
            SizedBox(
              height: AppHitTargets.minTouch + 8,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                  textStyle: const TextStyle(
                    fontSize: AppText.bodyLg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('保存'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ── Category Grid ─────────────────────────────────────

/// 分类选择网格
class _CategoryGrid extends StatelessWidget {
  final CategoryId selected;
  final void Function(CategoryId) onSelect;

  const _CategoryGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: CategoryId.values.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentPale : AppColors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat.icon, size: 22, color: cat.color),
                const SizedBox(height: AppSpacing.xs),
                Text(cat.label, style: TextStyle(
                  fontSize: AppText.label,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.accent : AppColors.muted,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Date / Time Picker Button ─────────────────────────

class _DatePickerButton extends StatelessWidget {
  final String label;
  final String displayText;
  final VoidCallback onTap;

  const _DatePickerButton({
    required this.label,
    required this.displayText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.muted),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  fontSize: AppText.label, color: AppColors.muted,
                )),
                Text(displayText, style: const TextStyle(
                  fontSize: AppText.bodySm,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fg,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}