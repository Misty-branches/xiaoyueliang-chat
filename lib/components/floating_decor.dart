import 'package:flutter/material.dart';

/// 月下窗底部装饰：小猫小狗花草线稿（带动画）
/// 轻微上下浮动 + 呼吸感
class FloatingDecor extends StatefulWidget {
  final Color borderColor;
  final Color fillColor;
  final Color fillLightColor;
  final Color blushColor;
  final double height;

  const FloatingDecor({
    super.key,
    required this.borderColor,
    required this.fillColor,
    required this.fillLightColor,
    required this.blushColor,
    this.height = 80,
  });

  @override
  State<FloatingDecor> createState() => _FloatingDecorState();
}

class _FloatingDecorState extends State<FloatingDecor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          painter: _DecoPainter(
            borderColor: widget.borderColor,
            fillColor: widget.fillColor,
            fillLightColor: widget.fillLightColor,
            blushColor: widget.blushColor,
          ),
        ),
      ),
    );
  }
}

class _DecoPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final Color fillLightColor;
  final Color blushColor;

  _DecoPainter({
    required this.borderColor,
    required this.fillColor,
    required this.fillLightColor,
    required this.blushColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = borderColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = fillColor..style = PaintingStyle.fill;
    final fillLight = Paint()..color = fillLightColor..style = PaintingStyle.fill;
    final blush = Paint()..color = blushColor..style = PaintingStyle.fill;

    final sx = size.width / 320, sy = size.height / 100;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    void ln(double x1, double y1, double x2, double y2) => canvas.drawLine(p(x1, y1), p(x2, y2), stroke);
    void cr(double cx, double cy, double r, [Paint? pt]) => canvas.drawCircle(p(cx, cy), r * ((sx + sy) / 2), pt ?? stroke);
    void qb(double x1, double y1, double cx, double cy, double x2, double y2) {
      canvas.drawPath(Path()..moveTo(x1 * sx, y1 * sy)..quadraticBezierTo(cx * sx, cy * sy, x2 * sx, y2 * sy), stroke);
    }

    // 猫
    qb(115,58,113,80,119,92); qb(119,92,125,96,137,96); qb(137,96,149,96,155,92); qb(155,92,161,80,159,58);
    qb(115,48,115,28,127,22); qb(127,22,137,18,147,22); qb(147,22,159,28,159,48);
    qb(117,30,109,34,103,44); qb(103,44,99,52,101,56); qb(101,56,105,58,109,50); qb(109,50,113,42,119,34);
    qb(157,30,165,34,171,44); qb(171,44,175,52,173,56); qb(173,56,169,58,165,50); qb(165,50,161,42,155,34);
    cr(129,38,3,fill); cr(145,38,3,fill); cr(137,46,2.5,fill);
    qb(133,50,137,54,141,50); cr(123,44,5,blush); cr(151,44,5,blush);
    qb(129,94,129,100,133,100); qb(133,100,137,100,137,96);
    qb(141,94,141,100,145,100); qb(145,100,149,100,149,96);
    ln(117,80,107,74); ln(105,66,103,60); ln(107,58,105,66);

    // 狗
    qb(155,60,153,80,157,92); qb(157,92,163,96,175,96); qb(175,96,187,96,193,92); qb(193,92,197,80,195,60);
    qb(161,50,161,30,169,24); qb(169,24,177,20,185,24); qb(185,24,193,30,193,50);
    qb(165,28,163,18,167,12); qb(167,12,171,10,173,20);
    qb(189,28,191,18,187,12); qb(187,12,183,10,181,20);
    final e1 = Path()..moveTo(166*sx,26*sy)..quadraticBezierTo(165*sx,18*sy,168*sx,14*sy)..quadraticBezierTo(170*sx,12*sy,172*sx,20*sy)..close();
    canvas.drawPath(e1, fillLight);
    final e2 = Path()..moveTo(188*sx,26*sy)..quadraticBezierTo(189*sx,18*sy,186*sx,14*sy)..quadraticBezierTo(184*sx,12*sy,182*sx,20*sy)..close();
    canvas.drawPath(e2, fillLight);
    qb(169,40,172,36,175,40); qb(179,40,182,36,185,40);
    cr(177,46,2,fill); qb(174,49,177,52,177,49); qb(177,49,177,52,180,49);
    cr(165,46,4.5,blush); cr(189,46,4.5,blush);
    ln(163,44,153,42); ln(163,46,153,48); ln(191,44,201,42); ln(191,46,201,48);
    qb(171,94,171,100,175,100); qb(175,100,179,100,179,96);
    qb(183,94,183,100,187,100); qb(187,100,191,100,191,96);
    qb(193,82,205,76,211,66); qb(211,66,217,56,213,48);
    ln(179,62,183,60); ln(187,62,179,62); ln(177,68,183,66); ln(189,68,177,68);
    ln(177,74,183,72); ln(189,74,177,74); ln(179,80,183,78); ln(187,80,179,80);
    // 花草
    ln(72,96,68,74); ln(68,74,70,72); ln(72,74,74,72);
    ln(68,68,66,62); ln(68,68,70,62); ln(68,68,62,66); ln(68,68,74,66); ln(68,68,68,60);
    ln(50,96,46,70); ln(46,64,44,58); ln(46,64,48,58); ln(46,64,40,62); ln(46,64,52,62); ln(46,64,46,56);
    ln(232,96,236,76); ln(236,70,234,64); ln(236,70,238,64); ln(236,70,230,68); ln(236,70,242,68); ln(236,70,236,62);
    ln(258,96,262,72); ln(262,66,260,60); ln(262,66,264,60); ln(262,66,256,64); ln(262,66,268,64); ln(262,66,262,58);
    ln(60,98,62,88); ln(66,98,64,86); ln(84,98,86,90); ln(90,98,88,88);
    ln(180,98,182,90); ln(188,98,186,86); ln(208,98,210,88); ln(216,98,214,86);
    ln(240,98,242,90); ln(276,98,274,88); ln(282,98,284,86);
    ln(173,26,175,30); ln(181,26,179,30); ln(163,56,165,60); ln(191,56,189,60); ln(167,78,169,82);
  }

  @override
  bool shouldRepaint(covariant _DecoPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
