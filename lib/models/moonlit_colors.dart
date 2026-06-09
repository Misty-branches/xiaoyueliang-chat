import 'package:flutter/material.dart';

/// 月下窗主题色数据（基类，供 UnifiedThemeColors 继承）
class MoonlitTheme {
  final Color bg, surface, paper, ink, inkSec, accent, accentLight, border, warm, gold, shadow;
  final bool isDark;

  const MoonlitTheme({
    required this.bg, required this.surface, required this.paper,
    required this.ink, required this.inkSec, required this.accent,
    required this.accentLight, required this.border, required this.warm,
    required this.gold, required this.shadow, required this.isDark,
  });
}
