import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

Future<void> showAppSheet(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.veil,
    builder: builder,
  );
}

class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.title, required this.child, this.leading});

  final String title;
  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 34),
        decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 12),
          Row(children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(child: AppText(title, size: 22, weight: FontWeight.w800, maxLines: 1)),
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.cardInner, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.soft),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Flexible(child: SingleChildScrollView(child: child)),
        ]),
      ),
    );
  }
}
