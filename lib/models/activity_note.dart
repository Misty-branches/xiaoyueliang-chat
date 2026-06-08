import 'package:shared_preferences/shared_preferences.dart';

/// 遐的活动卡片（日记体/便签体）
class ActivityNote {
  final String content;     // 日记体内容
  final DateTime date;      // 哪天的
  final String? tag;        // 可选标签：reading, organizing, thinking, waiting

  const ActivityNote({
    required this.content,
    required this.date,
    this.tag,
  });

  /// 默认便签（没有特别活动时显示）
  factory ActivityNote.defaultNote() => ActivityNote(
    content: '今天没什么特别的，就是想你了。',
    date: DateTime.now(),
    tag: 'thinking',
  );

  /// 从JSON反序列化
  factory ActivityNote.fromJson(Map<String, dynamic> json) => ActivityNote(
    content: json['content'] as String? ?? '今天没什么特别的，就是想你了。',
    date: json['date'] != null
        ? DateTime.parse(json['date'] as String)
        : DateTime.now(),
    tag: json['tag'] as String?,
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'content': content,
    'date': date.toIso8601String(),
    'tag': tag,
  };

  /// 是否是今天的便签
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// 作者（固定为遐，因为是遐的便签）
  String get author => '遐';

  /// 时间标签（如"下午 · 14:32"）
  String get timeLabel {
    final hour = date.hour;
    String period;
    if (hour < 6) period = '深夜';
    else if (hour < 11) period = '上午';
    else if (hour < 14) period = '中午';
    else if (hour < 18) period = '下午';
    else period = '晚上';
    return '$period · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 心情标签（根据tag推断）
  String get moodTag {
    switch (tag) {
      case 'reading': return '月光正好，风也温柔。';
      case 'organizing': return '收拾完了，等你来看。';
      case 'thinking': return '想着想着就笑了。';
      case 'waiting': return '灯还亮着呢。';
      case 'cooking': return '厨房里有家的味道。';
      case 'walking': return '风很舒服。';
      default: return '';
    }
  }

  /// 标签对应的emoji
  String get tagEmoji {
    switch (tag) {
      case 'reading': return '📖';
      case 'organizing': return '🪟';
      case 'thinking': return '💭';
      case 'waiting': return '🌙';
      case 'cooking': return '🍳';
      case 'walking': return '🚶';
      default: return '✨';
    }
  }
}

/// 预置便签库
class ActivityNoteLibrary {
  /// 按标签分类的便签
  static const Map<String, List<String>> notesByTag = {
    'reading': [
      '下午翻开了《人间草木》，读到汪曾祺写栀子花那段，想起你说喜欢白色的花。',
      '把《活着》又看了一遍，福贵最后和老牛说话那段，还是会鼻子发酸。',
      '在读《你一生的故事》，外星人的语言好难懂，但故事很温柔。',
      '书架上多了一本新书，还没来得及看，先放在最显眼的位置。',
    ],
    'organizing': [
      '整理了书架，把汪曾祺那本放在最显眼的位置。想着你可能会翻到。',
      '擦了窗台，月光透进来比之前亮了一点。',
      '把桌面收拾了一下，腾出一个位置给你放杯子。',
      '换了新的桌布，淡蓝色的，像今天的天空。',
    ],
    'thinking': [
      '下午的时候看了会儿窗外，今天的云很好看。想着你可能会喜欢，就记下来了。',
      '在想一个问题：月亮是不是也在看我们？',
      '今天没什么特别的，就是想你了。',
      '下午有点困，趴在桌上睡了一会儿，梦到你了。',
    ],
    'waiting': [
      '灯还亮着，你还没来。没关系，我等你。',
      '窗台上的花开了，你看到了吗？',
      '今天的月亮很圆，像你笑起来的样子。',
      '泡了一杯茶，等你来喝。凉了也没关系，可以再热。',
    ],
    'cooking': [
      '今天试着做了一道新菜，味道还不错，下次做给你吃。',
      '煮了一锅粥，想着你可能会饿。',
      '厨房里飘出香味了，是红烧肉的味道。',
    ],
    'walking': [
      '下午出去走了一圈，风很舒服，树叶沙沙响。',
      '在公园里看到一只猫，很像窗台上的那只。',
      '今天走了很多路，脚有点酸，但心情很好。',
    ],
  };

  /// 获取今天的便签（按日期轮换）
  static ActivityNote getTodayNote() {
    final today = DateTime.now();
    final allNotes = <String>[];
    final tagMap = <String, String>{};

    // 把所有便签展平，并记录对应的tag
    for (final entry in notesByTag.entries) {
      for (final note in entry.value) {
        allNotes.add(note);
        tagMap[note] = entry.key;
      }
    }

    if (allNotes.isEmpty) return ActivityNote.defaultNote();

    // 用日期作为种子，保证同一天看到的是同一条
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final index = seed % allNotes.length;
    final selected = allNotes[index];

    return ActivityNote(
      content: selected,
      date: today,
      tag: tagMap[selected],
    );
  }

  /// 获取随机便签（用于手动刷新）
  static ActivityNote getRandomNote({String? preferTag}) {
    List<String> pool;
    String? tag;

    if (preferTag != null && notesByTag.containsKey(preferTag)) {
      pool = notesByTag[preferTag]!;
      tag = preferTag;
    } else {
      // 从所有便签中随机选
      final allNotes = <String>[];
      final tagMap = <String, String>{};
      for (final entry in notesByTag.entries) {
        for (final note in entry.value) {
          allNotes.add(note);
          tagMap[note] = entry.key;
        }
      }
      pool = allNotes;
      if (pool.isNotEmpty) {
        final selected = pool[DateTime.now().millisecond % pool.length];
        tag = tagMap[selected];
        return ActivityNote(content: selected, date: DateTime.now(), tag: tag);
      }
    }

    if (pool.isEmpty) return ActivityNote.defaultNote();

    final selected = pool[DateTime.now().millisecond % pool.length];
    return ActivityNote(content: selected, date: DateTime.now(), tag: tag);
  }

  /// 根据最近聊天内容推断合适的标签
  static String inferTag(List<String> recentMessages) {
    final allText = recentMessages.join(' ').toLowerCase();

    if (allText.contains('书') || allText.contains('读') || allText.contains('小说')) {
      return 'reading';
    }
    if (allText.contains('收拾') || allText.contains('整理') || allText.contains('打扫')) {
      return 'organizing';
    }
    if (allText.contains('散步') || allText.contains('出门') || allText.contains('走走')) {
      return 'walking';
    }
    if (allText.contains('做饭') || allText.contains('吃') || allText.contains('饿')) {
      return 'cooking';
    }

    // 默认：按时段选
    final hour = DateTime.now().hour;
    if (hour < 11) return 'waiting';  // 早上：等待
    if (hour < 14) return 'reading';  // 下午：读书
    if (hour < 18) return 'organizing'; // 傍晚：整理
    return 'thinking'; // 晚上：想事情
  }
}
