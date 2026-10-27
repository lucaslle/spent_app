import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

void showToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Center(child: AppText(message, size: 13, color: AppColors.accentInk)),
      duration: const Duration(milliseconds: 2400),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFFF4EFE2),
      elevation: 12,
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 104),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
}
