import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Charts/segmented_ring.dart';
import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_button.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/avatar_badge.dart';
import '../../../../technical/Theme/progress_bar.dart';
import '../../../../technical/Theme/screen_scaffold.dart';
import '../../domain/categorizer.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/spending_stats.dart';
import '../cubit/spending_cubit.dart';
import '../cubit/spending_view_cubit.dart';
import '../widgets/cumul_chart.dart';

class AnalysisView extends StatelessWidget {
  const AnalysisView({super.key, required this.onShowFilter});

  final ValueChanged<String> onShowFilter;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SpendingCubit>().state.stats;
    if (s == null) {
      return const ScreenScaffold(title: 'Analyse', children: [AppText('Importez un relevé pour voir vos analyses.', weight: FontWeight.w500, color: AppColors.muted)]);
    }
    final net = s.income - s.spent;
    final tiles = [('Revenus', context.money(s.income, sign: true, decimals: 0), AppColors.pos), ('Dépenses', context.money(-s.spent, decimals: 0), AppColors.text), ('Solde', context.money(net, sign: true, decimals: 0), net >= 0 ? AppColors.pos : AppColors.neg)];
    return ScreenScaffold(
      title: 'Analyse',
      eyebrow: '${capitalize(mois[s.month - 1])} ${s.year}',
      children: [
        _Breakdown(stats: s, onShowFilter: onShowFilter),
        _Cumul(stats: s),
        Row(children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: AppCard(radius: 20, padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AppText(tiles[i].$1, size: 11, weight: FontWeight.w600, color: AppColors.muted),
                FittedBox(fit: BoxFit.scaleDown, child: AppText(tiles[i].$2, size: 15, weight: FontWeight.w800, color: tiles[i].$3)),
              ])),
            ),
          ],
        ]),
        _Merchants(stats: s),
        _Weekdays(stats: s),
        _Months(stats: s),
      ],
    );
  }
}

class _Breakdown extends StatelessWidget {
  const _Breakdown({required this.stats, required this.onShowFilter});

  final SpendingStats stats;
  final ValueChanged<String> onShowFilter;

  @override
  Widget build(BuildContext context) {
    final view = context.watch<SpendingViewCubit>();
    final cats = stats.categories.where((c) => c.amount > 0).toList();
    final sel = cats.where((c) => c.category == view.state.donutSelection).firstOrNull;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppText('Répartition', size: 15),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(alignment: Alignment.center, children: [
              SegmentedRing(
                size: 120, radius: 42, strokeWidth: 16, gap: 2, denominator: stats.spent,
                segments: [for (final c in cats) RingSegment(id: c.category, color: c.category.color, value: c.amount)],
                selected: sel?.category, selectedStrokeWidth: 20,
                onSelect: (id) => view.toggleDonut(id as SpendCategory),
              ),
              IgnorePointer(child: Column(mainAxisSize: MainAxisSize.min, children: [
                AppText(context.money(sel?.amount ?? stats.spent, decimals: 0), size: 15, weight: FontWeight.w800),
                AppText(sel?.category.label ?? 'ce mois', size: 9, weight: FontWeight.w600, color: AppColors.muted, maxLines: 1),
              ])),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(children: [
              for (final c in cats)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => view.toggleDonut(c.category),
                  child: Opacity(
                    opacity: sel != null && sel.category != c.category ? 0.3 : 1,
                    child: SizedBox(height: 26, child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: c.category.color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(child: AppText(c.category.label, size: 12, weight: FontWeight.w600, maxLines: 1)),
                      AppText(formatPercent(c.amount / stats.spent), size: 12, color: AppColors.muted),
                    ])),
                  ),
                ),
            ]),
          ),
        ]),
        if (sel != null) ...[
          const SizedBox(height: 12),
          AppButton(
            label: 'Voir les opérations ›',
            background: Colors.transparent,
            foreground: sel.category.color,
            borderColor: sel.category.color,
            onPressed: () {
              view.clearDonut();
              onShowFilter(sel.category.name);
            },
          ),
        ],
      ]),
    );
  }
}

class _Cumul extends StatelessWidget {
  const _Cumul({required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    final prev = moisCourts[stats.prevMonth - 1];
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          AppText('Cumul vs $prev', size: 15),
          AppText('${formatPercentSigned(stats.vsPrev)} à date', size: 12, color: stats.vsPrev > 0.05 ? AppColors.neg : AppColors.pos),
        ]),
        const SizedBox(height: 12),
        CumulChart(stats: stats),
        const SizedBox(height: 8),
        Wrap(spacing: 14, children: [
          AppText('— ${context.money(stats.spent, decimals: 0)}', size: 11, weight: FontWeight.w600, color: AppColors.accent),
          AppText('— $prev ${context.money(stats.prevTotal, decimals: 0)}', size: 11, weight: FontWeight.w600, color: AppColors.prev),
          const AppText('- - budget', size: 11, weight: FontWeight.w600, color: AppColors.neg),
        ]),
      ]),
    );
  }
}

class _Merchants extends StatelessWidget {
  const _Merchants({required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.merchants.isEmpty) return const SizedBox.shrink();
    final top = stats.merchants.first.amount;
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppText('Où va votre argent', size: 15),
        for (final m in stats.merchants)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: [
              AvatarBadge(initials: initialsOf(m.name).isEmpty ? '?' : initialsOf(m.name), color: m.category.color),
              const SizedBox(width: 12),
              Expanded(child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: AppText(m.name, maxLines: 1)),
                  AppText(context.money(m.amount)),
                ]),
                const SizedBox(height: 6),
                ProgressBar(ratio: m.amount / top, color: m.category.color, height: 5),
              ])),
            ]),
          ),
      ]),
    );
  }
}

class _Weekdays extends StatelessWidget {
  const _Weekdays({required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    final max = stats.weekdayAverages.fold<double>(1, math.max);
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppText('Jour type', size: 15),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                AppText(context.money(stats.weekdayAverages[i], decimals: 0), size: 9, weight: FontWeight.w600, color: AppColors.muted, maxLines: 1),
                const SizedBox(height: 4),
                Container(height: math.max(3, stats.weekdayAverages[i] / max * 62), decoration: BoxDecoration(color: stats.weekdayAverages[i] == max ? AppColors.accent : AppColors.bar, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 4),
                AppText('LMMJVSD'[i], size: 11, weight: FontWeight.w600, color: AppColors.muted),
              ])),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _Months extends StatelessWidget {
  const _Months({required this.stats});

  final SpendingStats stats;

  @override
  Widget build(BuildContext context) {
    final max = stats.months.fold<double>(1, (a, m) => math.max(a, math.max(m.income, m.out)));
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AppText('Entrées et sorties', size: 15),
        for (final m in stats.months)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                AppText(capitalize(moisCourts[m.month - 1]), size: 12, color: AppColors.muted),
                AppText(context.money(m.income - m.out, sign: true, decimals: 0), size: 12, color: m.income - m.out >= 0 ? AppColors.pos : AppColors.neg),
              ]),
              const SizedBox(height: 4),
              ProgressBar(ratio: m.income / max, color: AppColors.pos, height: 6),
              const SizedBox(height: 4),
              ProgressBar(ratio: m.out / max, color: AppColors.prev, height: 6),
            ]),
          ),
      ]),
    );
  }
}
