import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class DiaryStore extends ChangeNotifier {
  List<DiaryEntry> _entries = [];
  int _tab = 0;
  static const _kDiaryEntries = 'diary_entries';

  List<DiaryEntry> get entries => _entries;
  List<DiaryEntry> get filtered {
    if (_tab == 0) return _entries;
    if (_tab == 1) return _entries.where((e) => e.author == '遐').toList();
    return _entries.where((e) => e.author == '小满').toList();
  }
  int get tab => _tab;

  DiaryStore() { _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kDiaryEntries);
    if (json != null) {
      try {
        _entries = (jsonDecode(json) as List).map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) { _entries = []; }
    }
    if (_entries.isEmpty) { _entries = List.from(DiaryPresets.samples); await _save(); }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDiaryEntries, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  void setTab(int index) { _tab = index; notifyListeners(); }

  Future<void> addEntry(DiaryEntry entry) async { _entries.insert(0, entry); notifyListeners(); await _save(); }
  Future<void> removeEntry(String id) async { _entries.removeWhere((e) => e.id == id); notifyListeners(); await _save(); }

  void load(List<DiaryEntry> items) {
    if (_entries.isEmpty) { _entries = List.from(items); notifyListeners(); }
  }
}
