import 'package:flutter/material.dart';

import 'app_colors.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.ratio, required this.color, this.height = 8, this.markAt, this.markColor = AppColors.faint, this.markWidth = 2});

  final double ratio;
  final Color color;
  final double height;
  final double? markAt;
  final Color markColor;
  final double markWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          width: w,
          child: Stack(children: [
            Container(color: AppColors.track),
            Container(width: w * ratio.clamp(0, 1), color: color),
            if (markAt != null) Positioned(left: w * markAt!.clamp(0, 1), top: 0, bottom: 0, width: markWidth, child: Container(color: markColor)),
          ]),
        ),
      );
    });
  }
}
