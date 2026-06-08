     1|import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
     2|import 'package:provider/provider.dart';
     3|import '../models/unified_theme.dart';
     4|import '../models/echo_card.dart';
     5|import '../stores/echo_store.dart';
     6|import '../components/circle_button.dart';
     7|import '../components/page_dots.dart';
     8|
     9|const _initialCards = [
    10|  EchoCard(title: '月下窗·初版', badge: '链接', desc: '第一次做的窗台和月亮预览，日间灰米配色定版时的样子', preview: '🌙 推开窗 → 月下窗（聊天·书库·日记·待办）', date: '遐 · 2025.6.5'),
    11|  EchoCard(title: '窗台花园', badge: 'HTML', desc: '底部小狗小猫装饰SVG，遐照着豆包AI的图一笔一笔画出来的', preview: '<path class="deco-line" d="M88 58 Q86 80 92 92..." />', date: '遐 · 2025.6.6'),
    12|  EchoCard(title: '日记本雏形', badge: '链接', desc: '双标签日记+详情页的HTML预览，「月光正好」「和遐商量月下窗」', preview: '📖 一起 · 遐 · 小满 | 三条日记故事线', date: '遐 · 2025.6.6'),
    13|  EchoCard(title: '待办清单', badge: 'HTML', desc: '方框勾选的待办列表，进行中/已完成分类，带标签', preview: '☐ 写小月亮的日记代码 · ☑ 配色定版', date: '遐 · 2025.6.6'),
    14|];
    15|
    16|class EchoWallPage extends StatefulWidget {
    17|  const EchoWallPage({super.key});
    18|  @override
    19|  State<EchoWallPage> createState() => _EchoWallPageState();
    20|}
    21|
    22|class _EchoWallPageState extends State<EchoWallPage> {
    23|  @override
    24|  void initState() {
    25|    super.initState();
    26|    WidgetsBinding.instance.addPostFrameCallback((_) {
    27|      final store = context.read<EchoStore>();
    28|      if (store.cards.isEmpty) {
    29|        store.load(_initialCards);
    30|      }
    31|    });
    32|  }
    33|
    34|  @override
    35|  Widget build(BuildContext context) {
    36|    final isDark = Theme.of(context).brightness == Brightness.dark;
    37|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    38|    final store = context.watch<EchoStore>();
    39|
    40|    return Scaffold(
    41|      backgroundColor: c.bg,
    42|      body: SafeArea(
    43|        child: Padding(
    44|          padding: const EdgeInsets.symmetric(horizontal: 20),
    45|          child: Column(
    46|            children: [
    47|              const SizedBox(height: 16),
    48|              Row(
    49|                mainAxisAlignment: MainAxisAlignment.spaceBetween,
    50|                children: [
    51|                  CircleButton(icon: Icons.arrow_back_ios_new_rounded, color: c.inkSec, bg: c.paper, border: c.border, onTap: () => Navigator.pop(context)),
    52|                  Text('回 音 墙', style: TextStyle(fontFamily: 'Noto Serif SC', fontSize: 17, fontWeight: FontWeight.w700, color: c.ink, letterSpacing: 1)),
    53|                  const SizedBox(width: 36),
    54|                ],
    55|              ),
    56|              const SizedBox(height: 20),
    57|              Expanded(
    58|                child: ListView.builder(
    59|                  padding: EdgeInsets.zero,
    60|                  itemCount: store.cards.length,
    61|                  itemBuilder: (_, i) {
    62|                    final card = store.cards[i];
    63|                    final isCode = card.badge == 'HTML';
    64|                    return GestureDetector(
    65|                      onTap: () => store.toggleExpanded(i),
    66|                      child: Container(
    67|                        margin: const EdgeInsets.only(bottom: 10),
    68|                        padding: const EdgeInsets.all(16),
    69|                        decoration: BoxDecoration(
    70|                          color: c.paper,
    71|                          borderRadius: BorderRadius.circular(14),
    72|                          border: Border(left: BorderSide(color: c.warm, width: 3)),
    73|                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06), blurRadius: 4)],
    74|                        ),
    75|                        child: Column(
    76|                          crossAxisAlignment: CrossAxisAlignment.start,
    77|                          children: [
    78|                            Row(
    79|                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
    80|                              children: [
    81|                                Text(card.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.ink)),
    82|                                Container(
    83|                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
    84|                                  decoration: BoxDecoration(
    85|                                    color: isCode ? (isDark ? const Color(0xFF3A4A5A) : const Color(0xFFE8E0D4)) : c.accentLight,
    86|                                    borderRadius: BorderRadius.circular(4),
    87|                                  ),
    88|                                  child: Text(card.badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isCode ? (isDark ? const Color(0xFFC8D8E8) : const Color(0xFF7A6A58)) : c.accent)),
    89|                                ),
    90|                              ],
    91|                            ),
    92|                            const SizedBox(height: 6),
    93|                            Text(card.desc, style: TextStyle(fontSize: 12, color: c.inkSec, height: 1.5)),
    94|                            const SizedBox(height: 6),
    95|                            AnimatedContainer(
    96|                              duration: const Duration(milliseconds: 200),
    97|                              width: double.infinity,
    98|                              padding: const EdgeInsets.all(8),
    99|                              decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
   100|                              constraints: BoxConstraints(maxHeight: card.expanded ? 200 : 32),
   101|                              child: SingleChildScrollView(
   102|                                child: Text(card.preview, style: TextStyle(fontSize: 11, color: c.inkSec, fontFamily: 'monospace', height: 1.4)),
   103|                              ),
   104|                            ),
   105|                            const SizedBox(height: 6),
   106|                            Row(
   107|                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
   108|                              children: [
   109|                                Text(card.date, style: TextStyle(fontSize: 10, color: c.border, letterSpacing: 0.3)),
   110|                                Text(card.expanded ? '收起 ↕' : '点我展开 ↕', style: TextStyle(fontSize: 10, color: c.warm)),
   111|                              ],
   112|                            ),
   113|                          ],
   114|                        ),
   115|                      ),
   116|                    );
   117|                  },
   118|                ),
   119|              ),
   120|              PageDots(count: 5, active: 4, accent: c.accent, border: c.border),
   121|              const SizedBox(height: 16),
   122|            ],
   123|          ),
   124|        ),
   125|      ),
   126|    );
   127|  }
   128|}
   129|