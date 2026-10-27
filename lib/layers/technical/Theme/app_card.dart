import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(18),
    this.color = AppColors.card,
    this.border,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: child,
    );
    return onTap == null ? box : GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: box);
  }
}
