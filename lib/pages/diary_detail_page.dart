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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.border), color: c.paper), child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: c.inkSec)),
                  ),
                  const SizedBox(width: 36), const SizedBox(width: 36),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(color: c.paper, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 14, 0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.border)), child: Icon(Icons.close_rounded, size: 14, color: c.inkSec)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.title, style: TextStyle(fontFamily: 'Noto Serif SC', fontSize: 22, fontWeight: FontWeight.w700, color: c.ink, height: 1.3)),
                              const SizedBox(height: 10),
                              Row(children: [
                                Text(entry.mood, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8), Text(entry.weather, style: TextStyle(fontSize: 13, color: c.inkSec)),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('·', style: TextStyle(color: c.border))),
                                Text(entry.feeling, style: TextStyle(fontSize: 13, color: c.accent, fontWeight: FontWeight.w500)),
                              ]),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: CustomPaint(size: const Size(double.infinity, 1), painter: _DashedLine(color: c.border)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          child: _buildBody(entry.body, c),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${entry.author} · ${entry.date}', style: TextStyle(fontSize: 11, color: c.inkSec)),
                              Text('☕ 读完', style: TextStyle(fontSize: 11, color: c.inkSec)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == 2 ? 18 : 5, height: 5,
                    decoration: BoxDecoration(color: i == 2 ? c.accent : c.border, borderRadius: BorderRadius.circular(3)),
                  )),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(String text, MoonlitTheme c) {
    final paras = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paras.map((para) {
        final hl = para.contains('水在') || para.contains('不是设计') || para.contains('我的第一');
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            para,
            style: TextStyle(
              fontSize: 14, color: c.ink, height: 1.8, letterSpacing: 0.3,
              backgroundColor: hl ? c.warm.withValues(alpha: c.isDark ? 0.15 : 0.25) : null,
            ),
          ),
        );
      }).toList(),
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
