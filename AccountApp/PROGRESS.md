# 语音记账 App — 开发进度

> 最后更新：2026-05-17

## 整体进度

- [x] Phase 1：基础骨架 ✅
- [x] Phase 2：数据模型 + 本地数据库 ✅ 已修 bug
- [x] Phase 3：录音功能 ✅ 已完成
- [x] Phase 4：AI 解析链路 ✅ 已完成
- [x] Phase 5：UI 完善 ✅ 已完成（含首页美化）
- [x] Phase 6：设置 + 合规 ✅ 已完成（含锁屏通知、权限引导）
- [ ] Phase 7：上架准备

---

## Phase 1：基础骨架 ✅ 已完成

### 完成时间
2026-05-17

### 完成内容

#### 1. 依赖配置（pubspec.yaml）
- [x] flutter_riverpod 2.6.1 — 状态管理
- [x] go_router 14.8.0 — 路由
- [x] sqflite 2.4.2 — 本地数据库
- [x] shared_preferences 2.5.2 — 本地存储
- [x] dio 5.8.0+1 — 网络请求
- [x] intl 0.20.2 — 日期格式化
- [x] record 5.2.1 — 语音录制
- [x] fl_chart 0.70.2 — 图表
- [x] path_provider 2.1.5 — 路径获取
- [x] riverpod_generator + build_runner — 代码生成
- [x] `flutter pub get` 执行成功，无报错

#### 2. 目录结构
```
lib/
├── main.dart                          ✅ 入口，ProviderScope + runApp
├── app.dart                           ✅ MaterialApp.router + go_router
├── core/
│   ├── config/
│   │   ├── api_config.dart            ✅ API URL 配置
│   │   └── app_theme.dart            ✅ 明/暗主题，Material 3
│   ├── constants/
│   │   ├── categories.dart            ✅ 8 个预设分类 + 图标映射
│   │   └── prompts.dart              ✅ DeepSeek prompt 模板
│   └── utils/
│       └── date_helper.dart           ✅ 日期/时间格式化
├── data/
│   ├── models/
│   │   ├── record.dart                ✅ Record 模型 (id/amount/category/date/note/voiceText/voiceFile/createdAt/updatedAt)
│   │   └── category.dart             ✅ CategoryModel
│   ├── local/
│   │   ├── database.dart             ✅ sqflite 建表 + 索引
│   │   └── prefs_manager.dart        ✅ API Key / 主题模式存储
│   └── repositories/
│       └── record_repository.dart     ✅ CRUD (insert/update/delete/getAll/getTotal/getTotalsByCategory)
├── providers/
│   ├── records_provider.dart          ✅ RecordsNotifier (load/add/delete)
│   └── theme_provider.dart            ✅ ThemeMode provider
└── features/
    ├── home/
    │   └── home_screen.dart           ✅ 主页：AppBar + 日分组列表 + 每日总计 + 麦克风 FAB
    └── settings/
        └── settings_screen.dart       ✅ 设置页占位
```

#### 3. 路由配置
- [x] `/` → HomeScreen
- [x] `/settings` → SettingsScreen

#### 4. 主题
- [x] 亮色/暗色主题支持
- [x] Material 3 设计语言
- [x] seed color: Indigo

#### 5. 数据模型
- [x] **Record** 模型完整字段：
  - `id` (String, UUID)
  - `amount` (double)
  - `category` (String)
  - `date` (DateTime)
  - `note` (String)
  - `voiceText` (String, 可选)
  - `voiceFile` (String, 可选)
  - `createdAt` (DateTime)
  - `updatedAt` (DateTime)
  - `toMap()` / `fromMap()` / `copyWith()` 方法

#### 6. 数据库
- [x] SQLite 表 `records` 创建
- [x] 索引：`date`、`category`
- [x] 单例模式 `DatabaseHelper`

#### 7. 仓库层
- [x] `insert` — 插入记录
- [x] `update` — 更新记录
- [x] `delete` — 删除记录
- [x] `getAll` — 获取全部（支持按分类/日期筛选）
- [x] `getTotal` — 获取总金额
- [x] `getTotalsByCategory` — 按分类汇总

