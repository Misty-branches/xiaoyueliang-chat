import 'package:flutter/material.dart';
export 'moonlit_colors.dart';

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

  static const peachBlossom = UnifiedTheme(
    id: 'peach-blossom', name: '桃之夭夭', emoji: '🌸', description: '温柔的初恋粉',
    lightBg: Color(0xFFFDF2F8), lightSurface: Color(0xFFFCE4EC), lightPaper: Color(0xFFFFFFFF),
    lightInk: Color(0xFF4A2D3E), lightInkSec: Color(0xFF8D6B7B), lightAccent: Color(0xFFEC407A),
    lightAccentLight: Color(0xFFF8BBD0), lightBorder: Color(0xFFF48FB1), lightWarm: Color(0xFFF8BBD0),
    lightGold: Color(0xFFEC407A), lightShadow: Color(0x0FEC407A),
    darkBg: Color(0xFF1A1A2E), darkSurface: Color(0xFF2D1F28), darkPaper: Color(0xFF2D2D3D),
    darkInk: Color(0xFFF0E6EA), darkInkSec: Color(0xFFB8A0AA), darkAccent: Color(0xFFF48FB1),
    darkAccentLight: Color(0xFF4A2D3E), darkBorder: Color(0xFF4A2D3E), darkWarm: Color(0xFFF8BBD0),
    darkGold: Color(0xFFF48FB1), darkShadow: Color(0x33EC407A),
    lightUserBubble: Color(0xFFF8BBD0), lightXiaBubble: Color(0xFFFCE4EC),
    darkUserBubble: Color(0xFF4A2D3E), darkXiaBubble: Color(0xFF2D1F28),
  );

  static const warmLatte = UnifiedTheme(
    id: 'warm-latte', name: '暖茶拿铁', emoji: '☕', description: '温暖安稳的奶茶色',
    lightBg: Color(0xFFFFF5EE), lightSurface: Color(0xFFEDE0D9), lightPaper: Color(0xFFFFFFFF),
    lightInk: Color(0xFF4A3F3A), lightInkSec: Color(0xFF8D7B73), lightAccent: Color(0xFFC4A99D),
    lightAccentLight: Color(0xFFDBC7BE), lightBorder: Color(0xFFDBC7BE), lightWarm: Color(0xFFDBC7BE),
    lightGold: Color(0xFFC4A99D), lightShadow: Color(0x0FC4A99D),
    darkBg: Color(0xFF2A2420), darkSurface: Color(0xFF3A302B), darkPaper: Color(0xFF3A3430),
    darkInk: Color(0xFFF0E6EA), darkInkSec: Color(0xFFB8A0AA), darkAccent: Color(0xFFC4A99D),
    darkAccentLight: Color(0xFF4A3F3A), darkBorder: Color(0xFF4A3F3A), darkWarm: Color(0xFFDBC7BE),
    darkGold: Color(0xFFC4A99D), darkShadow: Color(0x33C4A99D),
    lightUserBubble: Color(0xFFDBC7BE), lightXiaBubble: Color(0xFFEDE0D9),
    darkUserBubble: Color(0xFF4A3F3A), darkXiaBubble: Color(0xFF3A302B),
  );

  static const mistyLavender = UnifiedTheme(
    id: 'misty-lavender', name: '雾紫灰', emoji: '🌆', description: '冷静温柔的朦胧紫',
    lightBg: Color(0xFFF0EDF2), lightSurface: Color(0xFFDDD8E3), lightPaper: Color(0xFFFFFFFF),
    lightInk: Color(0xFF3C3848), lightInkSec: Color(0xFF7A8B9E), lightAccent: Color(0xFFA89BB8),
    lightAccentLight: Color(0xFFC5BCD0), lightBorder: Color(0xFFC5BCD0), lightWarm: Color(0xFFC5BCD0),
    lightGold: Color(0xFFA89BB8), lightShadow: Color(0x0FA89BB8),
    darkBg: Color(0xFF1E1C24), darkSurface: Color(0xFF2A2833), darkPaper: Color(0xFF2E2C38),
    darkInk: Color(0xFFF0E6EA), darkInkSec: Color(0xFFB8A0AA), darkAccent: Color(0xFFA89BB8),
    darkAccentLight: Color(0xFF3C3848), darkBorder: Color(0xFF3C3848), darkWarm: Color(0xFFC5BCD0),
    darkGold: Color(0xFFA89BB8), darkShadow: Color(0x33A89BB8),
    lightUserBubble: Color(0xFFC5BCD0), lightXiaBubble: Color(0xFFDDD8E3),
    darkUserBubble: Color(0xFF3C3848), darkXiaBubble: Color(0xFF2A2833),
  );

  static const duskRose = UnifiedTheme(
    id: 'dusk-rose', name: '暮霭玫瑰', emoji: '🥀', description: '优雅复古的玫瑰棕',
    lightBg: Color(0xFFF7F2ED), lightSurface: Color(0xFFE8DFDF), lightPaper: Color(0xFFFFFFFF),
    lightInk: Color(0xFF443B3B), lightInkSec: Color(0xFF8D7B7B), lightAccent: Color(0xFFB8A0A0),
    lightAccentLight: Color(0xFFD4C5C5), lightBorder: Color(0xFFD4C5C5), lightWarm: Color(0xFFD4C5C5),
    lightGold: Color(0xFFB8A0A0), lightShadow: Color(0x0FB8A0A0),
    darkBg: Color(0xFF262020), darkSurface: Color(0xFF332B2B), darkPaper: Color(0xFF363030),
    darkInk: Color(0xFFF0E6EA), darkInkSec: Color(0xFFB8A0AA), darkAccent: Color(0xFFB8A0A0),
    darkAccentLight: Color(0xFF443B3B), darkBorder: Color(0xFF443B3B), darkWarm: Color(0xFFD4C5C5),
    darkGold: Color(0xFFB8A0A0), darkShadow: Color(0x33B8A0A0),
    lightUserBubble: Color(0xFFD4C5C5), lightXiaBubble: Color(0xFFE8DFDF),
    darkUserBubble: Color(0xFF443B3B), darkXiaBubble: Color(0xFF332B2B),
  );

  static const pineGreen = UnifiedTheme(
    id: 'pine-green', name: '松烟绿', emoji: '🌲', description: '静谧沉稳的烟松绿',
    lightBg: Color(0xFFF2F5F0), lightSurface: Color(0xFFC8DCC6), lightPaper: Color(0xFFFFFFFF),
    lightInk: Color(0xFF223028), lightInkSec: Color(0xFF6B8F71), lightAccent: Color(0xFF6B8F71),
    lightAccentLight: Color(0xFFA8C8A8), lightBorder: Color(0xFFA8C8A8), lightWarm: Color(0xFFA8C8A8),
    lightGold: Color(0xFF6B8F71), lightShadow: Color(0x0F6B8F71),
    darkBg: Color(0xFF1A221E), darkSurface: Color(0xFF223028), darkPaper: Color(0xFF2A322E),
    darkInk: Color(0xFFF0E6EA), darkInkSec: Color(0xFFB8A0AA), darkAccent: Color(0xFF6B8F71),
    darkAccentLight: Color(0xFF2D4032), darkBorder: Color(0xFF2D4032), darkWarm: Color(0xFFA8C8A8),
    darkGold: Color(0xFF6B8F71), darkShadow: Color(0x336B8F71),
    lightUserBubble: Color(0xFFA8C8A8), lightXiaBubble: Color(0xFFC8DCC6),
    darkUserBubble: Color(0xFF2D4032), darkXiaBubble: Color(0xFF223028),
  );

  static const List<UnifiedTheme> presets = [moonlit, peachBlossom, warmLatte, mistyLavender, duskRose, pineGreen];

  static UnifiedTheme fromId(String id) => presets.firstWhere((t) => t.id == id, orElse: () => moonlit);
}

class UnifiedThemeColors extends MoonlitTheme {
  final Color userBubble, xiaBubble;

  const UnifiedThemeColors({
    required super.bg, required super.surface, required super.paper,
    required super.ink, required super.inkSec, required super.accent,
    required super.accentLight, required super.border, required super.warm,
    required super.gold, required super.shadow, required super.isDark,
    required this.userBubble, required this.xiaBubble,
  }) : super();
}
