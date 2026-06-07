import 'package:flutter/material.dart';

/// 月下窗统一圆点导航 —— 从 windowsill / diary / todo / echo 四处重复定义抽取
class PageDots extends StatelessWidget {
  final int count;
  final int active;
  final Color accent;
  final Color border;

  const PageDots({
    super.key,
    required this.count,
    required this.active,
    required this.accent,
    required this.border,
  });

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