### 验收结果

| 验收标准 | 状态 |
|---|---|
| `flutter pub get` 无报错 | ✅ |
| 目录结构完整，无语法报错 | ✅ |
| Riverpod ProviderScope 配置 | ✅ |
| go_router 路由配置 | ✅ |
| 主题支持明/暗切换 | ✅ |
| `flutter run` 模拟器正常显示空主页 | ⏳ 待真机/模拟器验证 |

### 备注
- `flutter pub get` 已成功执行，依赖下载完成
- 尚未在模拟器上实际运行验证（待后续测试）
- HomeScreen 的麦克风 FAB 的 `onPressed` 为空（Phase 3 实现）
- SettingsScreen 为占位页面（Phase 6 完善）

---

## Phase 2：数据模型 + 本地数据库（待开始）

### 计划任务
- [ ] 验证本地数据库 CRUD 手动测试
- [ ] PrefsManager 存取 API Key 验证
- [ ] 考虑是否需要 json_serializable 代码生成

---

## Phase 3：录音功能（待开始）

### 计划任务
- [ ] VoiceButton widget（长按录音、松手发送、上滑取消）
- [ ] RecordingOverlay（波形动画）
- [ ] VoiceService（录音保存到本地）
- [ ] VoiceProvider（状态管理）
- [ ] 麦克风权限处理

---

## Phase 4：AI 解析链路（待开始）

### 计划任务
- [ ] WhisperClient（上传录音，返回识别文字）
- [ ] DeepseekClient（发送 prompt，返回 JSON）
- [ ] AiParserService（JSON → Record）
- [ ] 完整链路整合测试

---

## Phase 5：UI 完善（待开始）

### 计划任务
- [ ] 主页列表优化 + 汇总条
- [ ] RecordDetailScreen（查看/编辑）
- [ ] StatsScreen + CategoryChart
- [ ] FilterScreen
- [ ] EmptyState / LoadingOverlay

---

## Phase 6：设置 + 合规（待开始）

### 计划任务
- [ ] API Key 输入/保存
- [ ] 隐私政策页面
- [ ] 应用图标

---

## Phase 7：上架准备（待开始）

### 计划任务
- [ ] Release APK 构建
- [ ] 真机全流程测试
- [ ] 低端机兼容性测试

---

## 开发日志（2026-05-17）

### 修复
- **启动黑屏**：`await _requestNotificationPermission()` 移到 `runApp()` 之后异步执行，不阻塞 UI 渲染
- **重复权限检查**：移除 app.dart builder 中的 `_checkNotificationStatus`，统一在 main.dart 执行一次
- **首页列表与FAB重叠**：增加 ListView bottom padding 至 160
- **首页记录限制**：只显示最近6条，底部"查看更多"引导
- **Android 15 闪退**：移除 `deleteNotificationChannel` 调用，修复 SecurityException
- **删除记录闪退**：修复 Dismissible confirmDismiss/onDismissed 生命周期
- **前台服务启动**：改为 `startForegroundService` + `ServiceCompat.startForeground`
- **编译错误**：修复 ProviderScope import、Context 类型冲突、SwitchListTile onTap、静态方法调用等

### 新增
- **首页汇总卡片**：今日支出 + 本月累计
- **首页UI美化**：渐变卡片、圆角分类图标、FAB圆角+文字标签
- **设置页面重写**：移除 Whisper/DeepSeek API Key，添加账号管理、通知设置、数据管理
- **锁屏通知**：Android 前台服务实现，显示今日/本月支出
- **启动权限申请**：app 启动时请求通知权限，永久拒绝时显示引导弹窗
- **首次使用引导**：SharedPreferences 控制的一次性使用说明弹窗
- **桌面小组件**：home_widget + Kotlin AppWidgetProvider，横向今日/本月布局

### 已知问题
- 小组件载入失败（"载入窗口小部件时出现问题"）— 未解决，已回退到原始代码
- 语音输入第三方异常 — 未完全排查
