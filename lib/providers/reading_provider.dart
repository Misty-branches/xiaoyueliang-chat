import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/chapter.dart';

/// 阅读状态
enum ReadingStatus {
  idle,     // 没有在读书
  reading,  // 正在读某章
}

/// 阅读模式管理器
/// 管理当前在读哪本书、哪一章，以及阅读状态
class ReadingProvider extends ChangeNotifier {
  Book? _currentBook;
  int _currentChapterIndex = 1; // 从1开始
  ReadingStatus _status = ReadingStatus.idle;

  Book? get currentBook => _currentBook;
  int get currentChapterIndex => _currentChapterIndex;
  ReadingStatus get status => _status;
  bool get isReading => _status == ReadingStatus.reading;

  /// 当前在读的章节
  Chapter? get currentChapter {
    if (_currentBook == null) return null;
    return _currentBook!.getChapter(_currentChapterIndex);
  }

  /// 是否有上一章
  bool get hasPrev => _currentChapterIndex > 1;

  /// 是否有下一章
  bool get hasNext => _currentBook != null && _currentChapterIndex < _currentBook!.chapterCount;

  /// 当前进度文字，如 "第3章/共12章"
  String get progressText {
    if (_currentBook == null) return '';
    final ch = currentChapter;
    final chTitle = ch?.title ?? '第$_currentChapterIndex部分';
    return '$chTitle  ($_currentChapterIndex/${_currentBook!.chapterCount}章)';
  }

  /// 开始阅读一本书
  void startReading(Book book, {int chapterIndex = 1}) {
    _currentBook = book;
    _currentChapterIndex = chapterIndex.clamp(1, book.chapterCount);
    _status = ReadingStatus.reading;
    notifyListeners();
  }

  /// 跳转到指定章节
  void goToChapter(int chapterIndex) {
    if (_currentBook == null || _status != ReadingStatus.reading) return;
    _currentChapterIndex = chapterIndex.clamp(1, _currentBook!.chapterCount);
    notifyListeners();
  }

  /// 下一章
  bool nextChapter() {
    if (_currentBook == null) return false;
    if (_currentChapterIndex < _currentBook!.chapterCount) {
      _currentChapterIndex++;
      notifyListeners();
      return true;
    }
    return false; // 已经是最后一章
  }

  /// 上一章
  bool prevChapter() {
    if (_currentChapterIndex > 1) {
      _currentChapterIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// 退出阅读
  void stopReading() {
    _currentBook = null;
    _currentChapterIndex = 1;
    _status = ReadingStatus.idle;
    notifyListeners();
  }

  /// 处理自然语言阅读指令
  /// 返回处理结果描述
  String? handleCommand(String command) {
    final lower = command.trim().toLowerCase();

    // "不读了" / "退出阅读"
    if (lower.contains('不读了') || lower.contains('退出阅读')) {
      stopReading();
      return '好，不读了～下次再一起看书吧😌';
    }

    // "继续" — 什么都不做，保持当前阅读位置
    if (lower == '继续' || lower.contains('接着读')) {
      if (_status == ReadingStatus.reading) {
        return '好，继续读~';
      }
      return null;
    }

    // "下一章"
    if (lower.contains('下一章') || lower == '下一章' || lower.contains('下章')) {
      if (nextChapter()) {
        final ch = currentChapter;
        return '好的，翻到${ch?.title ?? '第$_currentChapterIndex章'}了~';
      }
      return '已经是最后一章啦～';
    }

    // "上一章"
    if (lower.contains('上一章') || lower == '上一章' || lower.contains('上章') || lower.contains('前一章')) {
      if (prevChapter()) {
        final ch = currentChapter;
        return '好的，翻回${ch?.title ?? '第$_currentChapterIndex章'}~';
      }
      return '已经在第一章啦～';
    }

    // "读第X章" / "第X章"
    // 这个需要通过 ChapterParser 解析
    // 在 ChatProvider 中处理

    return null;
  }
}
