import 'package:flutter/foundation.dart';
import '../models/echo_card.dart';

/// 回音墙数据管理
class EchoStore extends ChangeNotifier {
  List<EchoCard> _cards = [];

  List<EchoCard> get cards => _cards;

  void load(List<EchoCard> cards) {
    _cards = cards;
    notifyListeners();
  }

  void toggleExpanded(int index) {
    if (index >= 0 && index < _cards.length) {
      _cards[index] = _cards[index].copyWith(expanded: !_cards[index].expanded);
      notifyListeners();
    }
  }

  // TODO: 后续接 CRUD
}
