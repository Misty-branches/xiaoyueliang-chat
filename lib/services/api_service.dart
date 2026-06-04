import 'package:dio/dio.dart';
import '../models/message.dart';

class ApiService {
  final Dio _dio;
  String _apiKey;

  ApiService({required String baseUrl, String apiKey = '', Duration timeout = const Duration(seconds: 60)})
      : _apiKey = apiKey,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: timeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
        )) {
    if (apiKey.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $apiKey';
    }
  }

  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  void updateApiKey(String apiKey) {
    _apiKey = apiKey;
    if (apiKey.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $apiKey';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Send a chat completion request (non-streaming, more compatible).
  /// Returns the full response text.
  Future<String> chatCompletion({
    required List<Message> messages,
    required String model,
    double temperature = 0.7,
    int maxTokens = 4096,
    String? systemPrompt,
    String? bookTitle,
    String? bookContent,
  }) async {
    final List<Map<String, String>> apiMessages = [];

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      String finalPrompt = systemPrompt;
      if (bookTitle != null && bookContent != null) {
        finalPrompt += '\n\n【参考书籍：$bookTitle】\n${bookContent.length > 3000 ? '${bookContent.substring(0, 3000)}\n...' : bookContent}';
      }
      apiMessages.add({'role': 'system', 'content': finalPrompt});
    }

    for (final msg in messages) {
      apiMessages.add({'role': msg.role, 'content': msg.content});
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/chat/completions',
        data: {
          'model': model,
          'messages': apiMessages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': false,
        },
      );

      final data = response.data;
      if (data == null) throw Exception('Empty response');

      final choices = data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map?;
        final content = message?['content'] as String?;
        return content ?? '';
      }
      return '';
    } on DioException catch (e) {
      return '[错误: ${_formatError(e)}]';
    } catch (e) {
      return '[错误: $e]';
    }
  }

  String _formatError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return '连接超时，请检查API服务器地址';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return '响应超时';
    }
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final body = e.response?.data;
      if (body is Map && body.containsKey('error')) {
        return '${body['error']['message'] ?? body['error']}';
      }
      return 'HTTP $statusCode';
    }
    return '网络错误: ${e.message}';
  }
}
