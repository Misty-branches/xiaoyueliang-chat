import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onRegenerate;
  final VoidCallback? onRead;
  final VoidCallback? onEdit;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

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
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    final isSystem = message.role == 'system';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 系统消息（阅读内容等）居中显示
    if (isSystem) {
      return _buildSystemMessage(isDark);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 消息气泡本体（长按弹出菜单）
        GestureDetector(
          onLongPress: () => _showMessageMenu(context, isDark),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: isUser
                // ── 用户消息：右对齐，气泡自适应内容宽度 ──
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.82,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.blue.shade700 : Colors.blue.shade500,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            message.content,
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: CircleAvatar(
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
                      ),
                    ],
                  )
                // ── 遐的消息：左对齐，头像+气泡自适应 ──
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              isDark ? Colors.blueGrey.shade700 : Colors.blue.shade50,
                          child: Text(
                            '遐',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.blueGrey.shade200 : Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.82,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
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
                    ],
                  ),
          ),
        ),
        // ── 操作栏（消息下方） ──
        _buildActionBar(context, isDark, isUser),
      ],
    );
  }

  /// 操作栏：复制 | 重生成 | 朗读 | ⋮更多
  Widget _buildActionBar(BuildContext context, bool isDark, bool isUser) {
    // 操作栏左对齐（与气泡对齐）
    final iconSize = 18.0;
    final iconColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 12 : 56,   // 用户消息：12；遐消息：头像(32)+间距(8)+12
        right: 12,
        bottom: 2,
      ),
      child: Row(
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
      ),
    );
  }

  /// 操作栏小按钮
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

  /// ── 更多菜单（底部弹出） ──
  void _showMessageMenu(BuildContext context, bool isDark) {
    final bgColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF2F4F7);
    final cardColor = isDark ? const Color(0xFF3A3A3A) : Colors.white;
    final textColor = isDark ? Colors.grey.shade200 : Colors.black87;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
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
              // 拖拽条
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 菜单项卡片
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
              // 分隔线
              Divider(height: 1, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
              const SizedBox(height: 6),
              // 删除（粉色警示）
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
              // 时间戳信息
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

  /// 菜单项卡片
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

  /// 格式化时间戳
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
