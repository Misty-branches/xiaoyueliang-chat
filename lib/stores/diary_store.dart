import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

/// 日记数据管理
class DiaryStore extends ChangeNotifier {
  List<DiaryEntry> _entries = [];
  int _tab = 0;

  // ---- SharedPreferences keys ----
  static const _kDiaryEntries = 'diary_entries';

  // ---- Getters ----
  List<DiaryEntry> get entries => _entries;
  List<DiaryEntry> get filtered {
    if (_tab == 0) return _entries;
    if (_tab == 1) return _entries.where((e) => e.author == '遐').toList();
    return _entries.where((e) => e.author == '小满').toList();
  }
  int get tab => _tab;

  /// 构造函数：自动加载本地数据
  DiaryStore() {
    _loadData();
  }

  /// 从本地存储加载数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kDiaryEntries);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _entries = list
            .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _entries = [];
      }
    }
    // 如果没有数据，加载预置日记
    if (_entries.isEmpty) {
      _entries = List.from(DiaryPresets.samples);
      await _save();
    }
    notifyListeners();
  }

  /// 持久化到本地
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kDiaryEntries, json);
  }

  /// 切换标签页
  void setTab(int index) {
    _tab = index;
    notifyListeners();
  }

  /// 添加日记
  Future<void> addEntry(DiaryEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _save();
  }

  /// 删除日记
  Future<void> removeEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  /// 更新日记
  Future<void> updateEntry(DiaryEntry updated) async {
    final index = _entries.indexWhere((e) => e.id == updated.id);
    if (index >= 0) {
      _entries[index] = updated;
      notifyListeners();
      await _save();
    }
  }

  /// 获取今天的日记
  DiaryEntry? get todayEntry {
    try {
      return _entries.firstWhere((e) => e.isToday);
    } catch (_) {
      return null;
    }
  }

  /// 加载初始数据（仅在列表为空时）
  void load(List<DiaryEntry> items) {
    if (_entries.isEmpty) {
      _entries = List.from(items);
      notifyListeners();
    }
  }
}
