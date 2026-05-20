# 语音记账 App - 架构文档

## 项目概述

语音记账 App，核心流程：**长按录音 → 阿里云 ASR 转文字 → 智谱 GLM 解析 → 本地存储展示**

- **框架**: Flutter 3.x (Dart 3.11.5)
- **目标平台**: Android (一加 Ace 2, API 35)
- **状态管理**: Riverpod
- **路由**: GoRouter
- **本地存储**: SQLite (sqflite) + SharedPreferences

## 目录结构

```
lib/
├── main.dart                          # 入口，初始化 ProviderScope
├── app.dart                           # MaterialApp + GoRouter 配置
│
├── core/
│   ├── config/
│   │   ├── api_config.dart            # API Key、Base URL、Model 名称
│   │   └── app_theme.dart             # 应用主题配置
│   ├── constants/
│   │   ├── categories.dart            # 记账分类常量（餐饮/交通/购物等）
│   │   └── prompts.dart               # AI 解析 Prompt 模板
│   ├── services/
│   │   ├── voice_service.dart         # 阿里云 ASR 语音转文字
│   │   └── ai_parser.dart             # 智谱 GLM 文本解析为记账记录
│   └── utils/
│       └── date_helper.dart           # 日期格式化
│
├── data/
│   ├── models/
│   │   ├── record.dart                # 记账记录模型
│   │   └── category.dart              # 分类模型
│   ├── repositories/
│   │   └── record_repository.dart     # 数据访问层
│   └── local/
│       ├── database.dart              # SQLite 建表 + CRUD
│       └── prefs_manager.dart         # SharedPreferences 工具
│
├── providers/
│   ├── records_provider.dart          # 记录列表 Notifier + Provider
│   ├── theme_provider.dart            # 主题模式 Provider
│   └── voice_provider.dart            # 录音状态 Notifier + Provider
│
└── features/
    ├── home/
    │   ├── home_screen.dart           # 首页：记录列表 + 语音按钮
    │   └── widgets/
    │       ├── voice_button.dart      # 长按录音按钮
    │       └── recording_overlay.dart # 录音时全屏遮罩
    └── settings/
        └── settings_screen.dart       # 设置页
```

## 核心数据流

```
用户长按麦克风按钮
    │
    ▼ (触发录音)
VoiceButton → Listener.onPointerDown
    │
    ▼
VoiceService.startRecording()  →  record 包录制 .m4a 音频
    │
    ▼ (用户松开)
VoiceService.stopRecording()   →  返回本地文件路径
    │
    ▼
VoiceService.transcribeAudio() →  base64 编码 → 阿里云 DashScope API
    │                              POST /api/v1/services/aigc/multimodal-generation/generation
    │                              Body: {"model": "qwen3-asr-flash", "input": {"messages": [...]}}
    │
    ▼ (返回识别文字)
AiParserService._parseRecord() →  构造 Prompt → 智谱 GLM API
    │                              POST /api/anthropic/v1/messages
    │                              Body: {"model": "glm-4.5-air", "messages": [...]}
    │
    ▼ (返回 JSON: amount, category, note)
RecordRepository.addRecord()   →  写入 SQLite 本地数据库
    │
    ▼
UI 刷新显示新记录
```

## API 配置

| 服务 | 用途 | Base URL | 模型 | 认证 |
|------|------|----------|------|------|
| 阿里云 DashScope | 语音转文字 | `https://dashscope.aliyuncs.com` | `qwen3-asr-flash` | `Authorization: Bearer <key>` |
| 智谱 GLM | 文本解析 | `https://open.bigmodel.cn/api/anthropic` | `glm-4.5-air` | `Authorization: Bearer <key>` |

### API 调用格式（标准模板）

**纯文本 LLM (Anthropic 兼容):**
```
POST {baseUrl}/v1/messages
Header: Authorization: Bearer {apiKey}
Body: {"model": {model}, "max_tokens": 1024, "messages": [{"role": "user", "content": "文本"}]}
响应: data["content"][0]["text"]
```

**音频转文字 (DashScope 原生):**
```
POST {baseUrl}/api/v1/services/aigc/multimodal-generation/generation
Header: Authorization: Bearer {apiKey}
Body: {"model": {model}, "input": {"messages": [{"role": "user", "content": [{"audio": "data:audio/wav;base64,..."}]}]}, "parameters": {}}
响应: data["output"]["choices"][0]["message"]["content"][0]["text"]
```

## 状态管理

### Riverpod Providers

| Provider | 类型 | 作用 |
|----------|------|------|
| `voiceServiceProvider` | `Provider<VoiceService>` | 单例 VoiceService |
| `voiceStateProvider` | `StateNotifierProvider` | 管理录音状态 (idle/recording) |
| `recordsProvider` | `StateNotifierProvider` | 管理记录列表 CRUD |
| `themeModeProvider` | `StateProvider` | 亮色/暗色主题切换 |

## 录音状态

```dart
enum RecordingState { idle, recording }

class VoiceState {
  RecordingState state;
  String? filePath;      // 录音完成后的文件路径
  bool isCancelled;      // 上滑取消标志
}
```

## 数据库表结构 (records)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 自增 ID |
| amount | REAL | 金额 |
| category | TEXT | 分类（餐饮/交通/购物/娱乐/医疗/教育/住房/其他） |
| date | INTEGER | 记录日期（毫秒时间戳） |
| note | TEXT | 备注 |
| voice_text | TEXT | 原始语音识别文字 |
| voice_file | TEXT | 录音文件路径 |
| created_at | INTEGER | 创建时间 |
| updated_at | INTEGER | 更新时间 |

## 依赖说明

| 包 | 版本 | 用途 |
|----|------|------|
| flutter_riverpod | 2.6.1 | 状态管理 |
| go_router | 14.8.0 | 路由 |
| sqflite | 2.4.2 | 本地 SQLite 数据库 |
| shared_preferences | 2.5.2 | 键值对持久化 |
| dio | 5.8.0+1 | HTTP 请求 |
| intl | 0.20.2 | 日期格式化 |
| record | ^6.0.0 | 音频录制 |
| fl_chart | 0.70.2 | 图表（预留） |
| path_provider | 2.1.5 | 获取文件存储路径 |
| path | 1.9.1 | 路径处理 |

## 构建与运行

```bash
flutter pub get
flutter run -d PHK110          # 无线连接一加手机
```

### Gradle 构建配置 (android/build.gradle.kts)

```kotlin
// 仓库源：Google + MavenCentral + 阿里云 Flutter 镜像
google()
mavenCentral()
maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
```

### 无线调试连接

```bash
adb pair 192.168.10.104:<port>   # 配对码输入后连接
flutter devices                    # 确认设备出现
```

注意：一加手机息屏后无线连接会断开，需重新 `adb pair`。
