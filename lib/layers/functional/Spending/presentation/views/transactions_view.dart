import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_chip.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/screen_scaffold.dart';
import '../../domain/categorizer.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/entities/transaction_entry.dart';
import '../cubit/spending_cubit.dart';
import '../cubit/spending_view_cubit.dart';
import '../widgets/transaction_row.dart';
import 'transaction_detail_sheet.dart';

bool _matches(TransactionEntry t, String f) => f == 'all' || (f == 'out' && t.amount < 0 && SpendCategory.spending.contains(t.category)) || (f == 'in' && t.isIncome) || t.category.name == f;

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpendingCubit>().state;
    final view = context.watch<SpendingViewCubit>();
    final f = view.state.filter;
    final q = view.state.search.trim().toLowerCase();
    if (_controller.text != view.state.search) _controller.text = view.state.search;

    final list = state.entries.where((t) => _matches(t, f) && (q.isEmpty || '${t.raw} ${merchantName(t.raw)} ${t.category.label}'.toLowerCase().contains(q))).toList();
    final groups = <(String, double, List<TransactionEntry>)>[];
    for (final t in list) {
      if (groups.isEmpty || groups.last.$1 != t.date) groups.add((t.date, 0, []));
      final g = groups.last;
      groups[groups.length - 1] = (g.$1, g.$2 + t.amount, g.$3..add(t));
    }
    final stats = state.stats;
    String label(String d) => stats != null && stats.isToday && d == stats.ref ? 'Aujourd’hui' : (stats != null && stats.isToday && d == stats.yesterday ? 'Hier' : dayLabel(d));
    final total = list.fold<double>(0, (a, t) => a + t.amount);

    final filters = <(String, String, Color?)>[
      ('all', 'Tout', null), ('out', 'Dépenses', null), ('in', 'Revenus', null), (SpendCategory.invest.name, 'Investissement', SpendCategory.invest.color), ('autre', 'À classer · ${state.toReviewCount}', null),
      for (final c in SpendCategory.spending.where((c) => c != SpendCategory.autre)) (c.name, c.label, c.color),
    ];

    return ScreenScaffold(
      title: 'Opérations',
      pinned: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Icon(Icons.search_rounded, size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: view.setSearch,
                style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.text),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Rechercher', hintStyle: TextStyle(color: AppColors.faint), isDense: true),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => AppChip(label: filters[i].$2, selected: f == filters[i].$1, dot: filters[i].$3, onTap: () => view.setFilter(filters[i].$1)),
          ),
        ),
      ]),
      children: [
        AppText('${list.length} opérations · ${context.money(total, sign: true)}', size: 12, weight: FontWeight.w600, color: AppColors.muted),
        if (groups.isEmpty) const Padding(padding: EdgeInsets.only(top: 24), child: AppText('Aucun résultat.', weight: FontWeight.w500, color: AppColors.muted, align: TextAlign.center)),
        for (final g in groups)
          AppCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  AppText(label(g.$1), size: 12, color: AppColors.muted),
                  AppText(context.money(g.$2, sign: true), size: 12, color: AppColors.muted),
                ]),
              ),
              for (final t in g.$3) TransactionRow(entry: t, onTap: () => showTransactionDetail(context, t.id)),
            ]),
          ),
      ],
    );
  }
}
