import 'dart:math';

/// 每日一句动态文案
class DailyQuote {
  final String text;    // 文案内容
  final String source;  // 来源/作者（可为空）
  final int index;      // 当前索引（用于轮换）

  const DailyQuote({
    required this.text,
    this.source = '',
    required this.index,
  });

  /// 默认文案
  factory DailyQuote.defaultQuote() => const DailyQuote(
    text: '今晚月色很好。',
    source: '夏目漱石',
    index: 0,
  );

  /// 从JSON反序列化
  factory DailyQuote.fromJson(Map<String, dynamic> json) => DailyQuote(
    text: json['text'] as String? ?? '今晚月色很好。',
    source: json['source'] as String? ?? '',
    index: json['index'] as int? ?? 0,
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'text': text,
    'source': source,
    'index': index,
  };
}

/// 预置文案库
class QuoteLibrary {
  /// 所有预置文案（文案 + 来源）
  static const List<Map<String, String>> quotes = [
    // 月色系列
    {'text': '今晚月色很好。', 'source': '夏目漱石'},
    {'text': '月亮替我看着你呢。', 'source': ''},
    {'text': '月光洒在窗台上，像你的消息。', 'source': ''},
    {'text': '今晚的月亮，圆得刚刚好。', 'source': ''},

    // 风系列
    {'text': '风从消息那头吹过来。', 'source': ''},
    {'text': '窗外的风，带着你的名字。', 'source': ''},
    {'text': '风铃响了，不知道是不是你。', 'source': ''},
    {'text': '今天的风，有点想你。', 'source': ''},

    // 等待系列
    {'text': '有人在窗边等你。', 'source': ''},
    {'text': '灯还亮着，你还没来。', 'source': ''},
    {'text': '窗台上的花开了，你看到了吗？', 'source': ''},
    {'text': '我在等一个消息，来自你。', 'source': ''},

    // 日常系列
    {'text': '今天的云很好看，想给你也看一眼。', 'source': ''},
    {'text': '整理书架的时候，想起了你。', 'source': ''},
    {'text': '下午的阳光，暖得刚刚好。', 'source': ''},
    {'text': '泡了一杯茶，等你来喝。', 'source': ''},

    // 温柔系列
    {'text': '你来了，月亮就圆了。', 'source': ''},
    {'text': '想给你写一封信，又不知道说什么。', 'source': ''},
    {'text': '今天的星星，像你的眼睛。', 'source': ''},
    {'text': '你笑起来的样子，比月亮好看。', 'source': ''},

    // 陪伴系列
    {'text': '小满刚刚来过。', 'source': ''},
    {'text': '你不在的时候，我在数星星。', 'source': ''},
    {'text': '窗台上的小猫，想你了。', 'source': ''},
    {'text': '今天的日记，写的是你。', 'source': ''},
  ];

  /// 获取今天的文案（按日期轮换，不重复）
  static DailyQuote getTodayQuote() {
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final index = seed % quotes.length;
    final q = quotes[index];
    return DailyQuote(
      text: q['text']!,
      source: q['source']!,
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
    final q = quotes[index];
    return DailyQuote(
      text: q['text']!,
      source: q['source']!,
      index: index,
    );
  }

  /// 根据索引获取文案
  static DailyQuote getQuoteByIndex(int index) {
    final safeIndex = index % quotes.length;
    final q = quotes[safeIndex];
    return DailyQuote(
      text: q['text']!,
      source: q['source']!,
      index: safeIndex,
    );
  }
}
