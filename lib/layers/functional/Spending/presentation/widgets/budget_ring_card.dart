import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Charts/segmented_ring.dart';
import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/spending_stats.dart';
import '../cubit/spending_view_cubit.dart';

class BudgetRingCard extends StatelessWidget {
  const BudgetRingCard({super.key, required this.stats, required this.onOpenBudget});

  final SpendingStats stats;
  final VoidCallback onOpenBudget;

  @override
  Widget build(BuildContext context) {
    final selected = context.select((SpendingViewCubit c) => c.state.donutSelection);
    final sel = stats.categories.where((c) => c.category == selected && c.amount > 0).firstOrNull;
    final segments = [for (final c in stats.categories.where((c) => c.amount > 0)) RingSegment(id: c.category, color: c.category.color, value: c.amount)];
    final pct = stats.budgetTotal > 0 ? (stats.spent / stats.budgetTotal * 100).round() : 0;
    final denom = stats.budgetTotal > stats.spent ? stats.budgetTotal : stats.spent;
    return AppCard(
      child: Row(children: [
        SizedBox(
          width: 124,
          height: 124,
          child: Stack(alignment: Alignment.center, children: [
            SegmentedRing(
              size: 124, radius: 52, strokeWidth: 11, gap: 3, denominator: denom, segments: segments,
              selected: sel?.category, selectedStrokeWidth: 15,
              onSelect: (id) => context.read<SpendingViewCubit>().toggleDonut(id as SpendCategory),
            ),
            GestureDetector(
              onTap: onOpenBudget,
              child: SizedBox(
                width: 70,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AppText(sel?.category.label.toUpperCase() ?? 'BUDGET', size: 9, color: sel?.category.color ?? AppColors.muted, maxLines: 1),
                  AppText(sel != null ? context.money(sel.amount, decimals: 0) : '$pct %', size: 20, weight: FontWeight.w800),
                  AppText(sel != null ? '${formatPercent(sel.ratio)} du budget' : 'J${stats.day}/${stats.daysInMonth}', size: 10, weight: FontWeight.w600, color: AppColors.muted, maxLines: 1),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const AppText('Reste ce mois', size: 12, weight: FontWeight.w600, color: AppColors.muted),
            AppText(context.money(stats.remaining, decimals: 0), size: 24, weight: FontWeight.w800, color: stats.remaining < 0 ? AppColors.neg : AppColors.text),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _Figure('Par jour', context.money(stats.perDay < 0 ? 0 : stats.perDay, decimals: 0))),
              Expanded(child: _Figure('Dépensé', context.money(stats.spent, decimals: 0))),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppText(label, size: 11, weight: FontWeight.w600, color: AppColors.muted),
        AppText(value, maxLines: 1),
      ]);
}
