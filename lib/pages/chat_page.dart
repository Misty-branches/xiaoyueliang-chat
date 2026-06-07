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

  String _formatDate(DateTime dt) {
    final days = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return '${dt.month}月${dt.day}日 ${days[dt.weekday - 1]}';
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
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: _buildBgGradient(isDark, c),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(height: topInset > 0 ? topInset : 8),

              // ===== 顶栏 =====
              _buildHeader(c),

              // ===== 聊天卡片 =====
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  decoration: BoxDecoration(
                    color: c.paper,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: c.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      // 消息列表
                      Expanded(
                        child: session == null || session.messages.isEmpty
                            ? _buildEmptyState(isDark, c, readingProvider, scheme)
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: session.messages.length,
                                itemBuilder: (context, index) {
                                  final msg = session.messages[index];

                                  // 日期分割
                                  final widgets = <Widget>[];
                                  if (index == 0 || _isNewDay(session.messages[index - 1].timestamp, msg.timestamp)) {
                                    widgets.add(
                                      _buildDateDivider(
                                        _formatDate(msg.timestamp),
                                        c,
                                      ),
                                    );
                                  }

                                  widgets.add(MessageBubble(
                                    message: msg,
                                    avatarUser: settings.avatarUser,
                                    avatarXia: settings.avatarXia,
                                    userBubbleColor: scheme.userBubbleColorObj,
                                    xiaBubbleColor: scheme.xiaBubbleColorObj,
                                    primaryColor: scheme.primaryColorObj,
                                    onDelete: () => chatProvider.deleteMessage(index),
                                    onRegenerate: () {
                                      if (index > 0 && session.messages.length > index) {
                                        final userMsg = session.messages[index - 1];
                                        chatProvider.deleteMessage(index);
                                        chatProvider.sendMessage(userMsg.content);
                                      }
                                    },
                                    onRead: () {},
                                    onEdit: () {},
                                    onFavorite: () {},
                                    onShare: () {},
                                  ));

                                  return Column(children: widgets);
                                },
                              ),
                      ),

                      // Loading indicator
                      if (chatProvider.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),

                      // 输入区
                      InputBar(
                        isStreaming: chatProvider.isStreaming,
                        referencedBook: chatProvider.referencedBook,
                        onSend: _handleSend,
                        onCancel: () => chatProvider.cancelStreaming(),
                        onClearReference: () => chatProvider.clearReferenceBook(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== 会话抽屉（保留） =====
      drawer: _buildSessionDrawer(context, isDark, c, chatProvider, scheme),
    );
  }

  // ===== 顶栏 =====
  Widget _buildHeader(MoonlitTheme c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // X 关闭按钮（圆形描边）
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.border, width: 1.5),
                color: c.paper,
              ),
              child: Icon(Icons.close_rounded, size: 18, color: c.inkSec),
            ),
          ),
          const Spacer(),
          // 标题 + 副标题
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '小月亮 · 月下窗',
                style: TextStyle(
                  fontFamily: 'Noto Serif SC',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                ' 在线 · 月光正好',
                style: TextStyle(
                  fontSize: 11,
                  color: c.inkSec,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // ... 菜单按钮（圆形描边）
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.border, width: 1.5),
                color: c.paper,
              ),
              child: Icon(Icons.more_horiz_rounded, size: 18, color: c.inkSec),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 聊天卡片顶部的头像 + 状态 =====
  Widget _buildChatProfile(MoonlitTheme c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          // 弯月头像
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentLight,
              border: Border.all(color: c.border, width: 1),
            ),
            child: Icon(Icons.circle_rounded, size: 22, color: c.gold),
          ),
          const SizedBox(width: 10),
          // 名称 + 状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小月亮·月下窗',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '在线·月光正好',
                  style: TextStyle(
                    fontSize: 12,
                    color: c.inkSec,
                  ),
                ),
              ],
            ),
          ),
          // 右侧弯月图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.border, width: 1),
              color: c.surface,
            ),
            child: Icon(Icons.circle_rounded, size: 16, color: c.gold),
          ),
        ],
      ),
    );
  }

  // ===== 日期分割线 =====
  Widget _buildDateDivider(String text, MoonlitTheme c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: c.border, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: c.inkSec),
            ),
          ),
          Expanded(child: Divider(color: c.border, thickness: 0.5)),
        ],
      ),
    );
  }

  // ===== 空状态 =====
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
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentLight,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 32, color: c.accent),
          ),
          const SizedBox(height: 16),
          Text('开始与遐对话', style: TextStyle(fontSize: 16, color: c.ink, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('说点什么吧，月下窗开着呢', style: TextStyle(fontSize: 13, color: c.inkSec)),
        ],
      ),
    );
  }

  bool _isNewDay(DateTime? prev, DateTime? current) {
    if (prev == null || current == null) return false;
    return prev.year != current.year || prev.month != current.month || prev.day != current.day;
  }

  // ===== 背景渐变 =====
  RadialGradient _buildBgGradient(bool isDark, MoonlitTheme c) {
    return RadialGradient(
      center: Alignment.center,
      radius: 1.3,
      colors: [c.surface, c.bg],
      stops: const [0.0, 1.0],
    );
  }

  // ===== 会话抽屉 =====
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
                      icon: Icon(Icons.add_rounded, size: 18, color: c.accent),
                      label: Text('新建对话', style: TextStyle(color: c.accent)),
                      style: TextButton.styleFrom(
                        backgroundColor: c.accentLight,
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
                        if (result != null && context.mounted) {}
                      },
                      icon: Icon(Icons.auto_stories_rounded, size: 18, color: c.warm),
                      label: Text('我的书库', style: TextStyle(color: c.warm)),
                      style: TextButton.styleFrom(
                        backgroundColor: c.warm.withValues(alpha: 0.3),
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
