import 'package:flutter/material.dart';

abstract final class AppColors {
  static const bg = Color(0xFF0D0B07);
  static const card = Color(0xFF1A1710);
  static const cardInner = Color(0xFF231F15);
  static const wealth = Color(0xFF221D10);
  static const stepper = Color(0xFF26211A);
  static const track = Color(0xFF2E2919);
  static const line = Color(0xFF3A3320);
  static const bar = Color(0xFF4A4228);
  static const barFuture = Color(0xFF24201A);
  static const text = Color(0xFFF4EFE2);
  static const muted = Color(0xFFA39A80);
  static const faint = Color(0xFF6E664F);
  static const soft = Color(0xFFC9BE9C);
  static const accent = Color(0xFFEBCB5C);
  static const accentLight = Color(0xFFF9E596);
  static const accentDark = Color(0xFFC39228);
  static const accentInk = Color(0xFF0D0B07);
  static const pos = Color(0xFF4ADE9B);
  static const neg = Color(0xFFFF7A7A);
  static const warn = Color(0xFFF2A65A);
  static const prev = Color(0xFF5A5030);
  static const veil = Color(0xA604060A);
  static const tabBar = Color(0xF022201A);

  static Color parse(String hex) => Color(int.parse('FF${hex.substring(1)}', radix: 16));
}
