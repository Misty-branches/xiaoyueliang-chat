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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ---- 顶栏 ----
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: c.ink,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  // 右侧：切换 + 设置
                  Row(
                    children: [
                      _CircleIconBtn(
                        icon: isDark ? '☀️' : '🌙',
                        c: c,
                        onTap: () {
                          final provider = context.read<ChatProvider>();
                          provider.updateSettings(provider.settings.copyWith(
                            darkMode: !provider.settings.darkMode,
                          ));
                        },
                      ),
                      const SizedBox(width: 10),
                      _CircleIconBtn(
                        icon: '☆',
                        c: c,
                        onTap: () => Navigator.pushNamed(context, '/settings'),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // ---- 导航列表 ----
              _HubNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                name: '聊天',
                desc: '和遐说说话',
                c: c,
                route: '/chat',
              ),
              _HubNavItem(
                icon: Icons.auto_stories_rounded,
                name: '书架',
                desc: '一起读过的故事',
                c: c,
                route: '/book',
              ),
              _HubNavItem(
                icon: Icons.edit_note_rounded,
                name: '日记',
                desc: '写给彼此的话',
                c: c,
                route: '/diary',
              ),
              _HubNavItem(
                icon: Icons.checklist_rounded,
                name: '待办',
                desc: '想一起做的事',
                c: c,
                route: '/todo',
                iconColor: c.warm,
              ),
              _HubNavItem(
                icon: Icons.push_pin_outlined,
                name: '回音墙',
                desc: '遐钉的小玩意儿',
                c: c,
                route: '/echo',
              ),

              const Spacer(),

              // ---- 底部提示 ----
              Text(
                '轻触进入，长按回到窗台',
                style: TextStyle(
                  fontSize: 11,
                  color: c.inkSec.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// 圆形图标按钮
class _CircleIconBtn extends StatelessWidget {
  final String icon;
  final MoonlitTheme c;
  final VoidCallback onTap;

  const _CircleIconBtn({required this.icon, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.border.withValues(alpha: 0.5)),
          color: c.paper,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: c.isDark ? 0.20 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Text(icon, style: TextStyle(fontSize: 16))),
      ),
    );
  }
}

/// 枢纽导航项
class _HubNavItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String desc;
  final MoonlitTheme c;
  final String route;
  final Color? iconColor;

  const _HubNavItem({
    required this.icon,
    required this.name,
    required this.desc,
    required this.c,
    required this.route,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: c.paper,
            borderRadius: BorderRadius.circular(16),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.accentLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 24, color: iconColor ?? c.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(
                      fontFamily: 'Noto Serif SC',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: c.ink,
                    )),
                    const SizedBox(height: 3),
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
