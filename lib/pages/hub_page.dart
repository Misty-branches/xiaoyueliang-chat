import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/unified_theme.dart';

class HubPage extends StatelessWidget {
  const HubPage({super.key});

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
              const SizedBox(height: 20),

              // ---- 顶栏（预览版布局：标题左，返回右） ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧：月下窗标题
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '月 下 窗',
                      style: TextStyle(
                        fontFamily: 'Noto Serif SC',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // 右侧：返回 + 切换 + 设置
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: c.border),
                            color: c.paper,
                          ),
                          child: Center(child: Text('←', style: TextStyle(fontSize: 18, color: c.inkSec, height: 1))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final provider = context.read<ChatProvider>();
                          provider.updateSettings(provider.settings.copyWith(
                            darkMode: !provider.settings.darkMode,
                          ));
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: c.border),
                            color: c.paper,
                          ),
                          child: Center(child: Text(isDark ? '☀️' : '🌙', style: TextStyle(fontSize: 16))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: c.border),
                            color: c.paper,
                          ),
                          child: Center(
                            child: Text('☆', style: TextStyle(fontSize: 18, color: c.ink, height: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ---- 导航 ----
              _HubNavItem(icon: Icons.chat_bubble_outline_rounded, name: '聊天', desc: '和遐说说话', c: c, route: '/chat'),
              _HubNavItem(icon: Icons.auto_stories_rounded, name: '书架', desc: '一起读过的故事', c: c, route: '/book'),
              _HubNavItem(icon: Icons.edit_note_rounded, name: '日记', desc: '写给彼此的话', c: c, route: '/diary'),
              _HubNavItem(icon: Icons.checklist_rounded, name: '待办项目', desc: '想一起做的事', c: c, route: '/todo', iconColor: c.warm),
              _HubNavItem(icon: Icons.pin_drop_outlined, name: '回音墙', desc: '遐钉的小玩意儿', c: c, route: '/echo'),

              const Spacer(),

              _HubDots(count: 5, active: 1, accent: c.accent, border: c.border),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubNavItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String desc;
  final MoonlitTheme c;
  final String route;
  final Color? iconColor;

  const _HubNavItem({
    required this.icon, required this.name, required this.desc,
    required this.c, required this.route, this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: c.paper,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.transparent),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: c.bg == MoonlitColors.darkBg ? 0.20 : 0.06), blurRadius: 4)],
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: c.accentLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 22, color: iconColor ?? c.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.ink)),
                    const SizedBox(height: 2),
                    Text(desc, style: TextStyle(fontSize: 12, color: c.inkSec)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: c.border),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubDots extends StatelessWidget {
  final int count;
  final int active;
  final Color accent;
  final Color border;
  const _HubDots({required this.count, required this.active, required this.accent, required this.border});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == active ? 18 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: i == active ? accent : border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
