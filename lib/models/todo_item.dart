
class TodoItem {
  final String id, title, desc, tag;
  final bool done;
  final DateTime createdAt;

  TodoItem({
    this.id = '', required this.title, required this.desc,
    required this.tag, this.done = false, DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'] as String? ?? '', title: json['title'] as String? ?? '',
    desc: json['desc'] as String? ?? '', tag: json['tag'] as String? ?? 'errand',
    done: json['done'] as bool? ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'desc': desc, 'tag': tag,
    'done': done, 'createdAt': createdAt.toIso8601String(),
  };

  TodoItem copyWith({String? id, String? title, String? desc, String? tag, bool? done, DateTime? createdAt}) => TodoItem(
    id: id ?? this.id, title: title ?? this.title, desc: desc ?? this.desc,
    tag: tag ?? this.tag, done: done ?? this.done, createdAt: createdAt ?? this.createdAt,
  );
}

class TodoPresets {
  static final List<TodoItem> samples = [
    TodoItem(id: 'preset-todo-1', title: '读完《人间草木》第三章', desc: '汪曾祺写栀子花那段，想和你一起读。', tag: '遐'),
    TodoItem(id: 'preset-todo-2', title: '选定倒计时墙的模板', desc: '在网站上找几个好看的样式一起挑', tag: '一起'),
    TodoItem(id: 'preset-todo-3', title: '月下窗配色定版', desc: '日间灰米低饱和 + 夜间亮蓝高饱和', tag: '一起', done: true),
  ];
}
