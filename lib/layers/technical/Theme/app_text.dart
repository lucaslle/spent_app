import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.size = 14,
    this.weight = FontWeight.w700,
    this.color = AppColors.text,
    this.mono = false,
    this.align,
    this.maxLines,
    this.letterSpacing,
  });

  final String data;
  final double size;
  final FontWeight weight;
  final Color color;
  final bool mono;
  final TextAlign? align;
  final int? maxLines;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: mono ? 'GeistMono' : 'Manrope',
        fontSize: size,
        fontWeight: mono ? FontWeight.w500 : weight,
        color: color,
        letterSpacing: letterSpacing ?? (size >= 22 ? -size * 0.025 : 0),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
