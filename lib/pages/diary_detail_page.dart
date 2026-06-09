import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/unified_theme.dart';
import '../models/diary_entry.dart';

class DiaryDetailPage extends StatelessWidget {
  const DiaryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entry = ModalRoute.of(context)?.settings.arguments as DiaryEntry?;
    if (entry == null) {
      return Scaffold(body: Center(child: Text('未找到日记')));
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 返回按钮
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border, width: 1.5),
                    color: c.paper,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: c.inkSec),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.paper,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: c.shadow,
                          blurRadius: 16,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          Text(
                            entry.title,
                            style: TextStyle(
                              fontFamily: 'Noto Serif SC',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: c.ink,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // 元信息：心情 · 天气 · 感受
                          Row(children: [
                            Text(entry.mood, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(entry.weather, style: TextStyle(fontSize: 13, color: c.inkSec)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('·', style: TextStyle(color: c.border)),
                            ),
                            Text(entry.feeling, style: TextStyle(fontSize: 13, color: c.accent, fontWeight: FontWeight.w500)),
                          ]),
                          const SizedBox(height: 12),
                          // 虚线分隔
                          CustomPaint(
                            size: const Size(double.infinity, 1),
                            painter: _DashedLine(color: c.border),
                          ),
                          const SizedBox(height: 16),
                          // 正文
                          Text(
                            entry.body,
                            style: TextStyle(
                              fontSize: 14,
                              color: c.ink,
                              height: 1.8,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 底部信息
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${entry.author} · ${entry.date}', style: TextStyle(fontSize: 11, color: c.inkSec)),
                              Text('☕ 读完', style: TextStyle(fontSize: 11, color: c.inkSec)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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

class _DashedLine extends CustomPainter {
  final Color color;
  _DashedLine({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + 6).clamp(0, size.width), 0), paint);
      x += 10;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
