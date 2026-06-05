import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isSystem = message.role == 'system';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 系统消息（阅读内容等）居中显示
    if (isSystem) {
      return _buildSystemMessage(isDark);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) const Spacer(),
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark
                  ? Colors.blueGrey.shade700
                  : Colors.blue.shade50,
              child: Text(
                '遐',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blueGrey.shade200 : Colors.blue.shade700,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * (isUser ? 0.85 : 0.82),
                minWidth: isUser ? MediaQuery.of(context).size.width * 0.25 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? (isDark ? Colors.blue.shade700 : Colors.blue.shade500)
                    : (isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: isUser
                  ? Text(
                      message.content,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    )
                  : MarkdownBody(
                      data: message.isStreaming
                          ? '${message.content}▌'
                          : message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        code: TextStyle(
                          backgroundColor: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade200,
                          fontSize: 13,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        h1: TextStyle(
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: TextStyle(
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        a: TextStyle(color: isDark ? Colors.lightBlue.shade300 : Colors.blue),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                              width: 3,
                            ),
                          ),
                        ),
                        listBullet: TextStyle(
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                        ),
                        tableBorder: TableBorder.all(
                          color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                        ),
                        tableHead: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                        ),
                      ),
                    ),
            ),
          ),
          if (!isUser) const Spacer(),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
              child: Text(
                '满',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 系统消息（居中、底色不同、带书本图标）
  Widget _buildSystemMessage(bool isDark) {
    final isReading = message.content.startsWith('📖');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isReading
              ? (isDark ? Colors.indigo.shade900.withValues(alpha: 0.4) : Colors.indigo.shade50)
              : (isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReading
                ? (isDark ? Colors.indigo.shade700.withValues(alpha: 0.3) : Colors.indigo.shade200)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isReading ? Icons.auto_stories_rounded : Icons.info_outline_rounded,
                  size: 14,
                  color: isReading
                      ? (isDark ? Colors.indigo.shade300 : Colors.indigo.shade600)
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                Text(
                  isReading ? '阅读' : '系统',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isReading
                        ? (isDark ? Colors.indigo.shade300 : Colors.indigo.shade600)
                        : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
