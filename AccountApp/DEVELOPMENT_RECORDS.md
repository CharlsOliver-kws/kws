# 语音记账 App — 开发记录

> 项目路径：D:\myfirstapp\AccountApp
> 技术栈：Flutter 3.x + Dart 3.11.5, Android API 35
> 开始日期：2026-05-17

---

## 开发记录总览

### 1. 首页列表与FAB按钮重叠修复
**问题**：当记录超过8条时，列表内容与底部FAB按钮重叠渲染
**方案**：将 ListView 的 bottom padding 从 100 增加到 160
**文件**：`lib/features/home/home_screen.dart`

### 2. 首页记录数量限制
**需求**：首页只显示最近6条记录，底部显示"查看更多"提示引导用户点击"记录"按钮查看全部
**实现**：
- 遍历分组后的记录，累计取满6条后停止
- 如果总记录数 > 6，在 ListView 末尾添加 `_buildMoreHint` 组件
- "查看更多"为纯文本提示，不可点击
**文件**：`lib/features/home/home_screen.dart`

### 3. 首页汇总卡片
**需求**：在首页顶部展示今日支出和本月累计
**实现**：
- `_calcTodayTotal()` — 按当天起止时间过滤并求和
- `_calcMonthTotal()` — 按当月起始时间过滤并求和
- 渐变背景卡片，左右分栏显示今日/本月
**文件**：`lib/features/home/home_screen.dart`

### 4. 首页UI美化
**改动**：
- 汇总卡片：渐变背景 + 圆角 + 阴影
- 记录条目：Material + InkWell 卡片样式，圆角分类图标（alpha 0.12 背景色）
- 分类颜色：每个分类有独立颜色，金额文字使用分类色
- FAB按钮：圆形改为圆角矩形(52x52)，带边框和半透明背景，底部增加文字标签
- 空状态：大图标 + 提示文字
**文件**：`lib/features/home/home_screen.dart`

