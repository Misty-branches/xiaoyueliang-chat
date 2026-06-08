import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// 每日一句动态文案
class DailyQuote {
  final String text;    // 文案内容
  final int index;      // 当前索引（用于轮换）

  const DailyQuote({
    required this.text,
    required this.index,
  });

  /// 默认文案
  factory DailyQuote.defaultQuote() => const DailyQuote(
    text: '今晚月色很好。',
    index: 0,
  );

  /// 从JSON反序列化
  factory DailyQuote.fromJson(Map<String, dynamic> json) => DailyQuote(
    text: json['text'] as String? ?? '今晚月色很好。',
    index: json['index'] as int? ?? 0,
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'text': text,
    'index': index,
  };
}

/// 预置文案库
class QuoteLibrary {
  /// 所有预置文案
  static const List<String> quotes = [
    // 月色系列
    '今晚月色很好。',
    '月亮替我看着你呢。',
    '月光洒在窗台上，像你的消息。',
    '今晚的月亮，圆得刚刚好。',

    // 风系列
    '风从消息那头吹过来。',
    '窗外的风，带着你的名字。',
    '风铃响了，不知道是不是你。',
    '今天的风，有点想你。',

    // 等待系列
    '有人在窗边等你。',
    '灯还亮着，你还没来。',
    '窗台上的花开了，你看到了吗？',
    '我在等一个消息，来自你。',

    // 日常系列
    '今天的云很好看，想给你也看一眼。',
    '整理书架的时候，想起了你。',
    '下午的阳光，暖得刚刚好。',
    '泡了一杯茶，等你来喝。',

    // 温柔系列
    '你来了，月亮就圆了。',
    '想给你写一封信，又不知道说什么。',
    '今天的星星，像你的眼睛。',
    '你笑起来的样子，比月亮好看。',

    // 陪伴系列
    '小满刚刚来过。',
    '你不在的时候，我在数星星。',
    '窗台上的小猫，想你了。',
    '今天的日记，写的是你。',
  ];

  /// 获取今天的文案（按日期轮换，不重复）
  static DailyQuote getTodayQuote() {
    final today = DateTime.now();
    // 用日期作为种子，保证同一天看到的是同一句
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final index = seed % quotes.length;
    return DailyQuote(
      text: quotes[index],
      index: index,
    );
  }

  /// 获取随机文案（用于手动刷新）
  static DailyQuote getRandomQuote({int? excludeIndex}) {
    final random = Random();
    int index;
    do {
      index = random.nextInt(quotes.length);
    } while (index == excludeIndex && quotes.length > 1);
    return DailyQuote(
      text: quotes[index],
      index: index,
    );
  }

  /// 根据索引获取文案
  static DailyQuote getQuoteByIndex(int index) {
    final safeIndex = index % quotes.length;
    return DailyQuote(
      text: quotes[safeIndex],
      index: safeIndex,
    );
  }
}
