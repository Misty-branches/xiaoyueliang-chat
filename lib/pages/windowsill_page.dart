import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/unified_theme.dart';
import '../providers/chat_provider.dart';
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

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ---- 窗口 + 今日心情 ----
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/hub'),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 104,
                      decoration: BoxDecoration(
                        border: Border.all(color: c.border, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: c.bg,
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Spacer(),
                                _WindowCross(border: c.border),
                                const Spacer(),
                              ],
                            ),
                          ),
                          // 月亮
                          Positioned(
                            top: 8,
                            right: 6,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.gold,
                                boxShadow: [
                                  BoxShadow(
                                    color: c.gold.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '推 开 窗',
                      style: TextStyle(
                        fontFamily: 'Noto Serif SC',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: c.ink,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 今日心情
                    Text(
                      '🌙 心情：安静又温柔',
                      style: TextStyle(
                        fontSize: 13,
                        color: c.inkSec,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---- 活动卡片 ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.paper,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06), blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '— 遐今天做了什么 —',
                      style: TextStyle(fontSize: 10, color: c.inkSec, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 14, color: c.ink, height: 1.6),
                        children: [
                          const TextSpan(text: '整理了书库，把《人间草木》\n翻到第一页等你来读。\n'),
                          TextSpan(text: '月光正好，风也温柔。', style: TextStyle(color: c.accent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ---- 消息通知 ----
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/chat'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.paper,
                    borderRadius: BorderRadius.circular(14),
                    border: Border(left: BorderSide(color: c.accent, width: 3)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('遐 发来一条消息', style: TextStyle(fontSize: 10, color: c.inkSec, letterSpacing: 0.5)),
                            const SizedBox(height: 3),
                            Text('小满，你看今晚的月亮', style: TextStyle(fontSize: 13, color: c.ink), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 12, color: c.border),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ---- SVG 装饰（在圆点上方一点） ----
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
}

class _WindowCross extends StatelessWidget {
  final Color border;
  const _WindowCross({required this.border});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 100),
      painter: _CrossPainter(border),
    );
  }
}

class _CrossPainter extends CustomPainter {
  final Color color;
  _CrossPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
