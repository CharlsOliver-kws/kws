# Open Design UI 全量接入任务清单

## Step 1: 迁移 design tokens + 主题系统
- [ ] 新建 `lib/core/config/design_tokens.dart` — 从 Open Design 搬入
- [ ] 覆写 `lib/core/config/app_theme.dart` — 从 Open Design 搬入，import 改为 `design_tokens.dart`
- [ ] 修改 `lib/app.dart` — `AppTheme.lightTheme` → `AppTheme.light`，`AppTheme.darkTheme` → `AppTheme.dark`

## Step 2: 用 CategoryId 枚举替换分类系统
- [ ] 删除 `lib/core/constants/categories.dart` — 被 CategoryId 枚举替代
- [ ] 删除 `lib/data/models/category.dart` — 被 CategoryId 枚举替代
- [ ] 修改 `lib/core/constants/prompts.dart` — 分类列表改为英文ID

## Step 3: 数据库迁移 — 分类字段改为英文ID
- [ ] 修改 `lib/data/local/database.dart` — version 1→2，添加 CASE 迁移（中文→英文ID）
- [ ] 修改 `lib/data/models/record.dart` — 添加 `categoryEnum` 便捷 getter

## Step 4: 增强 Voice Provider — 5 状态支持
- [ ] 修改 `lib/providers/voice_provider.dart` — RecordingState 扩展为 5 种，增加 errorMessage，增加 setProcessing/setSuccess/setError

## Step 5: 接入首页 HomeScreen
- [ ] 覆写 `lib/features/home/home_screen.dart` — 用 Open Design 组件体系，接入 Riverpod Provider，保留 Dismissible 左滑删除

## Step 6: 接入录音遮罩
- [ ] 覆写 `lib/features/home/widgets/recording_overlay.dart` — 用 Open Design VoiceRecordingOverlay + 波形动画，接入 5 状态
- [ ] 修改 `lib/features/home/widgets/voice_button.dart` — 外观对齐 design tokens

## Step 7: 接入手动记账
- [ ] 覆写 `lib/features/home/widgets/manual_entry_dialog.dart` — 用 Open Design ManualEntrySheet（底部弹窗），CategoryId 枚举分类网格

## Step 8: 接入识图确认
- [ ] 覆写 `lib/features/home/widgets/image_bill_dialog.dart` — 用 Open Design ImageConfirmDialog + EditSheet

## Step 9: 接入全部记录页
- [ ] 覆写 `lib/features/home/all_records_screen.dart` — 用 Open Design AllRecordsScreen

## Step 10: 接入设置页
- [ ] 覆写 `lib/features/settings/settings_screen.dart` — 用 Open Design SettingsScreen，接入 themeModeProvider + PrefsManager

## Step 11: 更新 app.dart 和 main.dart
- [ ] 修改 `lib/app.dart` — theme 引用改为 `AppTheme.light` / `AppTheme.dark`

## Step 12: 修改 prompt 模板
- [ ] 修改 `lib/core/constants/prompts.dart` — 分类列表改为英文ID

## Step 13: 修改 AI 解析服务
- [ ] 修改 `lib/core/services/ai_parser.dart` — 确认 category 返回英文ID
- [ ] 修改 `lib/core/services/image_bill_service.dart` — prompt 中分类改为英文ID

---

## 验证清单
- [ ] `flutter analyze` 无错误
- [ ] 首页显示 Open Design 样式的 SummaryCard + RecordList
- [ ] 语音按钮 → 录音遮罩 5 状态动画
- [ ] 语音记账 → AI 返回英文ID → 存入数据库
- [ ] 手动记账底部弹窗 → 选择分类 → 保存
- [ ] 识图确认弹窗 → 保存
- [ ] 全部记录页正确显示
- [ ] 设置页主题切换/锁屏开关/清除数据
- [ ] 已有数据迁移成功（中文→英文ID）
