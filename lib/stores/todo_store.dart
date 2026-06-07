import 'package:flutter/foundation.dart';
import '../models/todo_item.dart';

/// 待办数据管理
class TodoStore extends ChangeNotifier {
  List<TodoItem> _items = [];

  List<TodoItem> get items => _items;
  List<TodoItem> get pending => _items.where((t) => !t.done).toList();
  List<TodoItem> get done => _items.where((t) => t.done).toList();

  void load(List<TodoItem> items) {
    _items = items;
    notifyListeners();
  }

  void toggle(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(done: !_items[index].done);
      notifyListeners();
    }
  }

  void add(TodoItem item) {
    _items.insert(0, item);
    notifyListeners();
  }

  // TODO: 后续接持久化
}
