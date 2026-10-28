import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Theme/app_colors.dart';

class RingSegment {
  const RingSegment({required this.id, required this.color, required this.value});

  final Object id;
  final Color color;
  final double value;
}

class SegmentedRing extends StatelessWidget {
  const SegmentedRing({
    super.key,
    required this.size,
    required this.radius,
    required this.strokeWidth,
    required this.segments,
    required this.denominator,
    required this.gap,
    this.selected,
    this.selectedStrokeWidth,
    this.onSelect,
  });

  final double size;
  final double radius;
  final double strokeWidth;
  final List<RingSegment> segments;
  final double denominator;
  final double gap;
  final Object? selected;
  final double? selectedStrokeWidth;
  final ValueChanged<Object>? onSelect;

  List<(RingSegment, double, double)> _arcs() {
    final circ = 2 * math.pi * radius;
    final total = denominator <= 0 ? 1.0 : denominator;
    var offset = 0.0;
    return [
      for (final s in segments)
        () {
          final len = s.value / total * circ;
          final start = offset / circ * 2 * math.pi - math.pi / 2;
          final sweep = math.max(len - gap, 0.5) / circ * 2 * math.pi;
          offset += len;
          return (s, start, sweep);
        }(),
    ];
  }

  void _onTap(Offset p) {
    final c = Offset(size / 2, size / 2);
    final d = p - c;
    if ((d.distance - radius).abs() > math.max(strokeWidth, 22)) return;
    var a = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (a < 0) a += 2 * math.pi;
    for (final (s, start, sweep) in _arcs()) {
      var from = start + math.pi / 2;
      if (from < 0) from += 2 * math.pi;
      if (a >= from && a <= from + sweep + gap / (2 * math.pi * radius) * 2 * math.pi) {
        onSelect?.call(s.id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: onSelect == null ? null : (d) => _onTap(d.localPosition),
      child: CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(this),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.w);

  final SegmentedRing w;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: c, radius: w.radius);
    canvas.drawCircle(c, w.radius, Paint()..style = PaintingStyle.stroke..strokeWidth = w.strokeWidth..color = AppColors.track);
    for (final (s, start, sweep) in w._arcs()) {
      final isSel = w.selected == s.id;
      final dim = w.selected != null && !isSel;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSel ? (w.selectedStrokeWidth ?? w.strokeWidth) : w.strokeWidth
          ..color = dim ? s.color.withAlpha(77) : s.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => true;
}
