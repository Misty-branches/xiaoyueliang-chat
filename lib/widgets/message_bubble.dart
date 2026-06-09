import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../models/unified_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onRegenerate;
  final VoidCallback? onRead;
  final VoidCallback? onEdit;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final String avatarUser;
  final String avatarXia;
  final Color userBubbleColor;
  final Color xiaBubbleColor;
  final Color primaryColor;

  const MessageBubble({
    super.key,
    required this.message,
    this.onCopy,
    this.onDelete,
    this.onRegenerate,
    this.onRead,
    this.onEdit,
    this.onFavorite,
    this.onShare,
    this.avatarUser = '',
    this.avatarXia = '',
    this.userBubbleColor = const Color(0xFFD8E2EC),
    this.xiaBubbleColor = const Color(0xFFECE9E3),
    this.primaryColor = const Color(0xFF5A7A94),
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isSystem = message.role == 'system';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width * 0.82;

    if (isSystem) {
      return _buildSystemMessage(isDark, theme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onLongPress: () => _showMessageMenu(context, isDark),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: isUser
                ? _buildUserBubble(theme, isDark, maxWidth)
                : _buildXiaBubble(theme, isDark, maxWidth),
          ),
        ),
        _buildActionBar(context, isDark, isUser),
      ],
    );
  }

  /// 用户消息气泡：右对齐 + 方案色
  Widget _buildUserBubble(ThemeData theme, bool isDark, double maxWidth) {
    final textColor = isDark ? Colors.grey.shade200 : Colors.black87;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? userBubbleColor.withValues(alpha: 0.55) : userBubbleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.5),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _buildAvatar(
            base64Str: avatarUser,
            fallbackText: '满',
            bgColor: primaryColor.withValues(alpha: 0.3),
            textColor: primaryColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  /// 遐消息气泡：左对齐 + 方案色
  Widget _buildXiaBubble(ThemeData theme, bool isDark, double maxWidth) {
    final textColor = isDark ? Colors.grey.shade200 : Colors.black87;
    final bubbleColor = isDark ? xiaBubbleColor.withValues(alpha: 0.4) : xiaBubbleColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: _buildAvatar(
            base64Str: avatarXia,
            fallbackText: '遐',
            bgColor: primaryColor.withValues(alpha: 0.3),
            textColor: primaryColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: textColor, fontSize: 15, height: 1.5),
                code: TextStyle(
                  backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                h1: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                h2: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold),
                h3: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                a: TextStyle(color: primaryColor),
                blockquoteDecoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      width: 3,
                    ),
                  ),
                ),
                listBullet: TextStyle(color: textColor),
                tableBorder: TableBorder.all(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
                tableHead: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 头像组件：有 base64 就显示图片，否则文字
  Widget _buildAvatar({
    required String base64Str,
    required String fallbackText,
    required Color bgColor,
    required Color textColor,
    required bool isDark,
  }) {
    if (base64Str.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 16,
          backgroundImage: MemoryImage(base64Decode(base64Str)),
        );
      } catch (_) {
        // base64 解析失败，降级到文字
      }
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: bgColor,
      child: Text(
        fallbackText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  // ── 以下方法保持不变（操作栏、菜单、时间戳） ──

  Widget _buildActionBar(BuildContext context, bool isDark, bool isUser) {
    final iconSize = 18.0;
    final iconColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    final actionRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.content_copy_outlined,
          size: iconSize,
          color: iconColor,
          onTap: () {
            Clipboard.setData(ClipboardData(text: message.content));
            ScaffoldMessenger.of(context).showSnackBar(
              _buildSnackBar('已复制', isDark, context),
            );
          },
        ),
        const SizedBox(width: 16),
        if (!isUser)
          _ActionButton(
            icon: Icons.refresh_outlined,
            size: iconSize,
            color: iconColor,
            onTap: onRegenerate,
          ),
        if (!isUser) const SizedBox(width: 16),
        if (!isUser)
          _ActionButton(
            icon: Icons.volume_up_outlined,
            size: iconSize,
            color: iconColor,
            onTap: onRead,
          ),
        if (!isUser) const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.more_horiz_outlined,
          size: iconSize,
          color: iconColor,
          onTap: () => _showMessageMenu(context, isDark),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 2),
      child: isUser
          ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [actionRow])
          : Padding(
              padding: const EdgeInsets.only(left: 56),
              child: actionRow,
            ),
    );
  }

  Widget _ActionButton({
    required IconData icon,
    required double size,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  void _showMessageMenu(BuildContext context, bool isDark) {
    final c = UnifiedTheme.moonlit.forMode(isDark);
    final bgColor = c.surface;
    final cardColor = c.paper;
    final textColor = c.ink;
    final iconColor = c.inkSec;
    final deleteColor = const Color(0xFFE88080);
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _MenuCard(
                icon: Icons.edit_outlined,
                label: '编辑',
                iconColor: iconColor,
                textColor: textColor,
                cardColor: cardColor,
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              const SizedBox(height: 6),
              _MenuCard(
                icon: Icons.favorite_border_rounded,
                label: '收藏',
                iconColor: iconColor,
                textColor: textColor,
                cardColor: cardColor,
                onTap: () {
                  Navigator.pop(context);
                  onFavorite?.call();
                },
              ),
              const SizedBox(height: 6),
              _MenuCard(
                icon: Icons.share_outlined,
                label: '分享',
                iconColor: iconColor,
                textColor: textColor,
                cardColor: cardColor,
                onTap: () {
                  Navigator.pop(context);
                  onShare?.call();
                },
              ),
              const SizedBox(height: 6),
              Divider(height: 1, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              const SizedBox(height: 6),
              _MenuCard(
                icon: Icons.delete_outline_rounded,
                label: '删除',
                iconColor: deleteColor,
                textColor: deleteColor,
                cardColor: deleteColor.withValues(alpha: 0.08),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _MenuCard({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color textColor,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return '';
    final months = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
    final m = months[dt.month - 1];
    final d = dt.day.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? '上午' : '下午';
    final h12 = dt.hour > 12 ? (dt.hour - 12).toString() : dt.hour.toString();
    return '${dt.year}年${m}月${d}日 $ampm${h12}:${min}';
  }

  SnackBar _buildSnackBar(String text, bool isDark, BuildContext context) {
    return SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade700,
    );
  }

  Widget _buildSystemMessage(bool isDark, ThemeData theme) {
    final isReading = message.content.startsWith('📖');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isReading
              ? primaryColor.withValues(alpha: 0.15)
              : (isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isReading
                ? primaryColor.withValues(alpha: 0.3)
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
                  color: isReading ? primaryColor : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                Text(
                  isReading ? '阅读' : '系统',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isReading ? primaryColor : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
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
