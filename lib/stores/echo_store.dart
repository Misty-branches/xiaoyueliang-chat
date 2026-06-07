import 'package:flutter/foundation.dart';

/// 回音墙 Store —— 目前用静态数据，后续接服务器
class EchoStore extends ChangeNotifier {
  List<_EchoCard> _cards = [];

  List<_EchoCard> get cards => _cards;

  void load(List<_EchoCard> cards) {
    _cards = cards;
    notifyListeners();
  }

  void toggleExpanded(int index) {
    if (index >= 0 && index < _cards.length) {
      _cards[index] = _EchoCard(
        title: _cards[index].title,
        badge: _cards[index].badge,
        desc: _cards[index].desc,
        preview: _cards[index].preview,
        date: _cards[index].date,
        expanded: !_cards[index].expanded,
      );
      notifyListeners();
    }
  }

  // TODO: 后续接 CRUD
}

class _EchoCard {
  final String title;
  final String badge;
  final String desc;
  final String preview;
  final String date;
  final bool expanded;

  const _EchoCard({
    required this.title,
    required this.badge,
    required this.desc,
    required this.preview,
    required this.date,
    this.expanded = false,
  });
}
