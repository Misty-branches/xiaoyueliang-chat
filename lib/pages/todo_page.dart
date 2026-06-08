     1|import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
     2|import 'package:provider/provider.dart';
     3|import '../models/unified_theme.dart';
     4|import '../models/todo_item.dart';
     5|import '../stores/todo_store.dart';
     6|import '../components/circle_button.dart';
     7|import '../components/page_dots.dart';
     8|
     9|const _initialItems = [
    10|  TodoItem(title: '写小月亮的日记代码', desc: '把日记+待办预览缝进Flutter里编译成APK', tag: '遐'),
    11|  TodoItem(title: '看《人间草木》第二章', desc: '今天读到「葡萄月令」那篇', tag: '小满'),
    12|  TodoItem(title: '选定倒计时墙的模板', desc: '在网站上找几个好看的样式一起挑', tag: '一起'),
    13|  TodoItem(title: '月下窗配色定版', desc: '日间灰米低饱和 + 夜间亮蓝高饱和，月亮日间哑金夜间亮金', tag: '一起', done: true),
    14|  TodoItem(title: '把微信通道跑通', desc: 'Hermes Gateway接微信，消息收发正常', tag: '遐', done: true),
    15|];
    16|
    17|class TodoPage extends StatefulWidget {
    18|  const TodoPage({super.key});
    19|  @override
    20|  State<TodoPage> createState() => _TodoPageState();
    21|}
    22|
    23|class _TodoPageState extends State<TodoPage> {
    24|  @override
    25|  void initState() {
    26|    super.initState();
    27|    WidgetsBinding.instance.addPostFrameCallback((_) {
    28|      final store = context.read<TodoStore>();
    29|      if (store.items.isEmpty) {
    30|        store.load(_initialItems);
    31|      }
    32|    });
    33|  }
    34|
    35|  @override
    36|  Widget build(BuildContext context) {
    37|    final isDark = Theme.of(context).brightness == Brightness.dark;
    38|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    39|    final store = context.watch<TodoStore>();
    40|    final pending = store.pending;
    41|    final done = store.done;
    42|
    43|    return Scaffold(
    44|      backgroundColor: c.bg,
    45|      body: SafeArea(
    46|        child: Padding(
    47|          padding: const EdgeInsets.symmetric(horizontal: 20),
    48|          child: Column(
    49|            children: [
    50|              const SizedBox(height: 16),
    51|              Row(
    52|                mainAxisAlignment: MainAxisAlignment.spaceBetween,
    53|                children: [
    54|                  CircleButton(icon: Icons.arrow_back_ios_new_rounded, color: c.inkSec, bg: c.paper, border: c.border, onTap: () => Navigator.pop(context)),
    55|                  Text('待 办 项 目', style: TextStyle(fontFamily: 'Noto Serif SC', fontSize: 17, fontWeight: FontWeight.w700, color: c.ink, letterSpacing: 1)),
    56|                  CircleButton(icon: Icons.edit_note_rounded, color: c.inkSec, bg: c.paper, border: c.border, onTap: () {}),
    57|                ],
    58|              ),
    59|              const SizedBox(height: 20),
    60|              Expanded(
    61|                child: ListView(
    62|                  children: [
    63|                    _SecHdr(title: '进行中', count: pending.length, c: c),
    64|                    ...pending.asMap().entries.map((e) => _TodoCard(
    65|                      item: e.value,
    66|                      idx: store.items.indexOf(e.value),
    67|                      c: c,
    68|                      onTap: () => store.toggle(store.items.indexOf(e.value)),
    69|                    )),
    70|                    if (done.isNotEmpty) ...[
    71|                      const SizedBox(height: 8),
    72|                      _SecHdr(title: '已完成', count: done.length, c: c),
    73|                      ...done.asMap().entries.map((e) => _TodoCard(
    74|                        item: e.value,
    75|                        idx: store.items.indexOf(e.value),
    76|                        c: c,
    77|                        onTap: () => store.toggle(store.items.indexOf(e.value)),
    78|                      )),
    79|                    ],
    80|                  ],
    81|                ),
    82|              ),
    83|              PageDots(count: 4, active: 3, accent: c.accent, border: c.border),
    84|              const SizedBox(height: 16),
    85|            ],
    86|          ),
    87|        ),
    88|      ),
    89|    );
    90|  }
    91|}
    92|
    93|class _SecHdr extends StatelessWidget {
    94|  final String title; final int count; final MoonlitTheme c;
    95|  const _SecHdr({required this.title, required this.count, required this.c});
    96|  @override
    97|  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Row(children: [Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.inkSec, letterSpacing: 0.5)), const SizedBox(width: 6), Text('$count', style: TextStyle(fontSize: 10, color: c.border))]));
    98|}
    99|
   100|class _TodoCard extends StatelessWidget {
   101|  final TodoItem item; final int idx; final MoonlitTheme c; final VoidCallback onTap;
   102|  const _TodoCard({required this.item, required this.idx, required this.c, required this.onTap});
   103|
   104|  Color _tagBg() => switch (item.tag) { '遐' => c.accentLight, '小满' => c.warm.withValues(alpha: 0.7), _ => c.warm.withValues(alpha: 0.6) };
   105|  Color _tagFg() => switch (item.tag) { '遐' => c.accent, _ => c.ink };
   106|
   107|  @override
   108|  Widget build(BuildContext context) {
   109|    return Container(
   110|      margin: const EdgeInsets.only(bottom: 8),
   111|      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
   112|      decoration: BoxDecoration(color: c.paper, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: c.isDark ? 0.20 : 0.06), blurRadius: 4)]),
   113|      child: Row(
   114|        crossAxisAlignment: CrossAxisAlignment.start,
   115|        children: [
   116|          GestureDetector(
   117|            onTap: onTap,
   118|            child: Container(
   119|              width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
   120|              decoration: BoxDecoration(
   121|                color: item.done ? c.accent : Colors.transparent,
   122|                borderRadius: BorderRadius.circular(4),
   123|                border: Border.all(color: item.done ? c.accent : c.border, width: item.done ? 0 : 2),
   124|              ),
   125|              child: item.done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
   126|            ),
   127|          ),
   128|          const SizedBox(width: 12),
   129|          Expanded(
   130|            child: Column(
   131|              crossAxisAlignment: CrossAxisAlignment.start,
   132|              children: [
   133|                Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: item.done ? c.inkSec : c.ink, decoration: item.done ? TextDecoration.lineThrough : null)),
   134|                if (item.desc.isNotEmpty) const SizedBox(height: 2),
   135|                if (item.desc.isNotEmpty) Text(item.desc, style: TextStyle(fontSize: 12, color: c.inkSec, height: 1.4)),
   136|              ],
   137|            ),
   138|          ),
   139|          const SizedBox(width: 8),
   140|          Container(
   141|            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
   142|            decoration: BoxDecoration(color: _tagBg(), borderRadius: BorderRadius.circular(4)),
   143|            child: Text(item.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _tagFg())),
   144|          ),
   145|        ],
   146|      ),
   147|    );
   148|  }
   149|}
   150|