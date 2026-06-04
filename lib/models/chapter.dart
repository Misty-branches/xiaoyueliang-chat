class Chapter {
  final int index;
  final String title;
  final String content;
  final int startPos; // 在全文中的字符起始位置
  final int endPos;   // 在全文中的字符结束位置

  const Chapter({
    required this.index,
    required this.title,
    required this.content,
    required this.startPos,
    required this.endPos,
  });

  String get preview {
    if (content.isEmpty) return '';
    final text = content.replaceAll('\n', ' ').trim();
    return text.length > 100 ? '${text.substring(0, 100)}...' : text;
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'title': title,
        'content': content,
        'startPos': startPos,
        'endPos': endPos,
      };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        index: json['index'] ?? 0,
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        startPos: json['startPos'] ?? 0,
        endPos: json['endPos'] ?? 0,
      );
}
