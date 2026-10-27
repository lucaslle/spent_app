import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(2),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(color: value ? AppColors.accent : AppColors.line, borderRadius: BorderRadius.circular(14)),
        child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: AppColors.text, shape: BoxShape.circle)),
      ),
    );
  }
}
