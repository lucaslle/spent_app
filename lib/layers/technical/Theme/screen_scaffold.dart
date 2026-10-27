import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';
import 'row_gap.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({super.key, required this.title, required this.children, this.eyebrow, this.topBar, this.pinned});

  final String title;
  final String? eyebrow;
  final Widget? topBar;
  final Widget? pinned;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final heading = Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null) AppText(eyebrow!, size: 13, weight: FontWeight.w500, color: AppColors.muted),
        AppText(title, size: 26, weight: FontWeight.w800),
      ]),
    );
    final list = ListView(
      padding: EdgeInsets.fromLTRB(16, pinned == null ? 8 : 4, 16, 130),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (pinned == null) ...[?topBar, heading],
        ...children.withGap(12),
      ].withGap(pinned == null ? 12 : 0),
    );
    return SafeArea(
      bottom: false,
      child: pinned == null
          ? list
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [heading, const SizedBox(height: 10), pinned!])),
              Expanded(child: list),
            ]),
    );
  }
}
