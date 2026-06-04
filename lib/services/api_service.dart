import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/message.dart';

class ApiService {
  final Dio _dio;

  ApiService({required String baseUrl, Duration timeout = const Duration(seconds: 60)})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: timeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
        ));

  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Send a chat completion request with streaming support.
  /// Returns a Stream<String> that yields content deltas.
  Stream<String> chatCompletion({
    required List<Message> messages,
    required String model,
    double temperature = 0.7,
    int maxTokens = 4096,
    String? systemPrompt,
    String? bookTitle,
    String? bookContent,
  }) async* {
    final List<Map<String, String>> apiMessages = [];

    // Add system prompt if provided
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      String finalPrompt = systemPrompt;

      // Inject referenced book content as context
      if (bookTitle != null && bookContent != null) {
        finalPrompt += '''

【参考书籍：$bookTitle】
以下是用户引用的书籍内容，请在回答中根据这些内容进行回应：
---
${bookContent.length > 3000 ? '${bookContent.substring(0, 3000)}\n\n...（以下内容省略，共${bookContent.length}字）' : bookContent}
---
''';
      }

      apiMessages.add({'role': 'system', 'content': finalPrompt});
    }

    // Add conversation history
    for (final msg in messages) {
      apiMessages.add({'role': msg.role, 'content': msg.content});
    }

    try {
      final response = await _dio.post<ResponseBody>(
        '/v1/chat/completions',
        data: {
          'model': model,
          'messages': apiMessages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data;
      if (stream == null) {
        throw Exception('Empty response from server');
      }

      String buffer = '';
      await for (final chunk in stream.stream) {
        final decoded = utf8.decode(chunk as List<int>);
        buffer += decoded;

        // Process complete SSE lines
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;
          if (line == 'data: [DONE]') return;

          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            try {
              final jsonData = jsonDecode(jsonStr);
              final choices = jsonData['choices'] as List?;
              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'] as Map?;
                final content = delta?['content'] as String?;
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              }
            } catch (e) {
              // Skip malformed JSON lines
              continue;
            }
          }
        }
      }
    } on DioException catch (e) {
      final errorMsg = _formatError(e);
      yield '\n\n[错误: $errorMsg]';
    } catch (e) {
      yield '\n\n[错误: $e]';
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
