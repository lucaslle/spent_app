import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../layers/functional/Savings/presentation/widgets/wealth_card.dart';
import '../layers/functional/Spending/presentation/cubit/spending_cubit.dart';
import '../layers/functional/Spending/presentation/cubit/spending_view_cubit.dart';
import '../layers/functional/Spending/presentation/views/analysis_view.dart';
import '../layers/functional/Spending/presentation/views/budget_view.dart';
import '../layers/functional/Spending/presentation/views/settings_view.dart';
import '../layers/functional/Spending/presentation/views/today_view.dart';
import '../layers/functional/Spending/presentation/views/transactions_view.dart';
import '../layers/technical/Theme/app_colors.dart';
import 'app_tab_cubit.dart';
import 'floating_tab_bar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final loaded = context.select((SpendingCubit c) => c.state.loaded);
    final tab = context.watch<AppTabCubit>().state;
    final tabs = context.read<AppTabCubit>();
    if (!loaded) return const Scaffold(backgroundColor: AppColors.bg);

    void showFilter(String filter) {
      context.read<SpendingViewCubit>().setFilter(filter);
      tabs.select(AppTab.transactions);
    }

    final body = switch (tab) {
      AppTab.today => TodayView(wealthCard: const WealthCard(), onOpenBudget: () => tabs.select(AppTab.budget), onSeeAll: () => showFilter('all'), onShowFilter: showFilter),
      AppTab.transactions => const TransactionsView(),
      AppTab.budget => const BudgetView(),
      AppTab.analysis => AnalysisView(onShowFilter: showFilter),
      AppTab.settings => const SettingsView(),
    };
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(children: [Positioned.fill(child: KeyedSubtree(key: ValueKey(tab), child: body)), FloatingTabBar(current: tab, onSelect: tabs.select)]),
    );
  }
}
