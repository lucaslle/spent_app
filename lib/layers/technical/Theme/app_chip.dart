import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, required this.selected, required this.onTap, this.dot, this.tint});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dot;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? (tint != null ? tint!.withAlpha(0x2E) : AppColors.accent) : AppColors.card;
    final fg = selected && tint == null ? AppColors.accentInk : AppColors.text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected && tint != null ? tint! : Colors.transparent, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot != null) ...[
            Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          AppText(label, size: 12, color: fg),
        ]),
      ),
    );
  }
}
