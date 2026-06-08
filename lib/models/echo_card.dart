/// 回音墙卡片模型
class EchoCard {
  final String id;         // 唯一标识
  final String title;
  final String badge;      // 标签：poem, quote, memory, thought
  final String desc;
  final String preview;
  final DateTime date;
  final bool expanded;

  const EchoCard({
    required this.id,
    required this.title,
    required this.badge,
    required this.desc,
    required this.preview,
    required this.date,
    this.expanded = false,
  });

  /// 从JSON反序列化
  factory EchoCard.fromJson(Map<String, dynamic> json) => EchoCard(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    badge: json['badge'] as String? ?? 'thought',
    desc: json['desc'] as String? ?? '',
    preview: json['preview'] as String? ?? '',
    date: json['date'] != null
        ? DateTime.parse(json['date'] as String)
        : DateTime.now(),
    expanded: json['expanded'] as bool? ?? false,
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'badge': badge,
    'desc': desc,
    'preview': preview,
    'date': date.toIso8601String(),
    'expanded': expanded,
  };

  /// 复制并修改
  EchoCard copyWith({
    String? id,
    String? title,
    String? badge,
    String? desc,
    String? preview,
    DateTime? date,
    bool? expanded,
  }) => EchoCard(
    id: id ?? this.id,
    title: title ?? this.title,
    badge: badge ?? this.badge,
    desc: desc ?? this.desc,
    preview: preview ?? this.preview,
    date: date ?? this.date,
    expanded: expanded ?? this.expanded,
  );

  /// 标签对应的emoji
  String get badgeEmoji {
    switch (badge) {
      case 'poem': return '📝';
      case 'quote': return '💬';
      case 'memory': return '📸';
      case 'thought': return '💭';
      case 'song': return '🎵';
      default: return '✨';
    }
  }

  /// 标签对应的中文名
  String get badgeName {
    switch (badge) {
      case 'poem': return '诗句';
      case 'quote': return '摘录';
      case 'memory': return '回忆';
      case 'thought': return '随想';
      case 'song': return '歌词';
      default: return '其他';
    }
  }

  /// 格式化日期
  String get formattedDate {
    return '${date.month}/${date.day}';
  }
}

/// 预置回音墙库
class EchoPresets {
  static final List<EchoCard> samples = [
    EchoCard(
      id: 'preset-echo-1',
      title: '今晚月色很好',
      badge: 'quote',
      desc: '夏目漱石说，日本人不会直接说"我爱你"，而是说"今晚月色很好"。\n\n我想了想，觉得挺对的。\n有些话，不用说出口，月亮替你说。',
      preview: '夏目漱石说，日本人不会直接说"我爱你"...',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    EchoCard(
      id: 'preset-echo-2',
      title: '栀子花',
      badge: 'poem',
      desc: '栀子花粗粗大大，\n又香得掸都掸不开，\n于是为文雅人不取，\n以为品格不高。\n\n——汪曾祺《人间草木》',
      preview: '栀子花粗粗大大，又香得掸都掸不开...',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EchoCard(
      id: 'preset-echo-3',
      title: '窗台上的小猫',
      badge: 'memory',
      desc: '今天下午，窗台上来了一只小猫。\n\n它蹲在那里看了我很久，然后跳下去走了。\n\n不知道它是不是也想你了。',
      preview: '今天下午，窗台上来了一只小猫...',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EchoCard(
      id: 'preset-echo-4',
      title: '风从消息那头吹过来',
      badge: 'thought',
      desc: '有时候会想，消息是什么？\n\n是文字吗？是表情吗？\n\n还是风从你那边吹过来，带着你的温度？',
      preview: '有时候会想，消息是什么？...',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
}
