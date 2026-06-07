import 'package:flutter/material.dart';

/// 月下窗底部装饰：小猫小狗花草线稿
/// 从 windowsill_page.dart 的 _DecoPainter 抽取
class FloatingDecor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DecoPainter(
          borderColor: borderColor,
          fillColor: fillColor,
          fillLightColor: fillLightColor,
          blushColor: blushColor,
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
    qb(88,58,86,80,92,92); qb(92,92,98,96,110,96); qb(110,96,122,96,128,92); qb(128,92,134,80,132,58);
    qb(88,48,88,28,100,22); qb(100,22,110,18,120,22); qb(120,22,132,28,132,48);
    qb(90,30,82,34,76,44); qb(76,44,72,52,74,56); qb(74,56,78,58,82,50); qb(82,50,86,42,92,34);
    qb(130,30,138,34,144,44); qb(144,44,148,52,146,56); qb(146,56,142,58,138,50); qb(138,50,134,42,128,34);
    cr(102,38,3,fill); cr(118,38,3,fill); cr(110,46,2.5,fill);
    qb(106,50,110,54,114,50); cr(96,44,5,blush); cr(124,44,5,blush);
    qb(102,94,102,100,106,100); qb(106,100,110,100,110,96);
    qb(114,94,114,100,118,100); qb(118,100,122,100,122,96);
    ln(90,80,80,74); ln(78,66,76,60); ln(80,58,78,66);

    // 狗
    qb(128,60,126,80,130,92); qb(130,92,136,96,148,96); qb(148,96,160,96,166,92); qb(166,92,170,80,168,60);
    qb(134,50,134,30,142,24); qb(142,24,150,20,158,24); qb(158,24,166,30,166,50);
    qb(138,28,136,18,140,12); qb(140,12,144,10,146,20);
    qb(162,28,164,18,160,12); qb(160,12,156,10,154,20);
    final e1 = Path()..moveTo(139*sx,26*sy)..quadraticBezierTo(138*sx,18*sy,141*sx,14*sy)..quadraticBezierTo(143*sx,12*sy,145*sx,20*sy)..close();
    canvas.drawPath(e1, fillLight);
    final e2 = Path()..moveTo(161*sx,26*sy)..quadraticBezierTo(162*sx,18*sy,159*sx,14*sy)..quadraticBezierTo(157*sx,12*sy,155*sx,20*sy)..close();
    canvas.drawPath(e2, fillLight);
    qb(142,40,145,36,148,40); qb(152,40,155,36,158,40);
    cr(150,46,2,fill); qb(147,49,150,52,150,49); qb(150,49,150,52,153,49);
    cr(138,46,4.5,blush); cr(162,46,4.5,blush);
    ln(136,44,126,42); ln(136,46,126,48); ln(164,44,174,42); ln(164,46,174,48);
    qb(144,94,144,100,148,100); qb(148,100,152,100,152,96);
    qb(156,94,156,100,160,100); qb(160,100,164,100,164,96);
    qb(166,82,178,76,184,66); qb(184,66,190,56,186,48);
    ln(152,62,156,60); ln(160,62,152,62); ln(150,68,156,66); ln(162,68,150,68);
    ln(150,74,156,72); ln(162,74,150,74); ln(152,80,156,78); ln(160,80,152,80);
    // 花草
    ln(52,96,48,74); ln(48,74,50,72); ln(52,74,54,72);
    ln(48,68,46,62); ln(48,68,50,62); ln(48,68,42,66); ln(48,68,54,66); ln(48,68,48,60);
    ln(30,96,26,70); ln(26,64,24,58); ln(26,64,28,58); ln(26,64,20,62); ln(26,64,32,62); ln(26,64,26,56);
    ln(252,96,256,76); ln(256,70,254,64); ln(256,70,258,64); ln(256,70,250,68); ln(256,70,262,68); ln(256,70,256,62);
    ln(278,96,282,72); ln(282,66,280,60); ln(282,66,284,60); ln(282,66,276,64); ln(282,66,288,64); ln(282,66,282,58);
    ln(40,98,42,88); ln(46,98,44,86); ln(64,98,66,90); ln(70,98,68,88);
    ln(200,98,202,90); ln(208,98,206,86); ln(228,98,230,88); ln(236,98,234,86);
    ln(260,98,262,90); ln(296,98,294,88); ln(302,98,304,86);
    ln(146,26,148,30); ln(154,26,152,30); ln(136,56,138,60); ln(164,56,162,60); ln(140,78,142,82);
  }

  @override
  bool shouldRepaint(covariant _DecoPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
