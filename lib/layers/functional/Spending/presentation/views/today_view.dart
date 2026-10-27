import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/ecu_logo.dart';
import '../../../../technical/Theme/screen_scaffold.dart';
import '../../domain/categorizer.dart';
import '../../domain/spending_stats.dart';
import '../cubit/spending_cubit.dart';
import '../cubit/spending_state.dart';
import '../widgets/budget_ring_card.dart';
import '../widgets/daily_bars_card.dart';
import '../widgets/month_switcher.dart';
import '../widgets/transaction_row.dart';
import 'import_sheet.dart';
import 'transaction_detail_sheet.dart';

class TodayView extends StatelessWidget {
  const TodayView({super.key, required this.wealthCard, required this.onOpenBudget, required this.onSeeAll, required this.onShowFilter});

  final Widget wealthCard;
  final VoidCallback onOpenBudget;
  final VoidCallback onSeeAll;
  final ValueChanged<String> onShowFilter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpendingCubit>().state;
    final s = state.stats;
    final topBar = Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Row(children: [EcuLogo(), SizedBox(width: 8), AppText('écu', size: 17, mono: true, letterSpacing: -0.7)]),
      GestureDetector(
        onTap: () => showImportSheet(context),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.file_download_outlined, size: 20, color: AppColors.text),
        ),
      ),
    ]);
    if (s == null) {
      return ScreenScaffold(title: 'Vos dépenses', topBar: topBar, children: [
        wealthCard,
        const AppCard(child: AppText('Aucune opération. Importez un relevé CSV pour commencer.', weight: FontWeight.w500, color: AppColors.muted)),
      ]);
    }
    final overBudget = s.projection - s.budgetTotal;
    return ScreenScaffold(
      title: 'Vos dépenses',
      eyebrow: '${s.isToday ? 'Aujourd’hui · ' : ''}${capitalize(jours[s.weekday])} ${s.day} ${mois[s.month - 1]}',
      topBar: topBar,
      children: [
        wealthCard,
        const MonthSwitcher(),
        BudgetRingCard(stats: s, onOpenBudget: onOpenBudget),
        _IncomeRow(stats: s, onTap: () => onShowFilter('in')),
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: AppCard(radius: 20, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppText(s.isToday ? 'Dépensé aujourd’hui' : 'Dépensé le ${s.day} ${moisCourts[s.month - 1]}', size: 12, weight: FontWeight.w600, color: AppColors.muted),
              AppText(context.money(s.todaySpent), size: 22, weight: FontWeight.w800),
              AppText('${formatPercentSigned(s.vsAverage)} vs moyenne', size: 11, color: s.vsAverage > 0.1 ? AppColors.neg : AppColors.pos),
            ])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppCard(radius: 20, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const AppText('Projection fin de mois', size: 12, weight: FontWeight.w600, color: AppColors.muted),
              AppText(context.money(s.projection, decimals: 0), size: 22, weight: FontWeight.w800, color: overBudget > 0 ? AppColors.neg : AppColors.pos),
              AppText(overBudget > 0 ? '+${context.money(overBudget, decimals: 0)} au-dessus du budget' : '${context.money(-overBudget, decimals: 0)} sous le budget', size: 11, color: overBudget > 0 ? AppColors.neg : AppColors.pos),
            ])),
          ),
        ])),
        DailyBarsCard(stats: s),
        AppCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              AppText(s.isToday ? 'Aujourd’hui' : 'Le ${s.day} ${moisCourts[s.month - 1]}', size: 15),
              GestureDetector(onTap: onSeeAll, child: const AppText('Tout voir ›', size: 13, color: AppColors.accent)),
            ]),
            if (s.todayEntries.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: AppText('Aucune opération ce jour-là.', size: 13, weight: FontWeight.w500, color: AppColors.muted)),
            for (final t in s.todayEntries) TransactionRow(entry: t, onTap: () => showTransactionDetail(context, t.id)),
          ]),
        ),
        _ReviewBanner(state: state, onTap: () => onShowFilter('autre')),
      ],
    );
  }
}

class _IncomeRow extends StatelessWidget {
  const _IncomeRow({required this.stats, required this.onTap});

  final SpendingStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final income = stats.incomeEntry;
    if (income == null) {
      return const AppCard(radius: 20, padding: EdgeInsets.all(14), child: AppText('Aucun revenu détecté ce mois. Classez votre salaire en « Revenus » depuis le détail d’une opération.', size: 13, weight: FontWeight.w500, color: AppColors.muted));
    }
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.pos.withAlpha(38), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_upward_rounded, size: 18, color: AppColors.pos)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppText('Revenus du mois'),
          AppText('${merchantName(income.raw)} · ${shortDate(income.date)}', size: 12, weight: FontWeight.w500, color: AppColors.muted),
        ])),
        AppText(context.money(stats.income, sign: true), color: AppColors.pos),
      ]),
    );
  }
}

class _ReviewBanner extends StatelessWidget {
  const _ReviewBanner({required this.state, required this.onTap});

  final SpendingState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (state.toReviewCount == 0) return const SizedBox.shrink();
    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(14),
      color: AppColors.warn.withAlpha(26),
      onTap: onTap,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const AppText('Opérations à classer', color: AppColors.warn),
        AppText('${state.toReviewCount} ›', color: AppColors.warn),
      ]),
    );
  }
}
