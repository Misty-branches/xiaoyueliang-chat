import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_data.dart';
import '../models/daily_quote.dart';
import '../models/activity_note.dart';
import '../models/latest_message.dart';

/// 窗台页数据管理
/// 统一管理今日心情、动态文案、活动卡片、最新消息
class WindowsillProvider extends ChangeNotifier {
  // ---- 数据 ----
  MoodData _mood = MoodData.defaultMood();
  DailyQuote _quote = DailyQuote.defaultQuote();
  ActivityNote _note = ActivityNote.defaultNote();
  LatestMessage _latestMessage = LatestMessage.empty();

  // ---- SharedPreferences keys ----
  static const _kMood = 'windowsill_mood';
  static const _kQuote = 'windowsill_quote';
  static const _kNote = 'windowsill_note';

  // ---- Getters ----
  MoodData get mood => _mood;
  DailyQuote get quote => _quote;
  ActivityNote get note => _note;
  LatestMessage get latestMessage => _latestMessage;

  /// 构造函数：自动加载本地数据
  WindowsillProvider() {
    _loadData();
  }

  /// 从本地存储加载数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 加载心情
    final moodJson = prefs.getString(_kMood);
    if (moodJson != null) {
      try {
        _mood = MoodData.fromJson(jsonDecode(moodJson) as Map<String, dynamic>);
      } catch (_) {
        _mood = MoodData.defaultMood();
      }
    }
    // 如果不是今天的心情，自动推断
    if (!_mood.isToday) {
      _mood = MoodData.defaultMood(); // 先用默认，后续可接自动推断
    }

    // 加载文案
    final quoteJson = prefs.getString(_kQuote);
    if (quoteJson != null) {
      try {
        final saved = DailyQuote.fromJson(jsonDecode(quoteJson) as Map<String, dynamic>);
        // 检查是否需要更新（每天轮换）
        final todayQuote = QuoteLibrary.getTodayQuote();
        _quote = todayQuote; // 每天自动换
      } catch (_) {
        _quote = QuoteLibrary.getTodayQuote();
      }
    } else {
      _quote = QuoteLibrary.getTodayQuote();
    }

    // 加载便签
    final noteJson = prefs.getString(_kNote);
    if (noteJson != null) {
      try {
        _note = ActivityNote.fromJson(jsonDecode(noteJson) as Map<String, dynamic>);
      } catch (_) {
        _note = ActivityNoteLibrary.getTodayNote();
      }
    }
    // 如果不是今天的便签，自动更新
    if (!_note.isToday) {
      _note = ActivityNoteLibrary.getTodayNote();
    }

    notifyListeners();
  }

  // ---- 心情操作 ----

  /// 手动设置心情
  Future<void> setMood(MoodData mood) async {
    _mood = mood.copyWith(updatedAt: DateTime.now());
    notifyListeners();
    await _saveMood();
  }

  /// 自动推断心情（从最近聊天记录）
  Future<void> inferMood(List<String> recentMessages) async {
    // 只在非手动模式下自动推断
    if (_mood.isManual) return;
    _mood = MoodPresets.inferFromChat(recentMessages);
    notifyListeners();
    await _saveMood();
  }

  /// 重置为自动模式
  Future<void> resetToAutoMood() async {
    _mood = MoodData.defaultMood();
    notifyListeners();
    await _saveMood();
  }

  // ---- 文案操作 ----

  /// 刷新文案（手动切换下一句）
  Future<void> refreshQuote() async {
    _quote = QuoteLibrary.getRandomQuote(excludeIndex: _quote.index);
    notifyListeners();
    await _saveQuote();
  }

  // ---- 便签操作 ----

  /// 刷新便签（手动切换）
  Future<void> refreshNote() async {
    _note = ActivityNoteLibrary.getRandomNote();
    notifyListeners();
    await _saveNote();
  }

  /// 根据聊天内容更新便签
  Future<void> updateNoteFromChat(List<String> recentMessages) async {
    final tag = ActivityNoteLibrary.inferTag(recentMessages);
    _note = ActivityNoteLibrary.getRandomNote(preferTag: tag);
    notifyListeners();
    await _saveNote();
  }

  // ---- 消息操作 ----

  /// 更新最新消息（从ChatProvider调用）
  void updateLatestMessage(LatestMessage message) {
    _latestMessage = message;
    notifyListeners();
  }

  // ---- 持久化 ----

  Future<void> _saveMood() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMood, jsonEncode(_mood.toJson()));
  }

  Future<void> _saveQuote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kQuote, jsonEncode(_quote.toJson()));
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNote, jsonEncode(_note.toJson()));
  }

  /// 清除所有本地数据（用于调试）
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kMood);
    await prefs.remove(_kQuote);
    await prefs.remove(_kNote);
    _mood = MoodData.defaultMood();
    _quote = QuoteLibrary.getTodayQuote();
    _note = ActivityNoteLibrary.getTodayNote();
    _latestMessage = LatestMessage.empty();
    notifyListeners();
  }
}
