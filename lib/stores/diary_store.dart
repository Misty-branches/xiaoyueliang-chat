import 'package:flutter/foundation.dart';
import '../pages/diary_page.dart'; // DiaryEntry 定义暂时还在这里

/// 日记 Store —— 目前用静态数据，后续接服务器
class DiaryStore extends ChangeNotifier {
  List<DiaryEntry> _entries = [];
  int _tab = 0;

  List<DiaryEntry> get entries => _entries;
  List<DiaryEntry> get filtered {
    if (_tab == 0) return _entries;
    if (_tab == 1) return _entries.where((e) => e.author == '遐').toList();
    return _entries.where((e) => e.author == '小满').toList();
  }

  int get tab => _tab;

  void setTab(int index) {
    _tab = index;
    notifyListeners();
  }

  void load(List<DiaryEntry> entries) {
    _entries = entries;
    notifyListeners();
  }

  void addEntry(DiaryEntry entry) {
    _entries.insert(0, entry);
    notifyListeners();
  }

  // TODO: 后续接服务器 CRUD
}
