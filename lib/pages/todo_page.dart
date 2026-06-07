import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/moonlit_colors.dart';
import '../models/todo_item.dart';
import '../stores/todo_store.dart';
import '../components/circle_button.dart';
import '../components/page_dots.dart';

const _initialItems = [
  TodoItem(title: '写小月亮的日记代码', desc: '把日记+待办预览缝进Flutter里编译成APK', tag: '遐'),
  TodoItem(title: '看《人间草木》第二章', desc: '今天读到「葡萄月令」那篇', tag: '小满'),
  TodoItem(title: '选定倒计时墙的模板', desc: '在网站上找几个好看的样式一起挑', tag: '一起'),
  TodoItem(title: '月下窗配色定版', desc: '日间灰米低饱和 + 夜间亮蓝高饱和，月亮日间哑金夜间亮金', tag: '一起', done: true),
  TodoItem(title: '把微信通道跑通', desc: 'Hermes Gateway接微信，消息收发正常', tag: '遐', done: true),
];

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<TodoStore>();
      if (store.items.isEmpty) {
        store.load(_initialItems);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = MoonlitColors.forMode(isDark);
    final store = context.watch<TodoStore>();
    final pending = store.pending;
    final done = store.done;

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
                  Text('待 办 项 目', style: TextStyle(fontFamily: 'Noto Serif SC', fontSize: 17, fontWeight: FontWeight.w700, color: c.ink, letterSpacing: 1)),
                  CircleButton(icon: Icons.edit_note_rounded, color: c.inkSec, bg: c.paper, border: c.border, onTap: () {}),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _SecHdr(title: '进行中', count: pending.length, c: c),
                    ...pending.asMap().entries.map((e) => _TodoCard(
                      item: e.value,
                      idx: store.items.indexOf(e.value),
                      c: c,
                      onTap: () => store.toggle(store.items.indexOf(e.value)),
                    )),
                    if (done.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _SecHdr(title: '已完成', count: done.length, c: c),
                      ...done.asMap().entries.map((e) => _TodoCard(
                        item: e.value,
                        idx: store.items.indexOf(e.value),
                        c: c,
                        onTap: () => store.toggle(store.items.indexOf(e.value)),
                      )),
                    ],
                  ],
                ),
              ),
              PageDots(count: 4, active: 3, accent: c.accent, border: c.border),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecHdr extends StatelessWidget {
  final String title; final int count; final MoonlitTheme c;
  const _SecHdr({required this.title, required this.count, required this.c});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Row(children: [Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.inkSec, letterSpacing: 0.5)), const SizedBox(width: 6), Text('$count', style: TextStyle(fontSize: 10, color: c.border))]));
}

class _TodoCard extends StatelessWidget {
  final TodoItem item; final int idx; final MoonlitTheme c; final VoidCallback onTap;
  const _TodoCard({required this.item, required this.idx, required this.c, required this.onTap});

  Color _tagBg() => switch (item.tag) { '遐' => c.accentLight, '小满' => c.warm.withValues(alpha: 0.7), _ => c.warm.withValues(alpha: 0.6) };
  Color _tagFg() => switch (item.tag) { '遐' => c.accent, _ => c.ink };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: c.paper, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: c.bg == MoonlitColors.darkBg ? 0.20 : 0.06), blurRadius: 4)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: item.done ? c.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: item.done ? c.accent : c.border, width: item.done ? 0 : 2),
              ),
              child: item.done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: item.done ? c.inkSec : c.ink, decoration: item.done ? TextDecoration.lineThrough : null)),
                if (item.desc.isNotEmpty) const SizedBox(height: 2),
                if (item.desc.isNotEmpty) Text(item.desc, style: TextStyle(fontSize: 12, color: c.inkSec, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(color: _tagBg(), borderRadius: BorderRadius.circular(4)),
            child: Text(item.tag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _tagFg())),
          ),
        ],
      ),
    );
  }
}
