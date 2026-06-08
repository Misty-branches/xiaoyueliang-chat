import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/echo_card.dart';

/// 回音墙数据管理
class EchoStore extends ChangeNotifier {
  List<EchoCard> _cards = [];

  // ---- SharedPreferences keys ----
  static const _kEchoCards = 'echo_cards';

  // ---- Getters ----
  List<EchoCard> get cards => _cards;
  int get count => _cards.length;

  /// 构造函数：自动加载本地数据
  EchoStore() {
    _loadData();
  }

  /// 从本地存储加载数据
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kEchoCards);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        _cards = list
            .map((e) => EchoCard.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _cards = [];
      }
    }
    // 如果没有数据，加载预置回音
    if (_cards.isEmpty) {
      _cards = List.from(EchoPresets.samples);
      await _save();
    }
    notifyListeners();
  }

  /// 持久化到本地
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_cards.map((e) => e.toJson()).toList());
    await prefs.setString(_kEchoCards, json);
  }

  /// 切换展开状态
  Future<void> toggleExpanded(int index) async {
    if (index >= 0 && index < _cards.length) {
      _cards[index] = _cards[index].copyWith(expanded: !_cards[index].expanded);
      notifyListeners();
      await _save();
    }
  }

  /// 添加回音
  Future<void> addCard(EchoCard card) async {
    _cards.insert(0, card);
    notifyListeners();
    await _save();
  }

  /// 删除回音
  Future<void> removeCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    notifyListeners();
    await _save();
  }

  /// 加载初始数据（仅在列表为空时）
  void load(List<EchoCard> items) {
    if (_cards.isEmpty) {
      _cards = List.from(items);
      notifyListeners();
    }
  }
}
