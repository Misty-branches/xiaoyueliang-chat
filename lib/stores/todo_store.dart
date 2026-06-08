import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoStore extends ChangeNotifier {
  List<TodoItem> _items = [];
  static const _kTodoItems = 'todo_items';

  List<TodoItem> get items => _items;
  List<TodoItem> get pending => _items.where((t) => !t.done).toList();
  List<TodoItem> get done => _items.where((t) => t.done).toList();

  TodoStore() { _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kTodoItems);
    if (json != null) {
      try {
        _items = (jsonDecode(json) as List).map((e) => TodoItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) { _items = []; }
    }
    if (_items.isEmpty) { _items = List.from(TodoPresets.samples); await _save(); }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTodoItems, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> toggle(int index) async {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(done: !_items[index].done);
      notifyListeners(); await _save();
    }
  }

  Future<void> add(TodoItem item) async { _items.insert(0, item); notifyListeners(); await _save(); }
  Future<void> remove(String id) async { _items.removeWhere((t) => t.id == id); notifyListeners(); await _save(); }
  Future<void> clearDone() async { _items.removeWhere((t) => t.done); notifyListeners(); await _save(); }

  void load(List<TodoItem> items) {
    if (_items.isEmpty) { _items = List.from(items); notifyListeners(); }
  }
}
