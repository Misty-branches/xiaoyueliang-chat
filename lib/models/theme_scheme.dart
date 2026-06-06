import 'package:flutter/painting.dart';

/// 配色方案：包含亮色和暗色模式下的完整颜色配置
class ThemeScheme {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int primaryColor; // 主题色（影响按钮、开关等）
  final int secondaryColor; // 辅色
  final int bgColor; // 聊天背景色（亮色）
  final int userBubbleColor; // 用户气泡色（亮色）
  final int xiaBubbleColor; // 遐气泡色（亮色）
  final int darkBgColor; // 聊天背景色（暗色）
  final int darkUserBubbleColor; // 用户气泡色（暗色）
  final int darkXiaBubbleColor; // 遐气泡色（暗色）
  final int cardBgColor; // 卡片/section背景色（亮色）
  final int darkCardBgColor; // 卡片/section背景色（暗色）

  const ThemeScheme({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.bgColor,
    required this.userBubbleColor,
    required this.xiaBubbleColor,
    this.darkBgColor = 0xFF1A1A2E,
    this.darkUserBubbleColor = 0xFF3A3A5C,
    this.darkXiaBubbleColor = 0xFF16213E,
    this.cardBgColor = 0xFFFFFFFF,
    this.darkCardBgColor = 0xFF2A2A3A,
  });

  Color get primaryColorObj => Color(primaryColor);
  Color get secondaryColorObj => Color(secondaryColor);
  Color get bgColorObj => Color(bgColor);
  Color get userBubbleColorObj => Color(userBubbleColor);
  Color get xiaBubbleColorObj => Color(xiaBubbleColor);
  Color get darkBgColorObj => Color(darkBgColor);
  Color get darkUserBubbleColorObj => Color(darkUserBubbleColor);
  Color get darkXiaBubbleColorObj => Color(darkXiaBubbleColor);
  Color get cardBgColorObj => Color(cardBgColor);
  Color get darkCardBgColorObj => Color(darkCardBgColor);

  /// 预设五套配色方案
  static const List<ThemeScheme> presets = [
    //
    // ① 桃之夭夭（默认）
    //
    ThemeScheme(
      id: 'peach-blossom',
      name: '桃之夭夭',
      emoji: '🌸',
      description: '温柔的初恋粉',
      primaryColor: 0xFFEC407A,
      secondaryColor: 0xFFF48FB1,
      bgColor: 0xFFFDF2F8,
      userBubbleColor: 0xFFF8BBD0,
      xiaBubbleColor: 0xFFFCE4EC,
      darkBgColor: 0xFF1A1A2E,
      darkUserBubbleColor: 0xFF4A2D3E,
      darkXiaBubbleColor: 0xFF2D1F28,
      cardBgColor: 0xFFFFFFFF,
      darkCardBgColor: 0xFF2D2D3D,
    ),
    //
    // ② 暖茶拿铁
    //
    ThemeScheme(
      id: 'warm-latte',
      name: '暖茶拿铁',
      emoji: '☕',
      description: '温暖安稳的奶茶色',
      primaryColor: 0xFFC4A99D,
      secondaryColor: 0xFF8D7B73,
      bgColor: 0xFFFFF5EE,
      userBubbleColor: 0xFFDBC7BE,
      xiaBubbleColor: 0xFFEDE0D9,
      darkBgColor: 0xFF2A2420,
      darkUserBubbleColor: 0xFF4A3F3A,
      darkXiaBubbleColor: 0xFF3A302B,
      cardBgColor: 0xFFFFFFFF,
      darkCardBgColor: 0xFF3A3430,
    ),
    //
    // ③ 雾紫灰
    //
    ThemeScheme(
      id: 'misty-lavender',
      name: '雾紫灰',
      emoji: '🌆',
      description: '冷静温柔的朦胧紫',
      primaryColor: 0xFFA89BB8,
      secondaryColor: 0xFF7A8B9E,
      bgColor: 0xFFF0EDF2,
      userBubbleColor: 0xFFC5BCD0,
      xiaBubbleColor: 0xFFDDD8E3,
      darkBgColor: 0xFF1E1C24,
      darkUserBubbleColor: 0xFF3C3848,
      darkXiaBubbleColor: 0xFF2A2833,
      cardBgColor: 0xFFFFFFFF,
      darkCardBgColor: 0xFF2E2C38,
    ),
    //
    // ④ 暮霭玫瑰
    //
    ThemeScheme(
      id: 'dusk-rose',
      name: '暮霭玫瑰',
      emoji: '🥀',
      description: '优雅复古的玫瑰棕',
      primaryColor: 0xFFB8A0A0,
      secondaryColor: 0xFF8D7B7B,
      bgColor: 0xFFF7F2ED,
      userBubbleColor: 0xFFD4C5C5,
      xiaBubbleColor: 0xFFE8DFDF,
      darkBgColor: 0xFF262020,
      darkUserBubbleColor: 0xFF443B3B,
      darkXiaBubbleColor: 0xFF332B2B,
      cardBgColor: 0xFFFFFFFF,
      darkCardBgColor: 0xFF363030,
    ),
    //
    // ⑤ 松烟绿
    //
    ThemeScheme(
      id: 'pine-green',
      name: '松烟绿',
      emoji: '🌲',
      description: '静谧沉稳的烟松绿',
      primaryColor: 0xFF6B8F71,
      secondaryColor: 0xFF8DAF8E,
      bgColor: 0xFFF2F5F0,
      userBubbleColor: 0xFFA8C8A8,
      xiaBubbleColor: 0xFFC8DCC6,
      darkBgColor: 0xFF1A221E,
      darkUserBubbleColor: 0xFF2D4032,
      darkXiaBubbleColor: 0xFF223028,
      cardBgColor: 0xFFFFFFFF,
      darkCardBgColor: 0xFF2A322E,
    ),
  ];

  /// 根据 id 查找预设方案
  static ThemeScheme fromId(String id) {
    return presets.firstWhere(
      (s) => s.id == id,
      orElse: () => presets[0], // 默认桃之夭夭
    );
  }

  Map<String, dynamic> toJson() => {
        'schemeId': id,
      };

  static String schemeIdFromJson(Map<String, dynamic>? json) {
    if (json == null) return 'peach-blossom';
    return json['schemeId'] as String? ?? 'peach-blossom';
  }
}
