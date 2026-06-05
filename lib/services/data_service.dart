import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';
import '../models/session.dart';

/// 云端聊天记录服务
/// 与服务器上的 chat_record_service.py 通信
class DataService {
  String _baseUrl;
  final http.Client _client = http.Client();

  DataService({required String baseUrl}) : _baseUrl = baseUrl;

  void updateBaseUrl(String url) {
    _baseUrl = url;
  }

  String get _apiPrefix => '$_baseUrl/api';

  // ── 健康检查 ────────────────────────────

  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$_apiPrefix/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── 会话管理 ────────────────────────────

  /// 获取所有会话列表（只含元数据，不含消息）
  Future<List<Session>> listSessions() async {
    try {
      final response = await _client
          .get(Uri.parse('$_apiPrefix/sessions'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessions = (data['sessions'] as List).map((s) {
          return Session(
            id: s['id'] ?? '',
            title: s['title'] ?? '新对话',
            createdAt: DateTime.parse(s['createdAt'] ?? DateTime.now().toIso8601String()),
            updatedAt: DateTime.parse(s['updatedAt'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();
        return sessions;
      }
    } catch (_) {
      // 服务不可用时静默失败，调用方处理降级
    }
    return [];
  }

  /// 获取单个会话（含完整消息列表）
  Future<Session?> getSession(String sessionId) async {
    try {
      final response = await _client
          .get(Uri.parse('$_apiPrefix/sessions/$sessionId'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List).map((m) {
          return Message(
            id: m['id'] ?? '',
            role: m['role'] ?? 'user',
            content: m['content'] ?? '',
            timestamp: DateTime.parse(m['timestamp'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();
        return Session(
          id: data['id'],
          title: data['title'] ?? '新对话',
          messages: messages,
          createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
          updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
        );
      }
    } catch (_) {}
    return null;
  }

  /// 在服务器上创建会话
  Future<String?> createSession(String sessionId, String title) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_apiPrefix/sessions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': sessionId, 'title': title}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// 删除服务器上的会话
  Future<bool> deleteSession(String sessionId) async {
    try {
      final response = await _client
          .delete(Uri.parse('$_apiPrefix/sessions/$sessionId'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── 消息管理 ────────────────────────────

  /// 添加消息到服务器
  Future<bool> addMessage(String sessionId, Message message) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_apiPrefix/sessions/$sessionId/messages'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': message.id,
              'role': message.role,
              'content': message.content,
              'timestamp': message.timestamp.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 更新消息内容（用于流式更新）
  Future<bool> updateMessage(String sessionId, String messageId, String content) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_apiPrefix/sessions/$sessionId/messages/$messageId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'content': content}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── 归档管理 ────────────────────────────

  /// 归档旧消息，只保留最近的活跃上下文
  Future<Map<String, dynamic>> archiveSession(String sessionId,
      {bool force = false}) async {
    try {
      final uri = Uri.parse('$_apiPrefix/sessions/$sessionId/archive')
          .replace(queryParameters: force ? {'force': 'true'} : null);
      final response = await _client
          .post(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'archived': 0, 'active': 0, 'message': '归档请求失败'};
  }

  /// 获取未归档的活跃消息（用于喂给 AI 的上下文）
  Future<List<Message>> getActiveMessages(String sessionId) async {
    try {
      final response = await _client
          .get(Uri.parse('$_apiPrefix/sessions/$sessionId/active-messages'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = (data['messages'] as List).map((m) {
          return Message(
            id: m['id'] ?? '',
            role: m['role'] ?? 'user',
            content: m['content'] ?? '',
            timestamp: DateTime.parse(
                m['timestamp'] ?? DateTime.now().toIso8601String()),
          );
        }).toList();
        return messages;
      }
    } catch (_) {}
    return [];
  }

  /// 获取归档状态
  Future<Map<String, dynamic>> getArchiveStatus(String sessionId) async {
    try {
      final response = await _client
          .get(Uri.parse('$_apiPrefix/sessions/$sessionId/archive-status'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {'needsArchive': false};
  }

  // ── 搜索 ────────────────────────────────

  /// 搜索所有聊天记录
  Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final encoded = Uri.encodeQueryComponent(query.trim());
      final response = await _client
          .get(Uri.parse('$_apiPrefix/search?q=$encoded'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      }
    } catch (_) {}
    return [];
  }

  void dispose() {
    _client.close();
  }
}
