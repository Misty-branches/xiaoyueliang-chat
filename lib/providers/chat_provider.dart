import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../models/settings.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Session> _sessions = [];
  Session? _currentSession;
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  bool _isStreaming = false;
  late ApiService _apiService;
  late DataService _dataService;
  final Uuid _uuid = const Uuid();
  String _streamingContent = '';
  Book? _referencedBook;
  bool _cloudConnected = false; // 是否成功连接到了云端记录服务

  List<Session> get sessions => _sessions;
  Session? get currentSession => _currentSession;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String get streamingContent => _streamingContent;
  Book? get referencedBook => _referencedBook;
  bool get cloudConnected => _cloudConnected;

  ChatProvider() {
    _apiService = ApiService(baseUrl: _settings.apiUrl, apiKey: _settings.apiKey);
    _dataService = DataService(baseUrl: _settings.dataServiceUrl);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // ── 加载设置 ──
    final settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      _settings = AppSettings.fromJson(jsonDecode(settingsJson));
      _apiService.updateBaseUrl(_settings.apiUrl);
      _dataService.updateBaseUrl(_settings.dataServiceUrl);
    }

    // ── 尝试从云端加载 ──
    try {
      final cloudSessions = await _dataService.listSessions();
      if (cloudSessions.isNotEmpty) {
        _sessions = cloudSessions;

        // 加载当前会话的完整消息
        final currentId = prefs.getString('current_session_id');
        if (currentId != null) {
          final cloudSession = await _dataService.getSession(currentId);
          if (cloudSession != null) {
            _currentSession = cloudSession;
            // 更新本地 sessions 列表中的消息
            final idx = _sessions.indexWhere((s) => s.id == currentId);
            if (idx >= 0) {
              _sessions[idx] = cloudSession;
            }
          } else {
            _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
          }
        } else {
          _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
        }

        _cloudConnected = true;
        notifyListeners();
        return; // 云端加载成功，跳过本地
      }
    } catch (_) {
      // 云端不可用，降级到本地
      _cloudConnected = false;
    }

    // ── 降级：从本地加载 ──
    final sessionsJson = prefs.getString('sessions');
    if (sessionsJson != null) {
      final list = jsonDecode(sessionsJson) as List;
      _sessions = list
          .map((s) => Session.fromJson(s as Map<String, dynamic>))
          .toList();

      final currentId = prefs.getString('current_session_id');
      if (currentId != null) {
        _currentSession = _sessions.firstWhere(
          (s) => s.id == currentId,
          orElse: () => _sessions.isNotEmpty ? _sessions.first : Session(id: _uuid.v4()),
        );
      }
    }

    // 创建默认会话
    if (_sessions.isEmpty) {
      _createNewSession();
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(_settings.toJson()));
    await prefs.setString('sessions', jsonEncode(_sessions.map((s) => s.toJson()).toList()));
    await prefs.setString('current_session_id', _currentSession?.id ?? '');
  }

  /// 将当前会话同步到云端
  Future<void> _syncToCloud() async {
    if (!_cloudConnected || _currentSession == null) return;
    try {
      // 确保服务器上有这个会话
      await _dataService.createSession(_currentSession!.id, _currentSession!.title);
      // 同步最后一条消息（增量同步）
      final msgs = _currentSession!.messages;
      if (msgs.isNotEmpty) {
        final lastMsg = msgs.last;
        await _dataService.addMessage(_currentSession!.id, lastMsg);
      }
    } catch (_) {
      // 静默失败，下次再试
    }
  }

  void _createNewSession() {
    final session = Session(id: _uuid.v4());
    _sessions.add(session);
    _currentSession = session;
    // 同步到云端
    if (_cloudConnected) {
      _dataService.createSession(session.id, session.title);
    }
    notifyListeners();
  }

  Future<void> switchSession(String sessionId) async {
    if (_isStreaming) return;

    // 如果云端可用，从云端加载完整会话
    if (_cloudConnected) {
      final cloudSession = await _dataService.getSession(sessionId);
      if (cloudSession != null) {
        // 合并本地消息和云端消息
        final idx = _sessions.indexWhere((s) => s.id == sessionId);
        if (idx >= 0) {
          _sessions[idx] = cloudSession;
        }
        _currentSession = cloudSession;
        await _saveData();
        notifyListeners();
        return;
      }
    }

    // 降级：本地切换
    final session = _sessions.firstWhere((s) => s.id == sessionId);
    _currentSession = session;
    await _saveData();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
      if (_currentSession == null) _createNewSession();
    }
    await _saveData();
    // 云端删除
    if (_cloudConnected) {
      _dataService.deleteSession(sessionId);
    }
    notifyListeners();
  }

  Future<void> newSession() async {
    if (_isStreaming) return;
    _createNewSession();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    _apiService.updateBaseUrl(newSettings.apiUrl);
    _apiService.updateApiKey(newSettings.apiKey);
    _dataService.updateBaseUrl(newSettings.dataServiceUrl);
    await _saveData();
    notifyListeners();

    // 测试云端连接
    _cloudConnected = await _dataService.healthCheck();
    notifyListeners();
  }

  void setReferenceBook(Book? book) {
    _referencedBook = book;
    notifyListeners();
  }

  void clearReferenceBook() {
    _referencedBook = null;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isStreaming || _currentSession == null) return;

    _isLoading = true;
    notifyListeners();

    // 添加用户消息
    final userMsg = Message(
      id: _uuid.v4(),
      role: 'user',
      content: content.trim(),
    );
    _currentSession!.messages.add(userMsg);
    _currentSession!.updatedAt = DateTime.now();

    // 自动生成标题
    if (_currentSession!.messages.length == 1) {
      _currentSession!.title = content.trim().length > 30
          ? '${content.trim().substring(0, 30)}...'
          : content.trim();
    }

    _isLoading = false;
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    // 创建占位消息
    final assistantMsg = Message(
      id: _uuid.v4(),
      role: 'assistant',
      content: '',
      isStreaming: true,
    );
    _currentSession!.messages.add(assistantMsg);
    notifyListeners();

    // 同步用户消息到云端
    _syncToCloud();

    // 调用 API
    try {
      final response = await _apiService.chatCompletion(
        messages: _currentSession!.messages
            .where((m) => m.id != assistantMsg.id)
            .toList(),
        model: _settings.model,
        temperature: _settings.temperature,
        maxTokens: _settings.maxTokens,
        systemPrompt: _settings.systemPrompt,
        bookTitle: _referencedBook?.title,
        bookContent: _referencedBook?.content,
      );
      assistantMsg.content = response;
      notifyListeners();
    } catch (e) {
      assistantMsg.content = '请求失败: $e';
    }

    // 完成流式
    _currentSession!.messages.last = assistantMsg.copyWith(isStreaming: false);
    _isStreaming = false;
    _streamingContent = '';
    _currentSession!.updatedAt = DateTime.now();
    await _saveData();

    // 最终同步到云端
    if (_cloudConnected) {
      _dataService.updateMessage(
        _currentSession!.id,
        assistantMsg.id,
        assistantMsg.content,
      );
    }

    notifyListeners();
  }

  Future<void> sendMessageWithChapter(String text, Book book, Chapter chapter) async {
    if (text.trim().isEmpty || _isStreaming || _currentSession == null) return;

    _isLoading = true;
    notifyListeners();

    // 添加用户消息
    final userMsg = Message(
      id: _uuid.v4(),
      role: 'user',
      content: text.trim(),
    );
    _currentSession!.messages.add(userMsg);
    _currentSession!.updatedAt = DateTime.now();

    _isLoading = false;
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    // 创建占位消息
    final assistantMsg = Message(
      id: _uuid.v4(),
      role: 'assistant',
      content: '',
      isStreaming: true,
    );
    _currentSession!.messages.add(assistantMsg);
    notifyListeners();

    // 调用 API，注入当前章节内容
    try {
      final enhancedSystemPrompt = '${_settings.systemPrompt}\n\n'
          '【当前阅读章节：${book.title} - ${chapter.title}】\n'
          '---章节内容开始---\n'
          '${chapter.content.length > 4000 ? "${chapter.content.substring(0, 4000)}\n\n...（以下省略）" : chapter.content}\n'
          '---章节内容结束---\n\n'
          '用户刚才读了这一章，现在提出了关于本章内容的问题。请根据以上章节内容回答。';

      final response = await _apiService.chatCompletion(
        messages: _currentSession!.messages
            .where((m) => m.id != assistantMsg.id)
            .toList(),
        model: _settings.model,
        temperature: _settings.temperature,
        maxTokens: _settings.maxTokens,
        systemPrompt: enhancedSystemPrompt,
      );
      assistantMsg.content = response;
      notifyListeners();
    } catch (e) {
      assistantMsg.content = '请求失败: $e';
    }

    _currentSession!.messages.last = assistantMsg.copyWith(isStreaming: false);
    _isStreaming = false;
    _streamingContent = '';
    _currentSession!.updatedAt = DateTime.now();
    await _saveData();
    notifyListeners();
  }

  /// 发送一条系统消息（用于阅读指令反馈）
  void sendSystemMessage(String content) {
    if (_currentSession == null) return;
    final msg = Message(
      id: _uuid.v4(),
      role: 'system',
      content: content,
    );
    _currentSession!.messages.add(msg);
    _currentSession!.updatedAt = DateTime.now();
    notifyListeners();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // called from UI listener
  }

  void cancelStreaming() {
    if (_isStreaming && _currentSession != null) {
      final lastMsg = _currentSession!.messages.last;
      if (lastMsg.isStreaming && lastMsg.content.isEmpty) {
        _currentSession!.messages.removeLast();
      } else if (lastMsg.isStreaming) {
        _currentSession!.messages.last = lastMsg.copyWith(isStreaming: false);
      }
      _isStreaming = false;
      _streamingContent = '';
      notifyListeners();
    }
  }
}
