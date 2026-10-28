import 'package:flutter/material.dart';

import 'app_text.dart';

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key, required this.initials, required this.color, this.size = 38});

  final String initials;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withAlpha(0x24), borderRadius: BorderRadius.circular(size * 0.32)),
      child: AppText(initials, size: size > 50 ? 20 : 12, weight: FontWeight.w800, color: color),
    );
  }
}
