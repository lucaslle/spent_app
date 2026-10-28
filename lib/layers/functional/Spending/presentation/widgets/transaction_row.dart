import 'package:flutter/material.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/avatar_badge.dart';
import '../../domain/categorizer.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/entities/transaction_entry.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.entry, required this.onTap});

  final TransactionEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = merchantName(entry.raw);
    final cat = entry.category;
    final initials = initialsOf(name);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: entry.excluded ? 0.4 : 1,
        child: SizedBox(
          height: 56,
          child: Row(children: [
            AvatarBadge(initials: initials.isEmpty ? '?' : initials, color: cat.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppText(name, maxLines: 1),
                AppText(cat.label, size: 12, weight: FontWeight.w500, color: cat == SpendCategory.autre ? AppColors.warn : AppColors.muted),
              ]),
            ),
            AppText(context.money(entry.amount, sign: true), color: entry.amount > 0 ? AppColors.pos : AppColors.text),
          ]),
        ),
      ),
    );
  }
}
