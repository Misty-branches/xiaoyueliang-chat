import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/echo_card.dart';

class EchoStore extends ChangeNotifier {
  List<EchoCard> _cards = [];
  static const _kEchoCards = 'echo_cards';

  List<EchoCard> get cards => _cards;
  int get count => _cards.length;

  EchoStore() { _loadData(); }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kEchoCards);
    if (json != null) {
      try {
        _cards = (jsonDecode(json) as List).map((e) => EchoCard.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) { _cards = []; }
    }
    if (_cards.isEmpty) { _cards = List.from(EchoPresets.samples); await _save(); }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEchoCards, jsonEncode(_cards.map((e) => e.toJson()).toList()));
  }

  Future<void> toggleExpanded(int index) async {
    if (index >= 0 && index < _cards.length) {
      _cards[index] = _cards[index].copyWith(expanded: !_cards[index].expanded);
      notifyListeners(); await _save();
    }
  }

  Future<void> addCard(EchoCard card) async { _cards.insert(0, card); notifyListeners(); await _save(); }
  Future<void> removeCard(String id) async { _cards.removeWhere((c) => c.id == id); notifyListeners(); await _save(); }

  void load(List<EchoCard> items) {
    if (_cards.isEmpty) { _cards = List.from(items); notifyListeners(); }
  }
}
