import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 今日心情数据
class MoodData {
  final String emoji;      // 🌙 ☀️ 🌧️ 🌸 📖 😴
  final String text;       // "安静又温柔" "今天心情不错"
  final bool isManual;     // true=手动选的，false=自动推断
  final DateTime updatedAt;

  const MoodData({
    required this.emoji,
    required this.text,
    this.isManual = false,
    required this.updatedAt,
  });

  /// 默认心情（自动推断失败时的兜底）
  factory MoodData.defaultMood() => MoodData(
    emoji: '🌙',
    text: '安静又温柔',
    isManual: false,
    updatedAt: DateTime.now(),
  );

  /// 从JSON反序列化
  factory MoodData.fromJson(Map<String, dynamic> json) => MoodData(
    emoji: json['emoji'] as String? ?? '🌙',
    text: json['text'] as String? ?? '安静又温柔',
    isManual: json['isManual'] as bool? ?? false,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now(),
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'text': text,
    'isManual': isManual,
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// 是否是今天的心情（用于判断是否需要更新）
  bool get isToday {
    final now = DateTime.now();
    return updatedAt.year == now.year &&
           updatedAt.month == now.month &&
           updatedAt.day == now.day;
  }

  /// 复制并修改
  MoodData copyWith({
    String? emoji,
    String? text,
    bool? isManual,
    DateTime? updatedAt,
  }) => MoodData(
    emoji: emoji ?? this.emoji,
    text: text ?? this.text,
    isManual: isManual ?? this.isManual,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// 预设心情选项
class MoodPresets {
  static final List<MoodData> options = [
    MoodData(emoji: '🌙', text: '安静又温柔', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '☀️', text: '今天心情不错', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '🌧️', text: '有点想你', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '🌸', text: '慵懒午后', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '📖', text: '想读会儿书', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '😴', text: '有点累了', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '✨', text: '元气满满', isManual: true, updatedAt: _sentinel),
    MoodData(emoji: '🎵', text: '哼着小曲儿', isManual: true, updatedAt: _sentinel),
  ];

  /// 哨兵值，表示这是预设模板而非真实时间
  static final DateTime _sentinel = DateTime(0);

  /// 根据聊天内容自动推断心情
  static MoodData inferFromChat(List<String> recentMessages) {
    final allText = recentMessages.join(' ').toLowerCase();

    // 开心信号
    if (allText.contains('哈哈') || allText.contains('开心') ||
        allText.contains('😂') || allText.contains('😊')) {
      return MoodData(emoji: '😄', text: '看起来很开心', updatedAt: DateTime.now());
    }

    // 疲惫信号
    if (allText.contains('累') || allText.contains('困') ||
        allText.contains('疲惫') || allText.contains('想睡')) {
      return MoodData(emoji: '😴', text: '有点疲惫', updatedAt: DateTime.now());
    }

    // 读书信号
    if (allText.contains('书') || allText.contains('读') ||
        allText.contains('小说') || allText.contains('故事')) {
      return MoodData(emoji: '📖', text: '在读书呢', updatedAt: DateTime.now());
    }

    // 想念信号
    if (allText.contains('想你') || allText.contains('想念') ||
        allText.contains('思念')) {
      return MoodData(emoji: '🌧️', text: '有点想你', updatedAt: DateTime.now());
    }

    // 默认：按时段推断
    final hour = DateTime.now().hour;
    if (hour < 6) return MoodData(emoji: '🌙', text: '夜深了', updatedAt: DateTime.now());
    if (hour < 11) return MoodData(emoji: '☀️', text: '早安，新的一天', updatedAt: DateTime.now());
    if (hour < 14) return MoodData(emoji: '🌸', text: '午后时光', updatedAt: DateTime.now());
    if (hour < 18) return MoodData(emoji: '🌤️', text: '下午好', updatedAt: DateTime.now());
    return MoodData(emoji: '🌙', text: '晚上好', updatedAt: DateTime.now());
  }
}
