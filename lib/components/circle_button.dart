import 'package:flutter/material.dart';

/// 月下窗统一圆形按钮 —— 从 diary_page / todo_page 的重复定义抽取
class CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const CircleButton({
    super.key,
    required this.icon,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
    this.size = 36,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: border),
          color: bg,
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
