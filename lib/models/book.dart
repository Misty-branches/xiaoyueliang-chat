import 'chapter.dart';

class Book {
  final String id;
  String title;
  String content;
  List<Chapter> chapters;
  String? filePath;
  final DateTime createdAt;

  Book({
    required this.id,
    this.title = '未命名书籍',
    this.content = '',
    List<Chapter>? chapters,
    this.filePath,
    DateTime? createdAt,
  })  : chapters = chapters ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// 总章节数
  int get chapterCount => chapters.length;

  /// 是否有章节结构
  bool get hasChapters => chapters.length > 1;

  /// 获取指定章节
  Chapter? getChapter(int index) {
    if (index < 1 || index > chapters.length) return null;
    return chapters[index - 1];
  }

  /// 获取章节标题，如 "第3章：迷雾"
  String getChapterTitle(int index) {
    final ch = getChapter(index);
    return ch?.title ?? '第$index部分';
  }

  String get preview {
    if (content.isEmpty) return '（空）';
    final text = content.replaceAll('\n', ' ');
    return text.length > 80 ? '${text.substring(0, 80)}...' : text;
  }

  /// 简短的书籍信息
  String get info {
    final charCount = content.replaceAll(RegExp(r'\s+'), '').length;
    final chInfo = hasChapters ? ' · ${chapters.length}章' : '';
    return '$charCount字$chInfo';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'chapters': chapters.map((c) => c.toJson()).toList(),
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] ?? '',
        title: json['title'] ?? '未命名书籍',
        content: json['content'] ?? '',
        chapters: (json['chapters'] as List<dynamic>?)
                ?.map((c) => Chapter.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        filePath: json['filePath'],
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );
}
