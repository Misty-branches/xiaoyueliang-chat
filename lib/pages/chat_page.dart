import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/reading_provider.dart';
import '../providers/book_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';
import '../models/book.dart';
import '../services/chapter_parser.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final provider = context.read<ChatProvider>();
    provider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    context.read<ChatProvider>().removeListener(_onProviderChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onProviderChange() {
    _scrollToBottom();
  }

  /// 处理发送消息（支持阅读指令）
  void _handleSend(String text) {
    final chatProvider = context.read<ChatProvider>();
    final readingProvider = context.read<ReadingProvider>();

    // 检查是否是阅读指令
    if (ChapterParser.isReadingCommand(text)) {
      _handleReadingCommand(text, chatProvider, readingProvider);
      return;
    }

    // 如果是阅读模式下的普通问题，带章节上下文发送
    if (readingProvider.isReading && readingProvider.currentChapter != null) {
      chatProvider.sendMessageWithChapter(
        text,
        readingProvider.currentBook!,
        readingProvider.currentChapter!,
      );
      return;
    }

    // 普通发送
    chatProvider.sendMessage(text);
    chatProvider.clearReferenceBook();
  }

  /// 处理阅读指令
  void _handleReadingCommand(
    String text,
    ChatProvider chatProvider,
    ReadingProvider readingProvider,
  ) {
    // "不读了"
    if (text.contains('不读了') || text.contains('退出阅读')) {
      readingProvider.stopReading();
      chatProvider.sendSystemMessage('已退出阅读模式～下次再一起看书吧😌');
      return;
    }

    // "继续" — 恢复阅读，显示当前章节内容
    if (text == '继续' || text.contains('接着读')) {
      if (readingProvider.isReading && readingProvider.currentChapter != null) {
        final ch = readingProvider.currentChapter!;
        chatProvider.sendSystemMessage(
          '📖 ${readingProvider.progressText}\n\n${ch.content}',
        );
      } else {
        chatProvider.sendSystemMessage('现在没有在读书呢～去书库选一本吧📚');
      }
      return;
    }

    // "下一章"
    if (text.contains('下一章') || text.contains('下章')) {
      if (readingProvider.nextChapter()) {
        final ch = readingProvider.currentChapter;
        chatProvider.sendSystemMessage(
          '📖 翻到下一章啦~\n\n${readingProvider.progressText}\n\n${ch?.content ?? ''}',
        );
      } else {
        chatProvider.sendSystemMessage('已经是最后一章啦～🎉');
      }
      return;
    }

    // "上一章"
    if (text.contains('上一章') || text.contains('上章') || text.contains('前一章')) {
      if (readingProvider.prevChapter()) {
        final ch = readingProvider.currentChapter;
        chatProvider.sendSystemMessage(
          '📖 翻回上一章~\n\n${readingProvider.progressText}\n\n${ch?.content ?? ''}',
        );
      } else {
        chatProvider.sendSystemMessage('已经在第一章啦～');
      }
      return;
    }

    // "读第X章" / "第X章"
    final chapterNum = ChapterParser.extractChapterNumber(text);
    if (chapterNum != null && readingProvider.isReading) {
      readingProvider.goToChapter(chapterNum);
      final ch = readingProvider.currentChapter;
      if (ch != null) {
        chatProvider.sendSystemMessage(
          '📖 ${readingProvider.progressText}\n\n${ch.content}',
        );
      } else {
        chatProvider.sendSystemMessage(
          '这本书只有${readingProvider.currentBook?.chapterCount ?? 0}章哦～',
        );
      }
      return;
    }

    // "读《书名》"或"开始读"——从书库找书并开始阅读
    if (text.contains('读') || text.contains('开始读')) {
      // 从指令中提取书名
      final bookMatch = RegExp(r'[《（""]?(.+?)[》）""]?').firstMatch(text.replaceAll('开始读', '').replaceAll('读', ''));
      if (bookMatch != null) {
        final bookName = bookMatch.group(1)?.trim() ?? '';
        if (bookName.isNotEmpty) {
          final bookProvider = context.read<BookProvider>();
          final found = bookProvider.books.where(
            (b) => b.title.contains(bookName),
          ).toList();
          if (found.isNotEmpty) {
            final book = found.first;
            readingProvider.startReading(book);
            final ch = readingProvider.currentChapter;
            chatProvider.sendSystemMessage(
              '📖 开始读《${book.title}》啦！\n\n${ch?.content ?? book.content.substring(0, 2000)}',
            );
            return;
          }
        }
      }
      chatProvider.sendSystemMessage('书库里没有找到呢～先去书库添加一本吧📚');
      return;
    }

    // 不认识这个指令
    chatProvider.sendSystemMessage(
      '咦？遐不太懂这个指令呢～试试说"读第三章""下一章""不读了"😌',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = context.watch<ChatProvider>();
    final readingProvider = context.watch<ReadingProvider>();
    final session = chatProvider.currentSession;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            onPressed: () {
              Scaffold.of(ctx).openDrawer();
            },
          ),
        ),
        title: Text(
          readingProvider.isReading
              ? '📖 ${readingProvider.currentBook?.title ?? ""}'
              : (session?.title ?? '遐悦聊天'),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade200 : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      drawer: _buildSessionDrawer(context, isDark, chatProvider),
      body: Column(
        children: [
          // 阅读状态栏
          if (readingProvider.isReading) _buildReadingBar(isDark, readingProvider),
          // 消息列表
          Expanded(
            child: session == null || session.messages.isEmpty
                ? _buildEmptyState(isDark, readingProvider)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: session.messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(
                        message: session.messages[index],
                        onDelete: () => chatProvider.deleteMessage(index),
                        onRegenerate: () {
                          if (session.messages.length > index + 1) {
                            // 删除遐的回复，重发用户上一条消息
                            final userMsg = session.messages[index - 1];
                            chatProvider.deleteMessage(index + 1);
                            chatProvider.sendMessage(userMsg.content);
                          }
                        },
                        onRead: () {
                          // 朗读 —— 暂时留空，以后加 TTS
                        },
                        onEdit: () {
                          // 编辑 —— 暂时留空
                        },
                        onFavorite: () {
                          // 收藏 —— 暂时留空
                        },
                        onShare: () {
                          // 分享 —— 暂时留空
                        },
                      );
                    },
                  ),
          ),
          // Loading indicator
          if (chatProvider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          InputBar(
            isStreaming: chatProvider.isStreaming,
            referencedBook: chatProvider.referencedBook,
            onSend: _handleSend,
            onCancel: () => chatProvider.cancelStreaming(),
            onClearReference: () => chatProvider.clearReferenceBook(),
          ),
        ],
      ),
    );
  }

  /// 阅读状态栏
  Widget _buildReadingBar(bool isDark, ReadingProvider provider) {
    final book = provider.currentBook;
    if (book == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 16,
            color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              provider.progressText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          // 上一章
          _MiniButton(
            icon: Icons.chevron_left_rounded,
            onTap: provider.hasPrev ? provider.prevChapter : null,
            isDark: isDark,
          ),
          const SizedBox(width: 2),
          // 下一章
          _MiniButton(
            icon: Icons.chevron_right_rounded,
            onTap: provider.hasNext ? provider.nextChapter : null,
            isDark: isDark,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              provider.stopReading();
              context.read<ChatProvider>().sendSystemMessage('已退出阅读模式～📖');
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, ReadingProvider readingProvider) {
    if (readingProvider.isReading && readingProvider.currentChapter != null) {
      // 阅读模式下显示当前章节内容
      final ch = readingProvider.currentChapter!;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                readingProvider.progressText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ch.content,
              style: TextStyle(
                fontSize: 15,
                height: 1.8,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '开始与遐对话',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '在下方输入消息，点击发送',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDrawer(BuildContext context, bool isDark, ChatProvider provider) {
    return Drawer(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark ? Colors.blue.shade800 : Colors.blue.shade100,
                        child: Text(
                          '遐',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.blue.shade200 : Colors.blue.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '遐悦聊天',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.grey.shade200 : Colors.black87,
                            ),
                          ),
                          Text(
                            '小满 & 遐',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        provider.newSession();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('新建对话'),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade50,
                        foregroundColor: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.pushNamed<Book>(context, '/book');
                        if (result != null && context.mounted) {
                          context.read<ChatProvider>().setReferenceBook(result);
                        }
                      },
                      icon: const Icon(Icons.auto_stories_rounded, size: 18),
                      label: const Text('我的书库'),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? Colors.amber.shade900.withValues(alpha: 0.2) : Colors.amber.shade50,
                        foregroundColor: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Session list
            Expanded(
              child: provider.sessions.isEmpty
                  ? Center(
                      child: Text(
                        '暂无对话',
                        style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.sessions.length,
                      itemBuilder: (context, index) {
                        final session = provider.sessions[index];
                        final isActive = session.id == provider.currentSession?.id;
                        return ListTile(
                          selected: isActive,
                          selectedTileColor: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                          leading: Icon(
                            Icons.chat_rounded,
                            size: 20,
                            color: isActive
                                ? Colors.blue.shade400
                                : (isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                          ),
                          title: Text(
                            session.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              color: isDark ? Colors.grey.shade200 : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            session.lastMessagePreview,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onTap: () {
                            provider.switchSession(session.id);
                            Navigator.pop(context);
                          },
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            ),
                            onPressed: () => provider.deleteSession(session.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 迷你导航按钮
class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const _MiniButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? Colors.indigo.shade800.withValues(alpha: 0.4) : Colors.indigo.shade100)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? (isDark ? Colors.indigo.shade200 : Colors.indigo.shade600)
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade400),
        ),
      ),
    );
  }
}
