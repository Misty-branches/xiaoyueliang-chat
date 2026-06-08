     1|import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
     2|import '../models/unified_theme.dart';
     3|import '../models/diary_entry.dart';
     4|
     5|class DiaryDetailPage extends StatelessWidget {
     6|  const DiaryDetailPage({super.key});
     7|
     8|  @override
     9|  Widget build(BuildContext context) {
    10|    final entry = ModalRoute.of(context)?.settings.arguments as DiaryEntry?;
    11|    if (entry == null) {
    12|      return Scaffold(body: Center(child: Text('未找到日记', style: TextStyle(color: c.inkSec))));
    13|    }
    14|
    15|    final isDark = Theme.of(context).brightness == Brightness.dark;
    16|    final chatProv = context.watch<ChatProvider>();
    final theme = chatProv.currentUnifiedTheme;
    final c = theme.forMode(isDark);
    17|
    18|    return Scaffold(
    19|      backgroundColor: c.bg,
    20|      body: SafeArea(
    21|        child: Padding(
    22|          padding: const EdgeInsets.symmetric(horizontal: 20),
    23|          child: Column(
    24|            crossAxisAlignment: CrossAxisAlignment.start,
    25|            children: [
    26|              const SizedBox(height: 16),
    27|              Row(
    28|                mainAxisAlignment: MainAxisAlignment.spaceBetween,
    29|                children: [
    30|                  GestureDetector(
    31|                    onTap: () => Navigator.pop(context),
    32|                    child: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.border), color: c.paper), child: Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: c.inkSec)),
    33|                  ),
    34|                  const SizedBox(width: 36), const SizedBox(width: 36),
    35|                ],
    36|              ),
    37|              const SizedBox(height: 16),
    38|              Expanded(
    39|                child: SingleChildScrollView(
    40|                  child: Container(
    41|                    decoration: BoxDecoration(color: c.paper, borderRadius: BorderRadius.circular(16)),
    42|                    child: Column(
    43|                      crossAxisAlignment: CrossAxisAlignment.start,
    44|                      children: [
    45|                        Padding(
    46|                          padding: const EdgeInsets.fromLTRB(0, 10, 14, 0),
    47|                          child: Align(
    48|                            alignment: Alignment.centerRight,
    49|                            child: GestureDetector(
    50|                              onTap: () => Navigator.pop(context),
    51|                              child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.border)), child: Icon(Icons.close_rounded, size: 14, color: c.inkSec)),
    52|                            ),
    53|                          ),
    54|                        ),
    55|                        Padding(
    56|                          padding: const EdgeInsets.symmetric(horizontal: 20),
    57|                          child: Column(
    58|                            crossAxisAlignment: CrossAxisAlignment.start,
    59|                            children: [
    60|                              Text(entry.title, style: TextStyle(fontFamily: 'Noto Serif SC', fontSize: 22, fontWeight: FontWeight.w700, color: c.ink, height: 1.3)),
    61|                              const SizedBox(height: 10),
    62|                              Row(children: [
    63|                                Text(entry.mood, style: const TextStyle(fontSize: 16)),
    64|                                const SizedBox(width: 8), Text(entry.weather, style: TextStyle(fontSize: 13, color: c.inkSec)),
    65|                                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('·', style: TextStyle(color: c.border))),
    66|                                Text(entry.feeling, style: TextStyle(fontSize: 13, color: c.accent, fontWeight: FontWeight.w500)),
    67|                              ]),
    68|                            ],
    69|                          ),
    70|                        ),
    71|                        Padding(
    72|                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    73|                          child: CustomPaint(size: const Size(double.infinity, 1), painter: _DashedLine(color: c.border)),
    74|                        ),
    75|                        Padding(
    76|                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    77|                          child: _buildBody(entry.body, c),
    78|                        ),
    79|                        Padding(
    80|                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    81|                          child: Row(
    82|                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
    83|                            children: [
    84|                              Text('${entry.author} · ${entry.date}', style: TextStyle(fontSize: 11, color: c.inkSec)),
    85|                              Text('☕ 读完', style: TextStyle(fontSize: 11, color: c.inkSec)),
    86|                            ],
    87|                          ),
    88|                        ),
    89|                      ],
    90|                    ),
    91|                  ),
    92|                ),
    93|              ),
    94|              Center(
    95|                child: Row(
    96|                  mainAxisAlignment: MainAxisAlignment.center,
    97|                  children: List.generate(4, (i) => AnimatedContainer(
    98|                    duration: const Duration(milliseconds: 300),
    99|                    margin: const EdgeInsets.symmetric(horizontal: 3),
   100|                    width: i == 2 ? 18 : 5, height: 5,
   101|                    decoration: BoxDecoration(color: i == 2 ? c.accent : c.border, borderRadius: BorderRadius.circular(3)),
   102|                  )),
   103|                ),
   104|              ),
   105|              const SizedBox(height: 16),
   106|            ],
   107|          ),
   108|        ),
   109|      ),
   110|    );
   111|  }
   112|
   113|  Widget _buildBody(String text, MoonlitTheme c) {
   114|    final paras = text.split('\n\n');
   115|    return Column(
   116|      crossAxisAlignment: CrossAxisAlignment.start,
   117|      children: paras.map((para) {
   118|        final hl = para.contains('水在') || para.contains('不是设计') || para.contains('我的第一');
   119|        return Padding(
   120|          padding: const EdgeInsets.only(bottom: 14),
   121|          child: Text(
   122|            para,
   123|            style: TextStyle(
   124|              fontSize: 14, color: c.ink, height: 1.8, letterSpacing: 0.3,
   125|              backgroundColor: hl ? c.warm.withValues(alpha: c.isDark ? 0.15 : 0.25) : null,
   126|            ),
   127|          ),
   128|        );
   129|      }).toList(),
   130|    );
   131|  }
   132|}
   133|
   134|class _DashedLine extends CustomPainter {
   135|  final Color color;
   136|  _DashedLine({required this.color});
   137|  @override
   138|  void paint(Canvas canvas, Size size) {
   139|    final paint = Paint()..color = color..strokeWidth = 1;
   140|    double x = 0;
   141|    while (x < size.width) {
   142|      canvas.drawLine(Offset(x, 0), Offset((x + 6).clamp(0, size.width), 0), paint);
   143|      x += 10;
   144|    }
   145|  }
   146|  @override
   147|  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
   148|}
   149|