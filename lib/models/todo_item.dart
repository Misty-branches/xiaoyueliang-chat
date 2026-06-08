/// 待办事项模型
class TodoItem {
  final String id;         // 唯一标识
  final String title;
  final String desc;
  final String tag;        // 标签：reading, writing, errand, creative
  final bool done;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.tag,
    this.done = false,
    required this.createdAt,
  });

  /// 从JSON反序列化
  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    desc: json['desc'] as String? ?? '',
    tag: json['tag'] as String? ?? 'errand',
    done: json['done'] as bool? ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );

  /// 序列化为JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'desc': desc,
    'tag': tag,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  /// 复制并修改
  TodoItem copyWith({
    String? id,
    String? title,
    String? desc,
    String? tag,
    bool? done,
    DateTime? createdAt,
  }) => TodoItem(
    id: id ?? this.id,
    title: title ?? this.title,
    desc: desc ?? this.desc,
    tag: tag ?? this.tag,
    done: done ?? this.done,
    createdAt: createdAt ?? this.createdAt,
  );

  /// 标签对应的emoji
  String get tagEmoji {
    switch (tag) {
      case 'reading': return '📖';
      case 'writing': return '✏️';
      case 'errand': return '📝';
      case 'creative': return '🎨';
      case 'selfcare': return '🌿';
      default: return '📌';
    }
  }

  /// 标签对应的中文名
  String get tagName {
    switch (tag) {
      case 'reading': return '读书';
      case 'writing': return '写作';
      case 'errand': return '待办';
      case 'creative': return '创作';
      case 'selfcare': return '自洽';
      default: return '其他';
    }
  }
}

/// 预置待办库
class TodoPresets {
  static final List<TodoItem> samples = [
    TodoItem(
      id: 'preset-todo-1',
      title: '读完《人间草木》第三章',
      desc: '汪曾祺写栀子花那段，想和你一起读。',
      tag: 'reading',
      done: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TodoItem(
      id: 'preset-todo-2',
      title: '整理书架',
      desc: '把新到的书放好，给汪曾祺留个好位置。',
      tag: 'errand',
      done: false,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TodoItem(
      id: 'preset-todo-3',
      title: '写一封信',
      desc: '想给你写一封信，不知道说什么好。',
      tag: 'writing',
      done: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TodoItem(
      id: 'preset-todo-4',
      title: '给窗台上的花浇水',
      desc: '白色的花瓣，需要照顾一下。',
      tag: 'selfcare',
      done: true,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
}
