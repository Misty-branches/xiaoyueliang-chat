import 'package:flutter/material.dart';
import '../models/moonlit_colors.dart';

/// 月下窗统一卡片容器
class MoonlitCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const MoonlitCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 14,
    this.color,
    this.border,
    this.boxShadow,
  });

  /// 使用 MoonlitTheme 自动创建标准卡片
  factory MoonlitCard.standard({
    required Widget child,
    required MoonlitTheme c,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 14,
    Border? border,
    bool isDark = false,
  }) {
    return MoonlitCard(
      child: child,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      borderRadius: borderRadius,
      color: c.paper,
      border: border,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
          blurRadius: 8,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
