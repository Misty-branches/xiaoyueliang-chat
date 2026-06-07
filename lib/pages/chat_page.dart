import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xiayue_chat/providers/chat_provider.dart';
import 'package:xiayue_chat/providers/reading_provider.dart';
import 'package:xiayue_chat/models/theme_scheme.dart';
import '../models/moonlit_colors.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    final provider = context.read<ChatProvider>();
    provider.sendMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = MoonlitColors.forMode(isDark);
    final chatProvider = context.watch<ChatProvider>();
    final readingProvider = context.watch<ReadingProvider>();
    final session = chatProvider.currentSession;
    final settings = chatProvider.settings;
    final scheme = chatProvider.currentScheme;

    return Scaffold(
      backgroundColor: c.bg,
      // ---- 月下窗风格顶栏 ----
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: c.inkSec),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/hub', (route) => false),
        ),
        title: Text(
          readingProvider.isReading
              ? '📖 ${readingProvider.currentBook?.title ?? ""}'
              : (session?.title ?? '与遐对话'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.ink),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_rounded, size: 20, color: c.inkSec),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),

      // ---- 会话抽屉 ----
      drawer: _buildSessionDrawer(context, isDark, c, chatProvider, scheme),

      // ---- 主体 ----
      body: Column(
        children: [
          // 阅读状态栏
          if (readingProvider.isReading) _buildReadingBar(c, readingProvider),
          // 消息列表
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: _buildBgGradient(isDark, scheme),
              ),
              child: session == null || session.messages.isEmpty
                  ? _buildEmptyState(isDark, c, readingProvider, scheme)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: session.messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: session.messages[index],
                          avatarUser: settings.avatarUser,
                          avatarXia: settings.avatarXia,
                          userBubbleColor: chatProvider.currentScheme.userBubbleColorObj,
                          xiaBubbleColor: chatProvider.currentScheme.xiaBubbleColorObj,
                          primaryColor: chatProvider.currentScheme.primaryColorObj,
                          onDelete: () => chatProvider.deleteMessage(index),
                          onRegenerate: () {
                            if (session.messages.length > index + 1) {
                              final userMsg = session.messages[index - 1];
                              chatProvider.deleteMessage(index + 1);
                              chatProvider.sendMessage(userMsg.content);
                            }
                          },
                          onRead: () {
                            // 朗读——先空着
                          },
                          onEdit: () {},
                          onFavorite: () {},
                          onShare: () {},
                        );
                      },
                    ),
            ),
          ),
          // Loading
          chatProvider.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const SizedBox.shrink(),
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

  // ---- 阅读状态栏 ----
  Widget _buildReadingBar(MoonlitTheme c, ReadingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.accentLight,
        border: Border(bottom: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_stories_rounded, size: 16, color: c.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              provider.progressText,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.accent),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          _MiniBtn(icon: Icons.chevron_left_rounded, onTap: provider.hasPrev ? provider.prevChapter : null, c: c),
          const SizedBox(width: 2),
          _MiniBtn(icon: Icons.chevron_right_rounded, onTap: provider.hasNext ? provider.nextChapter : null, c: c),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              provider.stopReading();
              context.read<ChatProvider>().sendSystemMessage('已退出阅读模式～📖');
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 16, color: c.accent),
            ),
          ),
        ],
      ),
    );
  }

  // ---- 空状态 ----
  Widget _buildEmptyState(bool isDark, MoonlitTheme c, ReadingProvider readingProvider, ThemeScheme scheme) {
    if (readingProvider.isReading && readingProvider.currentChapter != null) {
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
                color: c.accentLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                readingProvider.progressText,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.accent),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              ch.content,
              style: TextStyle(fontSize: 15, height: 1.8, color: c.ink),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: c.border),
          const SizedBox(height: 16),
          Text('开始与遐对话', style: TextStyle(fontSize: 18, color: c.inkSec)),
          const SizedBox(height: 8),
          Text('在下方输入消息，点击发送', style: TextStyle(fontSize: 14, color: c.border)),
        ],
      ),
    );
  }

  // ---- 背景渐变 ----
  RadialGradient _buildBgGradient(bool isDark, ThemeScheme scheme) {
    final bg = isDark ? scheme.darkBgColorObj : scheme.bgColorObj;
    final center = isDark
        ? Color.lerp(bg, Colors.white, 0.06)!
        : Color.lerp(bg, Colors.white, 0.12)!;
    return RadialGradient(
      center: Alignment.center,
      radius: 1.3,
      colors: [center, bg],
      stops: const [0.0, 1.0],
    );
  }

  // ---- 会话抽屉 ----
  Widget _buildSessionDrawer(BuildContext context, bool isDark, MoonlitTheme c, ChatProvider provider, ThemeScheme scheme) {
    return Drawer(
      backgroundColor: c.paper,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: c.accentLight,
                        child: Text('遐', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c.accent)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('遐悦', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c.ink)),
                          Text('小满 & 遐', style: TextStyle(fontSize: 13, color: c.inkSec)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () { provider.newSession(); Navigator.pop(context); },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('新建对话'),
                      style: TextButton.styleFrom(
                        backgroundColor: c.accentLight,
                        foregroundColor: c.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        final result = await Navigator.pushNamed(context, '/book');
                        if (result != null && context.mounted) {
                          // 用户从书库选了书，传入聊天作为引用
                        }
                      },
                      icon: const Icon(Icons.auto_stories_rounded, size: 18),
                      label: const Text('我的书库'),
                      style: TextButton.styleFrom(
                        backgroundColor: c.warm.withValues(alpha: 0.3),
                        foregroundColor: c.warm,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.border),
            Expanded(
              child: provider.sessions.isEmpty
                  ? Center(child: Text('暂无对话', style: TextStyle(color: c.inkSec)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.sessions.length,
                      itemBuilder: (context, index) {
                        final session = provider.sessions[index];
                        final isActive = session.id == provider.currentSession?.id;
                        return ListTile(
                          selected: isActive,
                          selectedTileColor: c.accentLight,
                          leading: Icon(
                            Icons.chat_rounded, size: 20,
                            color: isActive ? c.accent : c.inkSec,
                          ),
                          title: Text(
                            session.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              color: c.ink,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            session.lastMessagePreview,
                            style: TextStyle(fontSize: 12, color: c.inkSec),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onTap: () {
                            provider.switchSession(session.id);
                            Navigator.pop(context);
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline_rounded, size: 18, color: c.inkSec),
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

// ---- 迷你按钮 ----
class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final MoonlitTheme c;
  const _MiniBtn({required this.icon, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: enabled ? c.accentLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: enabled ? c.accent : c.border),
      ),
    );
  }
}
