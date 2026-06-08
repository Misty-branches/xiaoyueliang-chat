import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/session.dart';
import '../models/settings.dart';
import '../models/book.dart';
import '../models/chapter.dart';
import '../models/theme_scheme.dart';
import '../models/unified_theme.dart';
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

  int _themeVersion = 0; // 主题版本号，仅用于 Selector 判断主题是否变化

  List<Session> get sessions => _sessions;
  Session? get currentSession => _currentSession;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String get streamingContent => _streamingContent;
  Book? get referencedBook => _referencedBook;
  bool get cloudConnected => _cloudConnected;
  ThemeScheme get currentScheme => ThemeScheme.fromId(_settings.schemeId);
  int get themeVersion => _themeVersion;

  /// 获取当前统一配色方案
  UnifiedTheme get currentUnifiedTheme => UnifiedTheme.fromId(_settings.schemeId);

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

  /// 删除当前会话中的某条消息
  void deleteMessage(int index) {
    if (_currentSession == null || index < 0 || index >= _currentSession!.messages.length) return;
    _currentSession!.messages.removeAt(index);
    _saveData();
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
    _themeVersion++; // 主题变化，递增版本号通知 Selector
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

  /// 检查是否需要归档旧消息，必要时自动触发归档
  Future<void> _checkAndArchive() async {
    if (_currentSession == null || !_cloudConnected) return;

    try {
      final status = await _dataService.getArchiveStatus(_currentSession!.id);
      if (status['needsArchive'] == true) {
        await _dataService.archiveSession(_currentSession!.id);
      }
    } catch (_) {
      // 归档失败不影响发消息，降级为全量发送
    }
  }

  /// 手动触发归档（用户也可以主动调用）
  Future<Map<String, dynamic>> manualArchive() async {
    if (_currentSession == null) return {'archived': 0, 'message': '没有活动的对话'};
    if (!_cloudConnected) return {'archived': 0, 'message': '云端未连接'};
    return await _dataService.archiveSession(_currentSession!.id, force: true);
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isLoading || _currentSession == null) return;

    _isLoading = true;
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    // 检查是否需要归档旧消息（本地估算活跃消息大小）
    if (_cloudConnected) {
      await _checkAndArchive();
    }

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
    notifyListeners();

    // 同步用户消息到云端
    await _syncToCloud();

    // 获取未归档的活跃消息用于 API 请求
    final List<Message> activeMessages;
    if (_cloudConnected) {
      final serverActive = await _dataService.getActiveMessages(_currentSession!.id);
      final serverIds = serverActive.map((m) => m.id).toSet();
      activeMessages = _currentSession!.messages
          .where((m) => serverIds.contains(m.id))
          .toList();
      for (final msg in serverActive) {
        if (!activeMessages.any((m) => m.id == msg.id)) {
          activeMessages.add(msg);
        }
      }
    } else {
      activeMessages = _currentSession!.messages.toList();
    }

    // 调用 API（非流式：等完整响应再一次性显示）
    try {
      final response = await _apiService.chatCompletion(
        messages: activeMessages,
        model: _settings.model,
        temperature: _settings.temperature,
        maxTokens: _settings.maxTokens,
        systemPrompt: _settings.systemPrompt,
        bookTitle: _referencedBook?.title,
        bookContent: _referencedBook?.content,
      );

      // API 返回完整内容后，创建一次性消息
      final assistantMsg = Message(
        id: _uuid.v4(),
        role: 'assistant',
        content: response,
      );
      _currentSession!.messages.add(assistantMsg);
      _currentSession!.updatedAt = DateTime.now();

      // 同步到云端
      if (_cloudConnected) {
        _dataService.updateMessage(
          _currentSession!.id,
          assistantMsg.id,
          assistantMsg.content,
        );
      }
    } catch (e) {
      // 错误消息也一次性显示
      final errorMsg = Message(
        id: _uuid.v4(),
        role: 'assistant',
        content: '请求失败: $e',
      );
      _currentSession!.messages.add(errorMsg);
    }

    _isLoading = false;
    _isStreaming = false;
    _streamingContent = '';
    await _saveData();
    notifyListeners();
  }

  Future<void> sendMessageWithChapter(String text, Book book, Chapter chapter) async {
    if (text.trim().isEmpty || _isLoading || _currentSession == null) return;

    _isLoading = true;
    _isStreaming = true;
    _streamingContent = '';
    notifyListeners();

    // 检查是否需要归档
    if (_cloudConnected) {
      await _checkAndArchive();
    }

    // 添加用户消息
    final userMsg = Message(
      id: _uuid.v4(),
      role: 'user',
      content: text.trim(),
    );
    _currentSession!.messages.add(userMsg);
    _currentSession!.updatedAt = DateTime.now();
    notifyListeners();

    // 同步到云端然后获取活跃消息
    await _syncToCloud();

    final List<Message> activeMessages;
    if (_cloudConnected) {
      final serverActive = await _dataService.getActiveMessages(_currentSession!.id);
      final serverIds = serverActive.map((m) => m.id).toSet();
      activeMessages = _currentSession!.messages
          .where((m) => serverIds.contains(m.id))
          .toList();
      for (final msg in serverActive) {
        if (!activeMessages.any((m) => m.id == msg.id)) {
          activeMessages.add(msg);
        }
      }
    } else {
      activeMessages = _currentSession!.messages.toList();
    }

    // 调用 API，注入当前章节内容
    try {
      final enhancedSystemPrompt = '${_settings.systemPrompt}\n\n'
          '【当前阅读章节：${book.title} - ${chapter.title}】\n'
          '---章节内容开始---\n'
          '${chapter.content.length > 4000 ? "${chapter.content.substring(0, 4000)}\n\n...（以下省略）" : chapter.content}\n'
          '---章节内容结束---\n\n'
          '用户刚才读了这一章，现在提出了关于本章内容的问题。请根据以上章节内容回答。';

      final response = await _apiService.chatCompletion(
        messages: activeMessages,
        model: _settings.model,
        temperature: _settings.temperature,
        maxTokens: _settings.maxTokens,
        systemPrompt: enhancedSystemPrompt,
      );

      // API 返回完整内容后，创建一次性消息
      final assistantMsg = Message(
        id: _uuid.v4(),
        role: 'assistant',
        content: response,
      );
      _currentSession!.messages.add(assistantMsg);
      _currentSession!.updatedAt = DateTime.now();
    } catch (e) {
      final errorMsg = Message(
        id: _uuid.v4(),
        role: 'assistant',
        content: '请求失败: $e',
      );
      _currentSession!.messages.add(errorMsg);
    }

    _isLoading = false;
    _isStreaming = false;
    _streamingContent = '';
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
    _isLoading = false;
    _isStreaming = false;
    _streamingContent = '';
    notifyListeners();
  }
}
