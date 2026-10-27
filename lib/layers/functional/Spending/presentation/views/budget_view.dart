import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/avatar_badge.dart';
import '../../../../technical/Theme/progress_bar.dart';
import '../../../../technical/Theme/screen_scaffold.dart';
import '../../domain/spending_stats.dart';
import '../cubit/spending_cubit.dart';

class BudgetView extends StatelessWidget {
  const BudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SpendingCubit>().state.stats;
    if (s == null) {
      return const ScreenScaffold(title: 'Budget', children: [AppText('Importez un relevé pour suivre votre budget.', weight: FontWeight.w500, color: AppColors.muted)]);
    }
    final over = s.projection > s.budgetTotal;
    return ScreenScaffold(
      title: 'Budget',
      eyebrow: '${capitalize(mois[s.month - 1])} ${s.year}',
      children: [
        AppCard(
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppText('Dépensé sur ${context.money(s.budgetTotal, decimals: 0)}', size: 13, weight: FontWeight.w600, color: AppColors.soft),
                AppText(context.money(s.spent), size: 30, weight: FontWeight.w800),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const AppText('Fin estimée', size: 11, weight: FontWeight.w600, color: AppColors.muted),
                AppText(context.money(s.projection, decimals: 0), size: 15, color: over ? AppColors.neg : AppColors.pos),
              ]),
            ]),
            const SizedBox(height: 14),
            ProgressBar(
              ratio: s.budgetTotal > 0 ? s.spent / s.budgetTotal : 0,
              color: s.spent > s.budgetTotal ? AppColors.neg : AppColors.accent,
              height: 12,
              markAt: s.pace,
              markColor: Colors.white,
              markWidth: 3,
            ),
          ]),
        ),
        for (final c in s.categories) _CategoryCard(stat: c, pace: s.pace),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.stat, required this.pace});

  final CategoryStat stat;
  final double pace;

  @override
  Widget build(BuildContext context) {
    final cat = stat.category;
    final color = stat.over ? AppColors.neg : (stat.ratio > pace * 1.15 && !cat.isFixed ? AppColors.warn : cat.color);
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          AvatarBadge(initials: cat.label.substring(0, 2), color: cat.color, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppText(cat.label),
            AppText(stat.over ? 'Dépassé de ${context.money(stat.amount - stat.budget, decimals: 0)}' : 'Reste ${context.money(stat.budget - stat.amount, decimals: 0)}', size: 12, weight: FontWeight.w500, color: stat.over ? AppColors.neg : AppColors.muted),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            AppText(context.money(stat.amount)),
            AppText(stat.budget > 0 ? formatPercent(stat.ratio) : '—', size: 12, weight: FontWeight.w500, color: AppColors.muted),
          ]),
        ]),
        const SizedBox(height: 10),
        ProgressBar(ratio: stat.ratio, color: color, markAt: pace),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const AppText('Budget mensuel', size: 12, weight: FontWeight.w600, color: AppColors.muted),
          _Stepper(value: stat.budget, onChanged: (v) => context.read<SpendingCubit>().setBudget(cat, v)),
        ]),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(String label, double next) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(next),
          child: SizedBox(width: 36, height: 34, child: Center(child: AppText(label, size: 18, color: AppColors.accent))),
        );
    return Container(
      decoration: BoxDecoration(color: AppColors.stepper, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        button('−', value - 10),
        SizedBox(width: 64, child: AppText(context.money(value, decimals: 0), size: 13, align: TextAlign.center)),
        button('+', value + 10),
      ]),
    );
  }
}
