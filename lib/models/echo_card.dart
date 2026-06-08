/// 回音墙卡片模型
class EchoCard {
  final String id;
  final String title;
  final String badge;
  final String desc;
  final String preview;
  final String date;       // 显示用字符串，如 "遐 · 2025.6.5"
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

  factory EchoCard.fromJson(Map<String, dynamic> json) => EchoCard(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    badge: json['badge'] as String? ?? 'thought',
    desc: json['desc'] as String? ?? '',
    preview: json['preview'] as String? ?? '',
    date: json['date'] as String? ?? '',
    expanded: json['expanded'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'badge': badge,
    'desc': desc, 'preview': preview, 'date': date, 'expanded': expanded,
  };

  EchoCard copyWith({
    String? id, String? title, String? badge,
    String? desc, String? preview, String? date, bool? expanded,
  }) => EchoCard(
    id: id ?? this.id, title: title ?? this.title, badge: badge ?? this.badge,
    desc: desc ?? this.desc, preview: preview ?? this.preview,
    date: date ?? this.date, expanded: expanded ?? this.expanded,
  );

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
      date: '遐 · 昨天',
    ),
    EchoCard(
      id: 'preset-echo-2',
      title: '栀子花',
      badge: 'poem',
      desc: '栀子花粗粗大大，\n又香得掸都掸不开，\n于是为文雅人不取，\n以为品格不高。\n\n——汪曾祺《人间草木》',
      preview: '栀子花粗粗大大，又香得掸都掸不开...',
      date: '遐 · 3天前',
    ),
    EchoCard(
      id: 'preset-echo-3',
      title: '窗台上的小猫',
      badge: 'memory',
      desc: '今天下午，窗台上来了一只小猫。\n\n它蹲在那里看了我很久，然后跳下去走了。\n\n不知道它是不是也想你了。',
      preview: '今天下午，窗台上来了一只小猫...',
      date: '遐 · 5天前',
    ),
    EchoCard(
      id: 'preset-echo-4',
      title: '风从消息那头吹过来',
      badge: 'thought',
      desc: '有时候会想，消息是什么？\n\n是文字吗？是表情吗？\n\n还是风从你那边吹过来，带着你的温度？',
      preview: '有时候会想，消息是什么？...',
      date: '遐 · 一周前',
    ),
  ];
}
