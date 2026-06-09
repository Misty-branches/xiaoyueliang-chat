import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unified_theme.dart';
import '../providers/chat_provider.dart';
import '../providers/windowsill_provider.dart';
import '../components/floating_decor.dart';
import '../components/page_dots.dart';

class WindowsillPage extends StatelessWidget {
  const WindowsillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    final ws = context.watch<WindowsillProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ---- 窗口 + 今日心情 ----
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/hub'),
                child: Column(
                  children: [
                    // 放大的窗户
                    Container(
                      width: 130,
                      height: 165,
                      decoration: BoxDecoration(
                        border: Border.all(color: c.border, width: 2.5),
                        borderRadius: BorderRadius.circular(16),
                        color: c.bg,
                        boxShadow: [
                          BoxShadow(
                            color: c.gold.withValues(alpha: 0.12),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // 窗格十字
                          Center(
                            child: _WindowCross(border: c.border),
                          ),
                          // 月亮（带光晕）
                          Positioned(
                            top: 16,
                            right: 14,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.gold,
                                boxShadow: [
                                  BoxShadow(
                                    color: c.gold.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                  BoxShadow(
                                    color: c.gold.withValues(alpha: 0.15),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 窗台底部阴影
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: c.border.withValues(alpha: 0.15),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // 推开窗
                    Text(
                      '推 开 窗',
                      style: TextStyle(
                        fontFamily: 'Noto Serif SC',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: c.ink,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 今日心情（动态）
                    _buildMoodBadge(c, ws),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ---- 每日一句（动态文案）----
              _buildDailyQuote(c, ws),

              const SizedBox(height: 10),

              // ---- 活动便签（日记体）----
              _buildActivityCard(c, ws),

              const SizedBox(height: 10),

              // ---- 消息通知（动态）----
              _buildLatestMessage(c, ws, context),

              const Spacer(),

              // ---- SVG 装饰（带动画）----
              FloatingDecor(
                borderColor: c.border,
                fillColor: c.border,
                fillLightColor: c.border.withValues(alpha: 0.25),
                blushColor: c.warm.withValues(alpha: 0.3),
              ),

              const SizedBox(height: 8),

              // ---- 底部圆点 ----
              PageDots(count: 4, active: 0, accent: c.accent, border: c.border),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 今日心情徽章
  Widget _buildMoodBadge(MoonlitTheme c, WindowsillProvider ws) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: c.accentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${ws.mood.emoji} 心情：${ws.mood.text}',
        style: TextStyle(
          fontSize: 13,
          color: c.inkSec,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 每日一句
  Widget _buildDailyQuote(MoonlitTheme c, WindowsillProvider ws) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ws.quote.text,
            style: TextStyle(
              fontFamily: 'Noto Serif SC',
              fontSize: 14,
              color: c.ink,
              height: 1.6,
              letterSpacing: 0.5,
            ),
          ),
          if (ws.quote.source.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '—— ${ws.quote.source}',
                style: TextStyle(
                  fontSize: 11,
                  color: c.inkSec,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 活动便签（日记体风格）
  Widget _buildActivityCard(MoonlitTheme c, WindowsillProvider ws) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: c.accent, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.isDark ? 0.25 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行：作者 + 时间
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: c.accentLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ws.note.author,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: c.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ws.note.timeLabel,
                style: TextStyle(fontSize: 10, color: c.inkSec, letterSpacing: 0.3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 便签内容（日记体）
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'Noto Serif SC',
                fontSize: 14,
                color: c.ink,
                height: 1.7,
              ),
              children: [
                TextSpan(text: ws.note.content),
                if (ws.note.moodTag.isNotEmpty)
                  TextSpan(
                    text: '\n${ws.note.moodTag}',
                    style: TextStyle(color: c.accent, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 最新消息通知
  Widget _buildLatestMessage(MoonlitTheme c, WindowsillProvider ws, BuildContext context) {
    final hasMessage = ws.latestMessage.preview.isNotEmpty && ws.latestMessage.preview != '还没有消息，去聊聊天吧~';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/chat'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: c.gold, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: c.isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 未读指示点
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasMessage ? c.gold : c.border,
                boxShadow: hasMessage
                    ? [BoxShadow(color: c.gold.withValues(alpha: 0.4), blurRadius: 6)]
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasMessage ? '${ws.latestMessage.sender} 发来一条消息' : '还没有消息',
                    style: TextStyle(fontSize: 10, color: c.inkSec, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasMessage ? ws.latestMessage.preview : '推开窗，说点什么吧',
                    style: TextStyle(fontSize: 13, color: c.ink),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: c.border),
          ],
        ),
      ),
    );
  }
}

/// 窗格十字（放大版）
class _WindowCross extends StatelessWidget {
  final Color border;
  const _WindowCross({required this.border});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(126, 161),
      painter: _CrossPainter(border),
    );
  }
}

class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    // 垂直线
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // 水平线（居中，田字格均匀）
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
