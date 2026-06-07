import 'package:flutter/material.dart';
import '../models/moonlit_colors.dart';
import '../components/circle_button.dart';
import '../components/page_dots.dart';

class _Card {
  final String title; final String badge; final String desc; final String preview; final String date;
  bool expanded;
  _Card({required this.title, required this.badge, required this.desc, required this.preview, required this.date, this.expanded = false});
}

final _cards = [
  _Card(title: '月下窗·初版', badge: '链接', desc: '第一次做的窗台和月亮预览，日间灰米配色定版时的样子', preview: '🌙 推开窗 → 月下窗（聊天·书库·日记·待办）', date: '遐 · 2025.6.5'),
  _Card(title: '窗台花园', badge: 'HTML', desc: '底部小狗小猫装饰SVG，遐照着豆包AI的图一笔一笔画出来的', preview: '<path class="deco-line" d="M88 58 Q86 80 92 92..." />', date: '遐 · 2025.6.6'),
  _Card(title: '日记本雏形', badge: '链接', desc: '双标签日记+详情页的HTML预览，「月光正好」「和遐商量月下窗」', preview: '📖 一起 · 遐 · 小满 | 三条日记故事线', date: '遐 · 2025.6.6'),
  _Card(title: '待办清单', badge: 'HTML', desc: '方框勾选的待办列表，进行中/已完成分类，带标签', preview: '☐ 写小月亮的日记代码 · ☑ 配色定版', date: '遐 · 2025.6.6'),
];

class EchoWallPage extends StatefulWidget {
  const EchoWallPage({super.key});
  @override
  State<EchoWallPage> createState() => _EchoWallPageState();
}

class _EchoWallPageState extends State<EchoWallPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = MoonlitColors.forMode(isDark);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleButton(icon: Icons.arrow_back_ios_new_rounded, color: c.inkSec, bg: c.paper, border: c.border, onTap: () => Navigator.pop(context)),
                  Text('回 音 墙', style: TextStyle(fontFamily: 'Noto Serif SC', fontSize: 17, fontWeight: FontWeight.w700, color: c.ink, letterSpacing: 1)),
                  const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _cards.length,
                  itemBuilder: (_, i) {
                    final card = _cards[i];
                    final isCode = card.badge == 'HTML';
                    return GestureDetector(
                      onTap: () => setState(() => card.expanded = !card.expanded),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: c.paper,
                          borderRadius: BorderRadius.circular(14),
                          border: Border(left: BorderSide(color: c.warm, width: 3)),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06), blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(card.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isCode ? (isDark ? const Color(0xFF3A4A5A) : const Color(0xFFE8E0D4)) : c.accentLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(card.badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isCode ? (isDark ? const Color(0xFFC8D8E8) : const Color(0xFF7A6A58)) : c.accent)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(card.desc, style: TextStyle(fontSize: 12, color: c.inkSec, height: 1.5)),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
                              constraints: BoxConstraints(maxHeight: card.expanded ? 200 : 32),
                              child: SingleChildScrollView(
                                child: Text(card.preview, style: TextStyle(fontSize: 11, color: c.inkSec, fontFamily: 'monospace', height: 1.4)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(card.date, style: TextStyle(fontSize: 10, color: c.border, letterSpacing: 0.3)),
                                Text(card.expanded ? '收起 ↕' : '点我展开 ↕', style: TextStyle(fontSize: 10, color: c.warm)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              PageDots(count: 5, active: 4, accent: c.accent, border: c.border),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

