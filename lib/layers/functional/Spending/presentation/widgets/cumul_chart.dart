import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../domain/spending_stats.dart';

class CumulChart extends StatelessWidget {
  const CumulChart({super.key, required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) => CustomPaint(size: const Size(double.infinity, 120), painter: _CumulPainter(stats));
}

class _CumulPainter extends CustomPainter {
  _CumulPainter(this.s);

  final SpendingStats s;

  @override
  void paint(Canvas canvas, Size size) {
    final raw = [s.projection, s.prevTotal, s.budgetTotal, s.spent].reduce((a, b) => a > b ? a : b) * 1.08;
    final top = raw <= 0 ? 1.0 : raw;
    final w = size.width - 8;
    final h = size.height;
    double x(int d, int n) => d / n * w;
    double y(double v) => h - v / top * h;

    Path cumulative(List<double> a, int upTo, int n) {
      var acc = 0.0;
      final p = Path()..moveTo(0, h);
      for (var i = 0; i < upTo; i++) {
        acc += a[i];
        p.lineTo(x(i + 1, n), y(acc));
      }
      return p;
    }

    void dashed(Canvas c, Offset a, Offset b, Paint paint) {
      final total = (b - a).distance;
      final dir = (b - a) / total;
      for (var d = 0.0; d < total; d += 8) {
        c.drawLine(a + dir * d, a + dir * (d + 4 > total ? total : d + 4), paint);
      }
    }

    final stroke = Paint()..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round;
    dashed(canvas, Offset(0, y(s.budgetTotal)), Offset(w, y(s.budgetTotal)), stroke.. color = AppColors.neg..strokeWidth = 1.2);
    canvas.drawPath(cumulative(s.prevDaily, s.prevDaily.length, s.prevDaily.length), stroke..color = AppColors.prev..strokeWidth = 2);
    final cum = cumulative(s.daily, s.day, s.daysInMonth);
    canvas.drawPath(Path.from(cum)..lineTo(x(s.day, s.daysInMonth), h)..close(), Paint()..color = AppColors.accent.withAlpha(36));
    dashed(canvas, Offset(x(s.day, s.daysInMonth), y(s.spent)), Offset(w, y(s.projection)), stroke..color = AppColors.accent..strokeWidth = 2);
    canvas.drawPath(cum, stroke..color = AppColors.accent..strokeWidth = 2.5);
    canvas.drawCircle(Offset(x(s.day, s.daysInMonth), y(s.spent)), 5, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant _CumulPainter old) => old.s != s;
}
