# 出海语音记账App — 从零到上架完整流程

## 技术栈选型（推荐方案）

| 层级 | 选择 | 说明 |
|---|---|---|
| **框架** | Flutter | Google出品，一套代码同时出Android和iOS，UI一致性好 |
| **语言** | Dart | Google开发，语法类似Java/JS，上手快 |
| **IDE** | VS Code + Flutter插件 | 你已有VS Code，装插件即可 |
| **AI大模型** | DeepSeek API | 低成本，每百万Token约0.2元（缓存命中后） |
| **语音识别(ASR)** | OpenAI Whisper API / Google Speech-to-Text | 把语音转文字 |
| **本地数据库** | SQLite (sqflite插件) | 初期数据存本地，零成本 |
| **状态管理** | Riverpod | Flutter官方推荐，简单易懂 |
| **后端(二期)** | Supabase / Firebase | 免费额度够用，做登录、云端同步 |

---

## 阶段一：环境搭建（第1-2天）

### 1. 安装必要工具
- 安装 Flutter SDK（包含Dart）
- 安装 Android Studio（只需要它提供的Android SDK和模拟器，不用IDE）
- VS Code 安装 Flutter 和 Dart 插件
- 安装 Android 模拟器（AVD）

### 2. 验证环境
```bash
flutter doctor          # 检查所有环境是否就绪
flutter create my_app   # 创建第一个项目
cd my_app
flutter run             # 在模拟器上跑起来
```

### 3. 开发调试流程
- VS Code 写代码，Ctrl+S 保存后**热重载**（Hot Reload），模拟器里几乎瞬间看到变化
- 不需要像传统开发那样重新编译

---

## 阶段二：核心功能开发（第1-2周）

### 功能1：记账核心数据结构
- 定义账本数据模型：金额、分类、日期、备注、语音原文
- 本地数据库建表（SQLite）

### 功能2：微信式语音交互UI
- 底部语音按钮，长按录音、松手发送、上滑取消
- 录音动画（波形/涟漪效果）
- 录音权限处理（Android/iOS）

### 功能3：语音 → 文字 → AI解析 → 记账
流程：
```
用户长按说话 → 录音 → 松开
  ↓
录音文件上传 Whisper API → 得到文字
  ↓
文字发给 DeepSeek API（带prompt）→ 提取：金额、分类、日期、备注
  ↓
存入 SQLite 本地数据库
  ↓
界面自动刷新，显示新记录
```

DeepSeek 的 prompt 示例：
```
你是一个记账助手。用户说了一句话，请从中提取：
- 金额（数字）
- 分类（餐饮/交通/购物/娱乐/医疗/其他）
- 日期（如果没有提到就是今天）
- 备注（简短描述）
以JSON格式返回，不要多余文字。
用户说："今天午饭花了50块钱"
```

### 功能4：账本展示
- 主页显示近期记账记录列表
- 按日期分组
- 显示每日/每月总计
- 支持筛选分类

---

## 阶段三：UI/UX打磨（第3周）

### 界面规范
- 主页极简：顶部日期+金额总览，底部语音按钮
- 菜单/设置藏在次要位置
- 配色干净、专业（参考YNAB等海外应用）
- 支持暗黑模式（Flutter一键支持）

### 交互优化
- 录音时的触觉反馈（震动）
- AI处理中的加载动画（1-2秒延迟期间）
- 解析错误时的重试机制
- 手动编辑解析结果（AI识别不准时可以改）

---

## 阶段四：测试（第4周）

### 测试方式
| 类型 | 工具 | 说明 |
|---|---|---|
| **单元测试** | Flutter内置 `flutter test` | 测试数据解析逻辑 |
| **Widget测试** | Flutter内置 | 测试UI组件 |
| **真机测试** | 你自己的Android手机 + USB连接 | 语音交互必须在真机上测 |
| **iOS测试** | 需要Mac + Xcode | 没有Mac可以先跳过，用云端Mac服务 |

### 测试重点
- 语音按钮的长按/上滑取消是否流畅
- 不同口音、语速下AI识别准确率
- App后台切换后是否正常
- 低端手机上的性能表现

---

## 阶段五：上架准备（第5周）

### Android（Google Play）
1. 注册 Google Play Developer 账号（$25，一次性）
2. 生成签名密钥（keystore）
3. 构建 Release 包：`flutter build appbundle`
4. 准备应用商店素材：截图、描述、图标、隐私政策
5. 提交审核（通常1-3天）

### iOS（App Store）
1. 注册 Apple Developer 账号（$99/年）
2. **必须有Mac电脑**来构建ipa：`flutter build ipa`
3. 通过 Xcode 上传到 App Store Connect
4. 准备素材，提交审核（通常1-2天）

### 合规要点
- 隐私政策（必须写清楚收集什么数据、怎么处理）
- 用户协议
- 语音录音数据是否需要上传云端（要说明）
- GDPR合规（如果面向欧洲用户）

---

## 阶段六：上线后（持续）

### 数据分析
- 接入 Firebase Analytics（免费）：看用户行为、留存
- 接入 Crashlytics（免费）：崩溃监控

### 二期迭代
- 登录系统（Firebase Auth，支持Google/Apple登录）
- 云端数据库同步（Firebase Firestore / Supabase）
- 多设备同步
- 付费订阅（Google Play Billing / Apple In-App Purchase）
- 多语言支持（i18n）

---

## 成本预估（初期）

| 项目 | 费用 |
|---|---|
| Google Play开发者 | $25（一次性） |
| Apple开发者（可选） | $99/年 |
| DeepSeek API | 极低，百万Token约0.2元 |
| Whisper API | 约$0.006/分钟音频 |
| 本地数据库 | $0 |
| **总计（不含iOS）** | **约¥200起** |

---

## 整体时间线（保守估计）

```
Week 1-2: 环境搭建 + 核心功能（语音录入→AI解析→存账本）
Week 3:   UI打磨 + 交互优化
Week 4:   测试 + Bug修复
Week 5:   上架准备 + 提交审核
```

如果全职投入，**4-6周**可以出一个可用的第一版。
