import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

/// 待办数据管理
class TodoStore extends ChangeNotifier {
  List<TodoItem> _items = [];

  // ---- SharedPreferences keys ----
  static const _kTodoItems = 'todo_items';

  // ---- Getters ----
  List<TodoItem> get items => _items;
  List<TodoItem> get pending => _items.where((t) => !t.done).toList();
  List<TodoItem> get done => _items.where((t) => t.done).toList();
  int get pendingCount => pending.length;
  int get doneCount => done.length;

  /// 构造函数：自动加载本地数据
  TodoStore() {
    _loadData();
  }

  /// 从本地存储加载数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kTodoItems);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _items = list
            .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    // 如果没有数据，加载预置待办
    if (_items.isEmpty) {
      _items = List.from(TodoPresets.samples);
      await _save();
    }
    notifyListeners();
  }

  /// 持久化到本地
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_kTodoItems, json);
  }

  /// 切换完成状态
  Future<void> toggle(int index) async {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(done: !_items[index].done);
      notifyListeners();
      await _save();
    }
  }

  /// 添加待办
  Future<void> add(TodoItem item) async {
    _items.insert(0, item);
    notifyListeners();
    await _save();
  }

  /// 删除待办
  Future<void> remove(String id) async {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
    await _save();
  }

  /// 清除已完成
  Future<void> clearDone() async {
    _items.removeWhere((t) => t.done);
    notifyListeners();
    await _save();
  }
}
