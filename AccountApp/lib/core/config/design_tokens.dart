/// VoiceLedger Design Tokens — Dart constants
/// 直接映射到 Flutter ThemeData，与 design-tokens.json 完全对齐
///
/// 用法：
///   import 'design_tokens.dart';
///   color: AppColors.accent,
///   borderRadius: AppRadius.md,

import 'package:flutter/material.dart';

// ── Colors ──────────────────────────────────────────
class AppColors {
  AppColors._();

  // Surface
  static const bg      = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const fg      = Color(0xFF1A1E2B);
  static const muted   = Color(0xFF5C6378);
  static const border  = Color(0xFFE1E4EB);

  // Brand
  static const accent     = Color(0xFF1EA58B);
  static const accentSoft = Color(0xFF60C9AD);
  static const accentPale = Color(0xFFD9F4EA);

  // Semantic
  static const positive = Color(0xFF1EA57B);
  static const warning  = Color(0xFFE6A817);
  static const danger   = Color(0xFFC93A3A);

  // 8 分类色
  static const catFood      = Color(0xFFD97736);
  static const catTransport = Color(0xFF3B82C4);
  static const catShopping  = Color(0xFF9B4DCA);
  static const catEntertain = Color(0xFFE04A6E);
  static const catMedical   = Color(0xFFD94A3A);
  static const catEducation = Color(0xFF1EA57B);
  static const catHousing   = Color(0xFF8B7355);
  static const catOther     = Color(0xFF6B7280);

  // 8 分类背景色（浅色底）
  static const catBgFood      = Color(0xFFFEF3E8);
  static const catBgTransport = Color(0xFFE8F0FE);
  static const catBgShopping  = Color(0xFFF3E8FD);
  static const catBgEntertain = Color(0xFFFDE8EE);
  static const catBgMedical   = Color(0xFFFDE8E5);
  static const catBgEducation = Color(0xFFE6F7F1);
  static const catBgHousing   = Color(0xFFF3EFE8);
  static const catBgOther     = Color(0xFFF0F1F3);

  /// 根据分类 ID 取前景色
  static Color catColor(String category) => _catColorMap[category] ?? catOther;

  /// 根据分类 ID 取背景色
  static Color catBg(String category) => _catBgMap[category] ?? catBgOther;

  static const _catColorMap = <String, Color>{
    'food': catFood, 'transport': catTransport,
    'shopping': catShopping, 'entertain': catEntertain,
    'medical': catMedical, 'education': catEducation,
    'housing': catHousing, 'other': catOther,
  };
  static const _catBgMap = <String, Color>{
    'food': catBgFood, 'transport': catBgTransport,
    'shopping': catBgShopping, 'entertain': catBgEntertain,
    'medical': catBgMedical, 'education': catBgEducation,
    'housing': catBgHousing, 'other': catBgOther,
  };
}

// ── Radius ──────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const double sm   = 10;
  static const double md   = 16;
  static const double lg   = 22;
  static const double xl   = 30;
  static const double full = 9999;

  static const BorderRadius smAll   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}

// ── Spacing ─────────────────────────────────────────
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

// ── Shadows ─────────────────────────────────────────
class AppShadows {
  AppShadows._();
  static const List<BoxShadow> sm = [
    BoxShadow(blurRadius: 3, spreadRadius: 0, offset: Offset(0, 1), color: Color(0x0F000000)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(blurRadius: 16, spreadRadius: 0, offset: Offset(0, 4), color: Color(0x14000000)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(blurRadius: 32, spreadRadius: 0, offset: Offset(0, 8), color: Color(0x1A000000)),
  ];
}

// ── Typography ──────────────────────────────────────
class AppText {
  AppText._();
  static const String displayFont = 'SF Pro Display, Roboto, system-ui, -apple-system, sans-serif';
  static const String bodyFont    = 'SF Pro Text, Roboto, system-ui, -apple-system, sans-serif';
  static const String monoFont    = 'SF Mono, JetBrains Mono, monospace';

  // Scale
  static const double displayLg = 32;
  static const double displayMd = 24;
  static const double displaySm = 18;
  static const double bodyLg    = 16;
  static const double bodyMd    = 15;
  static const double bodySm    = 14;
  static const double caption   = 13;
  static const double label     = 12;
  static const double amountLg  = 48;
  static const double amountMd  = 28;
}

// ── Animation ───────────────────────────────────────
class AppDuration {
  AppDuration._();
  static const Duration fast   = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow   = Duration(milliseconds: 400);
}

// ── Hit Targets ─────────────────────────────────────
class AppHitTargets {
  AppHitTargets._();
  static const double minTouch    = 44;
  static const double iconButton  = 40;
  static const double bottomNav   = 44;
}

// ── Layout Constants ────────────────────────────────
class AppLayout {
  AppLayout._();
  static const double appBarHeight       = 56;
  static const double appBarHPadding     = 16;
  static const double appBarTopIOS       = 48;
  static const double bottomBarHeight    = 72;
  static const double bottomBarIOSExtra  = 34;
  static const double voiceButtonSize    = 56;
}

// ── Category Enum ──────────────────────────────────
enum CategoryId {
  food, transport, shopping, entertain, medical, education, housing, other;

  String get id => name;

  IconData get icon => switch (this) {
    CategoryId.food      => Icons.restaurant,
    CategoryId.transport => Icons.directions_bus,
    CategoryId.shopping  => Icons.shopping_cart,
    CategoryId.entertain => Icons.movie,
    CategoryId.medical   => Icons.local_hospital,
    CategoryId.education => Icons.menu_book,
    CategoryId.housing   => Icons.home,
    CategoryId.other     => Icons.inventory_2,
  };

  String get label => switch (this) {
    CategoryId.food      => '餐饮',
    CategoryId.transport => '交通',
    CategoryId.shopping  => '购物',
    CategoryId.entertain => '娱乐',
    CategoryId.medical   => '医疗',
    CategoryId.education => '教育',
    CategoryId.housing   => '住房',
    CategoryId.other     => '其他',
  };

  Color get color => AppColors.catColor(id);
  Color get backgroundColor => AppColors.catBg(id);

  static CategoryId fromId(String id) =>
    CategoryId.values.firstWhere((c) => c.id == id, orElse: () => CategoryId.other);

  /// 从中文名映射（用于数据库迁移）
  static CategoryId fromLabel(String label) =>
    CategoryId.values.firstWhere((c) => c.label == label, orElse: () => CategoryId.other);
}
