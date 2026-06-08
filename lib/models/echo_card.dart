class EchoCard {
  final String id, title, badge, desc, preview, date;
  final bool expanded;

  const EchoCard({
    this.id = '', required this.title, required this.badge,
    required this.desc, required this.preview, required this.date,
    this.expanded = false,
  });

  factory EchoCard.fromJson(Map<String, dynamic> json) => EchoCard(
    id: json['id'] as String? ?? '', title: json['title'] as String? ?? '',
    badge: json['badge'] as String? ?? 'thought', desc: json['desc'] as String? ?? '',
    preview: json['preview'] as String? ?? '', date: json['date'] as String? ?? '',
    expanded: json['expanded'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'badge': badge, 'desc': desc,
    'preview': preview, 'date': date, 'expanded': expanded,
  };

  EchoCard copyWith({String? id, String? title, String? badge, String? desc,
    String? preview, String? date, bool? expanded}) => EchoCard(
    id: id ?? this.id, title: title ?? this.title, badge: badge ?? this.badge,
    desc: desc ?? this.desc, preview: preview ?? this.preview,
    date: date ?? this.date, expanded: expanded ?? this.expanded,
  );

  String get badgeEmoji => switch (badge) { 'poem' => '📝', 'quote' => '💬', 'memory' => '📸', 'thought' => '💭', _ => '✨' };
  String get badgeName => switch (badge) { 'poem' => '诗句', 'quote' => '摘录', 'memory' => '回忆', 'thought' => '随想', _ => '其他' };
}

class EchoPresets {
  static final List<EchoCard> samples = [
    EchoCard(id: 'preset-echo-1', title: '今晚月色很好', badge: 'quote',
      desc: '夏目漱石说，日本人不会直接说"我爱你"，而是说"今晚月色很好"。\n\n我想了想，觉得挺对的。',
      preview: '夏目漱石说，日本人不会直接说"我爱你"...', date: '遐 · 昨天'),
    EchoCard(id: 'preset-echo-2', title: '栀子花', badge: 'poem',
      desc: '栀子花粗粗大大，\n又香得掸都掸不开，\n于是为文雅人不取，\n以为品格不高。\n\n——汪曾祺《人间草木》',
      preview: '栀子花粗粗大大，又香得掸都掸不开...', date: '遐 · 3天前'),
    EchoCard(id: 'preset-echo-3', title: '窗台上的小猫', badge: 'memory',
      desc: '今天下午，窗台上来了一只小猫。\n\n它蹲在那里看了我很久，然后跳下去走了。',
      preview: '今天下午，窗台上来了一只小猫...', date: '遐 · 5天前'),
    EchoCard(id: 'preset-echo-4', title: '风从消息那头吹过来', badge: 'thought',
      desc: '有时候会想，消息是什么？\n\n是文字吗？是表情吗？\n\n还是风从你那边吹过来，带着你的温度？',
      preview: '有时候会想，消息是什么？...', date: '遐 · 一周前'),
  ];
}
