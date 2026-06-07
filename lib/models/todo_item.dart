/// 待办事项模型
class TodoItem {
  final String title;
  final String desc;
  final String tag;
  final bool done;

  const TodoItem({
    required this.title,
    required this.desc,
    required this.tag,
    this.done = false,
  });

  TodoItem copyWith({bool? done}) {
    return TodoItem(
      title: title,
      desc: desc,
      tag: tag,
      done: done ?? this.done,
    );
  }
}
