/// 回音墙卡片模型
class EchoCard {
  final String title;
  final String badge;
  final String desc;
  final String preview;
  final String date;
  final bool expanded;

  const EchoCard({
    required this.title,
    required this.badge,
    required this.desc,
    required this.preview,
    required this.date,
    this.expanded = false,
  });

  EchoCard copyWith({bool? expanded}) {
    return EchoCard(
      title: title,
      badge: badge,
      desc: desc,
      preview: preview,
      date: date,
      expanded: expanded ?? this.expanded,
    );
  }
}
