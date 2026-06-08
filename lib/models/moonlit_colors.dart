import 'package:flutter/material.dart';

class MoonlitColors {
  MoonlitColors._();

  // 日间
  static const lightBg = Color(0xFFE4E0DA);
  static const lightSurface = Color(0xFFECE9E3);
  static const lightPaper = Color(0xFFF2EFEA);
  static const lightInk = Color(0xFF2C3745);
  static const lightInkSec = Color(0xFF7A8490);
  static const lightAccent = Color(0xFF5A7A94);
  static const lightAccentLight = Color(0xFFE6E9EC);
  static const lightBorder = Color(0xFFD8D2CA);
  static const lightWarm = Color(0xFFC8B8A0);
  static const lightGold = Color(0xFFD4B86A);
  static const lightShadow = Color(0x0F2C3745);

  // 夜间
  static const darkBg = Color(0xFF162B42);
  static const darkSurface = Color(0xFF1E3550);
  static const darkPaper = Color(0xFF26405A);
  static const darkInk = Color(0xFFF0F4F8);
  static const darkInkSec = Color(0xFFA0B8CC);
  static const darkAccent = Color(0xFF7BA8D0);
  static const darkAccentLight = Color(0xFF1E3550);
  static const darkBorder = Color(0xFF2E4A68);
  static const darkWarm = Color(0xFFF0D8A8);
  static const darkGold = Color(0xFFF5D88A);
  static const darkShadow = Color(0x332C3745);

  static MoonlitTheme forMode(bool isDark) => isDark ? _dark : _light;

  static const _light = MoonlitTheme(
    bg: lightBg, surface: lightSurface, paper: lightPaper,
    ink: lightInk, inkSec: lightInkSec, accent: lightAccent,
    accentLight: lightAccentLight, border: lightBorder,
    warm: lightWarm, gold: lightGold, shadow: lightShadow, isDark: false,
  );

  static const _dark = MoonlitTheme(
    bg: darkBg, surface: darkSurface, paper: darkPaper,
    ink: darkInk, inkSec: darkInkSec, accent: darkAccent,
    accentLight: darkAccentLight, border: darkBorder,
    warm: darkWarm, gold: darkGold, shadow: darkShadow, isDark: true,
  );
}

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
