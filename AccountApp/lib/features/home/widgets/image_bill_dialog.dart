import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/design_tokens.dart';
import '../../../data/models/record.dart';

class ImageBillDialog extends ConsumerStatefulWidget {
  const ImageBillDialog({super.key, required this.records});

  final List<Record> records;

  @override
  ConsumerState<ImageBillDialog> createState() => _ImageBillDialogState();
}

class _ImageBillDialogState extends ConsumerState<ImageBillDialog> {
  late List<Record> _records;

  @override
  void initState() {
    super.initState();
    _records = List.from(widget.records);
  }

  double get _total => _records.fold(0, (s, r) => s + r.amount);

  void _editRecord(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _EditSheet(
        record: _records[index],
        onSave: (updated) {
          setState(() => _records[index] = updated);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _deleteRecord(int index) {
    setState(() => _records.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final n = _records.length;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      titlePadding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.md, 0),
      contentPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      actionsPadding: const EdgeInsets.all(AppSpacing.md),
      title: Text('识别到 $n 笔账单',
        style: const TextStyle(
          fontSize: AppText.displaySm,
          fontWeight: FontWeight.w600,
          color: AppColors.fg,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _records.length,
          itemBuilder: (_, i) {
            final r = _records[i];
            final cat = r.categoryEnum;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: cat.backgroundColor,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(cat.icon, size: 16, color: cat.color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(r.note.isNotEmpty ? r.note : cat.label,
                                  style: const TextStyle(
                                    fontSize: AppText.bodyMd,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.fg,
                                  ),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text('¥${r.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: AppText.bodyMd,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.fg,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(cat.label, style: const TextStyle(
                                fontSize: AppText.bodySm,
                                color: AppColors.muted,
                              )),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _editRecord(i),
                                child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              GestureDetector(
                                onTap: () => _deleteRecord(i),
                                child: const Icon(Icons.close, size: 18, color: AppColors.danger),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('合计 ¥${_total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: AppText.bodyLg,
                fontWeight: FontWeight.w700,
                color: AppColors.fg,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionChip('取消', AppColors.muted, () => Navigator.pop(context, <Record>[])),
                const SizedBox(width: AppSpacing.sm),
                _buildActionChip('确认添加', AppColors.accent,
                  () => Navigator.pop(context, _records),
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(String label, Color color, VoidCallback onTap,
      {bool isPrimary = false}) {
    return Material(
      color: isPrimary ? color : Colors.transparent,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: isPrimary ? null : Border.all(color: AppColors.border),
            borderRadius: AppRadius.mdAll,
          ),
          child: Text(label, style: TextStyle(
            fontSize: AppText.bodySm,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : color,
          )),
        ),
      ),
    );
  }
}

// ── Edit Sheet ────────────────────────────────────────

class _EditSheet extends StatefulWidget {
  final Record record;
  final void Function(Record) onSave;

  const _EditSheet({required this.record, required this.onSave});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  late CategoryId _category;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.record.amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: widget.record.note);
    _category = widget.record.categoryEnum;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('编辑记录', style: TextStyle(
            fontSize: AppText.displaySm, fontWeight: FontWeight.w600, color: AppColors.fg,
          )),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '金额',
              prefixText: '¥ ',
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              labelText: '备注',
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: CategoryId.values.map((cat) {
              final selected = cat == _category;
              return ChoiceChip(
                label: Text(cat.label),
                selected: selected,
                onSelected: (_) => setState(() => _category = cat),
                selectedColor: AppColors.accentPale,
                labelStyle: TextStyle(
                  color: selected ? AppColors.accent : AppColors.muted,
                  fontSize: AppText.label,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  side: BorderSide(
                    color: selected ? AppColors.accent : AppColors.border,
                  ),
                ),
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              widget.onSave(widget.record.copyWith(
                amount: double.tryParse(_amountCtrl.text) ?? widget.record.amount,
                category: _category.id,
                note: _noteCtrl.text,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
            ),
            child: const Text('保存'),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
