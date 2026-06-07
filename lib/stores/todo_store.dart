import 'package:flutter/foundation.dart';

/// 待办 Store —— 目前用静态数据，后续接持久化
class TodoStore extends ChangeNotifier {
  List<_TodoItem> _items = [];

  List<_TodoItem> get items => _items;
  List<_TodoItem> get pending => _items.where((t) => !t.done).toList();
  List<_TodoItem> get done => _items.where((t) => t.done).toList();

  void load(List<_TodoItem> items) {
    _items = items;
    notifyListeners();
  }

  void toggle(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index] = _TodoItem(
        title: _items[index].title,
        desc: _items[index].desc,
        tag: _items[index].tag,
        done: !_items[index].done,
      );
      notifyListeners();
    }
  }

  void add(_TodoItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  // TODO: 后续接持久化
}

class _TodoItem {
  final String title;
  final String desc;
  final String tag;
  final bool done;

  const _TodoItem({
    required this.title,
    required this.desc,
    required this.tag,
    this.done = false,
  });
}
