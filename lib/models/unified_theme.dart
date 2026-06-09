import 'package:flutter/material.dart';
import 'moonlit_colors.dart';
export 'moonlit_colors.dart';

/// 月下窗唯一配色方案
class UnifiedTheme {
  final String id, name, emoji, description;
  final Color lightBg, lightSurface, lightPaper, lightInk, lightInkSec, lightAccent, lightAccentLight, lightBorder, lightWarm, lightGold, lightShadow;
  final Color darkBg, darkSurface, darkPaper, darkInk, darkInkSec, darkAccent, darkAccentLight, darkBorder, darkWarm, darkGold, darkShadow;
  final Color lightUserBubble, lightXiaBubble, darkUserBubble, darkXiaBubble;

  const UnifiedTheme({
    required this.id, required this.name, required this.emoji, required this.description,
    required this.lightBg, required this.lightSurface, required this.lightPaper,
    required this.lightInk, required this.lightInkSec, required this.lightAccent,
    required this.lightAccentLight, required this.lightBorder, required this.lightWarm,
    required this.lightGold, required this.lightShadow,
    required this.darkBg, required this.darkSurface, required this.darkPaper,
    required this.darkInk, required this.darkInkSec, required this.darkAccent,
    required this.darkAccentLight, required this.darkBorder, required this.darkWarm,
    required this.darkGold, required this.darkShadow,
    required this.lightUserBubble, required this.lightXiaBubble,
    required this.darkUserBubble, required this.darkXiaBubble,
  });

  UnifiedThemeColors forMode(bool isDark) => isDark
      ? UnifiedThemeColors(
          bg: darkBg, surface: darkSurface, paper: darkPaper,
          ink: darkInk, inkSec: darkInkSec, accent: darkAccent,
          accentLight: darkAccentLight, border: darkBorder,
          warm: darkWarm, gold: darkGold, shadow: darkShadow,
          userBubble: darkUserBubble, xiaBubble: darkXiaBubble, isDark: true,
        )
      : UnifiedThemeColors(
          bg: lightBg, surface: lightSurface, paper: lightPaper,
          ink: lightInk, inkSec: lightInkSec, accent: lightAccent,
          accentLight: lightAccentLight, border: lightBorder,
          warm: lightWarm, gold: lightGold, shadow: lightShadow,
          userBubble: lightUserBubble, xiaBubble: lightXiaBubble, isDark: false,
        );

  /// 月下窗 — 唯一配色
  static const moonlit = UnifiedTheme(
    id: 'moonlit', name: '月下窗', emoji: '🌙', description: '灰米日间 / 亮蓝夜间',
    lightBg: Color(0xFFE4E0DA), lightSurface: Color(0xFFECE9E3), lightPaper: Color(0xFFF2EFEA),
    lightInk: Color(0xFF2C3745), lightInkSec: Color(0xFF7A8490), lightAccent: Color(0xFF5A7A94),
    lightAccentLight: Color(0xFFE6E9EC), lightBorder: Color(0xFFD8D2CA), lightWarm: Color(0xFFC8B8A0),
    lightGold: Color(0xFFD4B86A), lightShadow: Color(0x0F2C3745),
    darkBg: Color(0xFF162B42), darkSurface: Color(0xFF1E3550), darkPaper: Color(0xFF26405A),
    darkInk: Color(0xFFF0F4F8), darkInkSec: Color(0xFFA0B8CC), darkAccent: Color(0xFF7BA8D0),
    darkAccentLight: Color(0xFF1E3550), darkBorder: Color(0xFF2E4A68), darkWarm: Color(0xFFF0D8A8),
    darkGold: Color(0xFFF5D88A), darkShadow: Color(0x332C3745),
    lightUserBubble: Color(0xFFD8E2EC), lightXiaBubble: Color(0xFFECE9E3),
    darkUserBubble: Color(0xFF2E4A68), darkXiaBubble: Color(0xFF1E3550),
  );

  static const UnifiedTheme defaultTheme = moonlit;

  static UnifiedTheme fromId(String id) => moonlit;
}

class UnifiedThemeColors extends MoonlitTheme {
  final Color userBubble, xiaBubble;

  const UnifiedThemeColors({
    required super.bg, required super.surface, required super.paper,
    required super.ink, required super.inkSec, required super.accent,
    required super.accentLight, required super.border, required super.warm,
    required super.gold, required super.shadow, required super.isDark,
    required this.userBubble, required this.xiaBubble,
  });
}
