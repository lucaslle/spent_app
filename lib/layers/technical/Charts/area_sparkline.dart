import 'package:flutter/material.dart';

import '../Theme/app_colors.dart';

class SparkPoint {
  const SparkPoint(this.t, this.v);

  final int t;
  final double v;
}

class AreaSparkline extends StatelessWidget {
  const AreaSparkline({super.key, required this.points, required this.height, this.color = AppColors.accent});

  final List<SparkPoint> points;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(double.infinity, height), painter: _SparkPainter(points, color));
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.points, this.color);

  final List<SparkPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final t0 = points.first.t;
    final t1 = points.last.t;
    final vs = points.map((p) => p.v);
    final mn = vs.reduce((a, b) => a < b ? a : b);
    final mx = vs.reduce((a, b) => a > b ? a : b);
    final rg = mx - mn == 0 ? (mx > 1 ? mx : 1.0) : mx - mn;
    final lo = mn - rg * 0.15;
    final hi = mx + rg * 0.15;
    double x(SparkPoint p) => t1 > t0 ? (p.t - t0) / (t1 - t0) * (size.width - 6) + 3 : size.width - 3;
    double y(double v) => size.height - (v - lo) / (hi - lo) * size.height;

    final pts = points.length == 1 ? [Offset(3, y(points.first.v)), Offset(x(points.first), y(points.first.v))] : [for (final p in points) Offset(x(p), y(p.v))];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      line.lineTo(o.dx, o.dy);
    }
    final area = Path.from(line)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(area, Paint()..color = color.withAlpha(36));
    canvas.drawPath(line, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round..color = color);
    canvas.drawCircle(pts.last, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.points != points;
}