### 5. 桌面小组件设计
**布局**：横向并排，左侧"今日"，右侧"本月"
**背景**：深灰色渐变 (#4A635D → #2D3B37)，16dp 圆角
**字体**：标签 11sp，金额 20sp bold，计数 10sp
**数据流**：SQLite → WidgetUpdateService → HomeWidget → SharedPreferences → Kotlin AccountWidgetProvider → RemoteViews
**文件**：
- `android/app/src/main/res/layout/widget_account.xml`
- `android/app/src/main/res/drawable/widget_background.xml`
- `android/app/src/main/kotlin/com/example/account_app/AccountWidgetProvider.kt`
- `lib/core/services/widget_update_service.dart`

### 6. 设置页面重写
**需求**：移除 Whisper/DeepSeek API Key 字段（开发者级别），添加账号管理和常用设置
**新结构**：
- 账号管理：登录/注册入口
- 通知设置：锁屏通知开关、桌面小组件引导
- 外观设置：主题选择（跟随系统/亮色/暗色）
- 数据管理：备份导出、导入恢复、清除数据
- 关于：版本号、使用帮助
**关键修复**：锁屏通知开关在开启时查询数据库获取真实的今日/本月支出数据，而非硬编码的 "0.00"
**文件**：`lib/features/settings/settings_screen.dart`

### 7. 锁屏通知实现
**需求**：添加记录后在锁屏/AOD显示通知，不仅是下拉通知栏
**方案**：Android 前台服务 (Foreground Service)
**实现**：
- Kotlin 服务 `AccountLockScreenService` 继承 `Service`
- 使用 `ServiceCompat.startForeground()` 发送持久化通知
- 通知设置 `setOngoing(true)` + `VISIBILITY_PUBLIC` 确保锁屏可见
- Flutter 通过 MethodChannel 调用原生服务
- 传递参数：今日金额、今日笔数、本月金额、本月笔数
**AndroidManifest 配置**：
- 声明 `FOREGROUND_SERVICE` 和 `POST_NOTIFICATIONS` 权限
- 注册 service，添加 `android:foregroundServiceType="specialUse"`
**文件**：
- `android/app/src/main/kotlin/com/example/account_app/AccountLockScreenService.kt`
- `lib/core/services/lockscreen_service.dart`
- `android/app/src/main/AndroidManifest.xml`

### 8. 启动时通知权限申请
**需求**：应用启动时请求通知权限，被永久拒绝时显示引导对话框
**实现**：
- `main.dart` 的 `main()` 函数中调用 `_requestNotificationPermission()`
- 如果永久拒绝，在 `app.dart` 的 `builder` 中检测并弹出 `NotificationGuideDialog`
- 引导对话框说明如何到系统设置中手动开启权限，提供跳转按钮
**文件**：
- `lib/main.dart`
- `lib/app.dart`

### 9. Android 15 闪退修复
**问题**：`AccountLockScreenService.createChannel()` 中调用 `manager.deleteNotificationChannel(CHANNEL_ID)` 后重新创建，Android 15 抛出 `SecurityException: Not allowed to delete channel with a foreground service`
**修复**：移除 `deleteNotificationChannel` 调用，`createNotificationChannel` 对已存在的channel会自动跳过
**文件**：`android/app/src/main/kotlin/com/example/account_app/AccountLockScreenService.kt`

### 10. 前台服务启动方式修复
**问题**：使用 `context.startService()` 启动前台服务在某些Android版本上失败
**修复**：改为 `context.startForegroundService()` + `ServiceCompat.startForeground()`
**文件**：`android/app/src/main/kotlin/com/example/account_app/AccountLockScreenService.kt`

### 11. 删除记录闪退修复
**问题**：`Dismissible` 的 `confirmDismiss` 弹窗后，`onDismissed` 仍会在context失效时执行导致崩溃
**修复**：
- `confirmDismiss` 正确返回 `bool`（等待用户确认结果）
- `onDismissed` 只在用户确认删除后执行
- 删除前检查 `record.id != null`
**文件**：`lib/features/home/home_screen.dart`

### 12. 编译错误修复汇总
| 错误 | 原因 | 修复 |
|---|---|---|
| `ProviderScope not defined` | main.dart 缺少 import | 添加 `import 'package:flutter_riverpod/flutter_riverpod.dart'` |
| `Context type conflict` | `path` package 导出 `Context` 类与 `BuildContext` 冲突 | 改为 `import 'package:path/path.dart' as p` |
| `SwitchListTile no onTap` | SwitchListTile 只有 `onChanged` 没有 `onTap` | 改用 `onChanged: (_) => ...` |
| `WidgetUpdateService().update()` | `updateWidget` 是静态方法 | 改为 `WidgetUpdateService.updateWidget()` |
| 未使用 import | all_records_screen.dart 等 | 删除无用 import |
| 未使用变量 | startOfDay/startOfMonth | 删除无用变量 |

### 13. 数据源统一修复
**问题**：首页使用 Riverpod 的 `recordsProvider`，但小组件和锁屏通知直接查 SQLite，导致数据不一致
**现状**：`recordsProvider` 内部封装了 `RecordsNotifier`，调用 `loadRecords()` 从 SQLite 读取；小组件通过 `WidgetUpdateService` 独立查 SQLite；锁屏通知通过 `LockScreenService` 直接传值
**方案**：保持现状，各模块独立查询 SQLite 避免 Riverpod context 依赖问题

### 14. PrefsManager 键值更新
**移除**：`whisper_api_key`、`deepseek_api_key`
**保留**：`theme_mode`
**新增**：`notifications_enabled`、`lock_screen_enabled`
**文件**：`lib/data/local/prefs_manager.dart`

### 15. 首次使用引导
**需求**：首次打开APP时显示桌面小组件和锁屏通知的使用说明
**实现**：SharedPreferences 标记 `seen_widget_guide`，首次启动弹出 AlertDialog
**文件**：`lib/features/home/home_screen.dart`

### 16. 启动黑屏修复
**问题**：应用偶尔启动黑屏，偶尔一次成功。原因是 `main()` 中 `await _requestNotificationPermission()` 在 `runApp()` 之前执行，如果权限请求卡顿（系统弹窗加载慢、设备未响应），整个启动流程被阻塞
**修复**：将 `_requestNotificationPermission()` 改为在 `runApp()` 之后异步调用，不阻塞 UI 渲染
**文件**：`lib/main.dart`

### 17. 启动时重复权限检查修复
**问题**：`app.dart` 的 `MaterialApp.builder` 每次重建都调用 `_checkNotificationStatus`，与 `main.dart` 中的权限检查重复，可能导致竞态条件和多次弹窗
**修复**：移除 `app.dart` builder 中的 `_checkNotificationStatus` 调用，权限检查统一在 `main.dart` 中只执行一次
**文件**：`lib/app.dart`

### 18. 图片账单识别功能
**需求**：拍照或从相册选择账单截图，AI 识别图片中的消费金额、分类、日期等信息，自动转为记账记录
**模型**：`qwen3-vl-235b-a22b-thinking`（阿里云 DashScope 多模态生成 API），与现有 ASR 走同一个 multimodal-generation 端点
**实现流程**：
1. 用户点击底部"识图"按钮 → `_processImageBill()`
2. 弹出来源选择（相册/拍照）→ `_pickImageSource()`
3. 通过 `ImageBillService.pickImage()` 获取图片
4. 显示加载弹窗，调用 `recognizeBills()` → 图片压缩（1920px, 85% 质量）→ base64 → POST DashScope
5. AI 返回 JSON 数组（多笔账单），拼接增量输出并解析
6. 显示 `ImageBillDialog` 确认弹窗，展示识别结果，支持逐笔编辑/删除
7. 用户确认后批量写入 SQLite
**底部按钮**：记录 / 语音 / **识图** / 设置（4 个按钮横向排列）
**关键修复**：
- `flutter analyze` 通过，3 个 info 级提示（doc_comment HTML、BuildContext across async gap、unnecessary underscores），无 error
- 解除了 Gradle OOM：`gradle.properties` 从 `-Xmx8G` 改为 `-Xmx2g`（15GB 内存机器）
**新增文件**：
- `lib/core/services/image_bill_service.dart` — 图片识别服务
- `lib/features/home/widgets/image_bill_dialog.dart` — 确认弹窗组件
**修改文件**：
- `pubspec.yaml` — 新增 image_picker
- `lib/core/config/api_config.dart` — 新增 VL 模型常量（恢复 ASR 配置）
- `lib/core/utils/date_helper.dart` — 新增 parseDateTime()
- `lib/features/home/home_screen.dart` — 新增识图按钮 + 识别流程
- `android/.../AndroidManifest.xml` — 新增 CAMERA + READ_MEDIA_IMAGES 权限

### 19. Android 15 / Gradle 构建修复
**Gradle OOM**：JVM 配置 8G 在 15GB 内存机器上 C2 编译线程崩溃，改为 `-Xmx2g`
**文件**：`android/gradle.properties`
**无线连接恢复**：手机端口从 42579 变为 43013，`adb connect 192.168.1.102:43013` 成功

---

## 已知问题

### 1. 小组件载入失败
**现象**：添加桌面小组件时显示"载入窗口小部件时出现问题"
**状态**：未解决。已回退到原始代码。可能原因：home_widget 插件兼容性、AndroidManifest 中 receiver 配置、或 widget_info.xml 配置
**涉及文件**：
- `android/app/src/main/AndroidManifest.xml`（receiver 声明）
- `android/app/src/main/res/xml/widget_info.xml`
- `android/app/src/main/kotlin/com/example/account_app/AccountWidgetProvider.kt`

### 2. 语音输入第三方异常
**现象**：语音输入后出现"第三方异常"提示
**状态**：未完全排查。可能原因：Alibaba DashScope API 超时或返回格式异常、网络问题、API 配额不足
**涉及文件**：
- `lib/core/services/ai_parser.dart`
- `lib/providers/voice_provider.dart`

---

## 关键架构决策

1. **Riverpod 状态管理**：使用 `StateNotifierProvider` 管理记录列表，`recordsProvider` 提供 load/add/delete 操作
2. **GoRouter 路由**：`/` → HomeScreen, `/settings` → SettingsScreen, `/all-records` → AllRecordsScreen
3. **SQLite 本地存储**：sqflite，表名 `records`，索引 `date` 和 `category`
4. **ASR 语音识别**：Alibaba DashScope 多模态 API（qwen3-asr-flash 模型），base64 音频上传
5. **文本解析**：Zhipu GLM-4.5-Air，通过 Anthropic 兼容端点调用
6. **桌面小组件**：home_widget 包 + Kotlin AppWidgetProvider
7. **锁屏通知**：Android 前台服务（specialUse 类型），MethodChannel 通信
8. **权限管理**：permission_handler 包，启动时请求通知权限

---

## 文件变更清单

| 文件 | 改动类型 |
|---|---|
| `lib/features/home/home_screen.dart` | 多次重写：列表限制、UI美化、删除修复、引导弹窗 |
| `lib/features/settings/settings_screen.dart` | 完全重写：移除API Key，添加账号/通知/数据管理 |
| `lib/main.dart` | 启动权限申请改为异步，不阻塞 runApp |
| `lib/app.dart` | 移除 builder 中重复的权限检查 |
| `lib/data/local/prefs_manager.dart` | 更新偏好设置键值 |
| `lib/core/services/widget_update_service.dart` | 新增：小组件数据更新 |
| `lib/core/services/lockscreen_service.dart` | 新增：锁屏通知平台通道 |
| `android/.../AccountLockScreenService.kt` | 新增+修复：Android 15 安全异常 |
| `android/.../AccountWidgetProvider.kt` | 新增：Kotlin 小组件接收器 |
| `android/.../MainActivity.kt` | 添加设置平台通道（打开通知设置） |
| `android/.../widget_account.xml` | 新增：小组件布局 |
| `android/.../widget_background.xml` | 新增：小组件背景渐变 |
| `android/.../AndroidManifest.xml` | 添加 service/receiver 声明和权限 |
| `lib/core/services/image_bill_service.dart` | 新增：图片账单识别服务（image_picker + 阿里云 Qwen3-VL） |
| `lib/features/home/widgets/image_bill_dialog.dart` | 新增：图片账单确认弹窗（预览/编辑/批量添加） |
| `lib/features/home/home_screen.dart` | 新增：识图按钮、图片来源选择、识别流程 |
| `lib/core/config/api_config.dart` | 新增：Qwen3-VL-Thinking 模型配置 |
| `lib/core/utils/date_helper.dart` | 新增：parseDateTime 方法 |
| `pubspec.yaml` | 新增：image_picker 依赖 |
| `android/.../AndroidManifest.xml` | 新增：CAMERA、READ_MEDIA_IMAGES 权限 |

---

## 新增功能：图片账单识别

### 核心流程

```
点击"识图"按钮 → 选择相册/拍照 → 上传图片到阿里云 Qwen3-VL-235b-a22b-thinking
  ↓
AI 识别图片中的多笔账单 → 返回 JSON 数组 → 解析为 List<Record>
  ↓
弹出确认弹窗 → 展示所有识别到的账单 → 支持编辑/删除
  ↓
用户确认 → 批量写入 SQLite
```

### 模型配置

- **模型**：`qwen3-vl-235b-a22b-thinking`（阿里云 DashScope）
- **API**：`POST /api/v1/services/aigc/multimodal-generation/generation`
- **认证**：复用现有的阿里云 API Key（`ApiConfig.aliyunApiKey`）

### 已知限制

- 图片大小限制：最大 1920px，质量 85%
- 识别准确率依赖图片清晰度
- 需要相机和相册权限
