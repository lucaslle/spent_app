import 'package:flutter/material.dart';

import '../layers/technical/Theme/app_colors.dart';
import '../layers/technical/Theme/app_text.dart';
import 'app_tab_cubit.dart';

const _items = <(AppTab, String, IconData)>[
  (AppTab.today, 'Jour', Icons.home_outlined),
  (AppTab.transactions, 'Opérations', Icons.format_list_bulleted_rounded),
  (AppTab.budget, 'Budget', Icons.pie_chart_outline_rounded),
  (AppTab.analysis, 'Analyse', Icons.bar_chart_rounded),
  (AppTab.settings, 'Réglages', Icons.tune_rounded),
];

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({super.key, required this.current, required this.onSelect});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: (bottom > 12 ? bottom : 12) + 8,
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: AppColors.tabBar, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.line)),
        child: Row(children: [
          for (final (tab, label, icon) in _items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(tab),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon, size: 22, color: current == tab ? AppColors.accent : AppColors.muted),
                  const SizedBox(height: 3),
                  AppText(label, size: 10, color: current == tab ? AppColors.accent : AppColors.muted),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
