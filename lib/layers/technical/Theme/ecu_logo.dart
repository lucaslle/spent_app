import 'package:flutter/material.dart';

import 'app_colors.dart';

class EcuLogo extends StatelessWidget {
  const EcuLogo({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: const _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 100;
    final bg = Paint()
      ..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accentLight, AppColors.accentDark])
          .createShader(Offset.zero & size);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(23 * u)), bg);
    canvas.drawCircle(Offset(50 * u, 50 * u), 30 * u, Paint()..color = const Color(0xFF1A1610));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(35 * u, 45.5 * u, 30 * u, 9 * u), Radius.circular(4.5 * u)), Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
