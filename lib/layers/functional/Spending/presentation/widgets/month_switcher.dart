import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../cubit/spending_cubit.dart';

class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpendingCubit>().state;
    final current = state.displayedMonth;
    if (current == null || state.months.length < 2) return const SizedBox.shrink();
    final i = state.months.indexOf(current);
    final cubit = context.read<SpendingCubit>();
    final y = int.parse(current.substring(0, 4));
    final m = int.parse(current.substring(5));

    Widget arrow(IconData icon, int target) {
      final enabled = target >= 0 && target < state.months.length;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => cubit.selectMonth(state.months[target]) : null,
        child: SizedBox(width: 44, height: 40, child: Icon(icon, size: 22, color: enabled ? AppColors.accent : AppColors.line)),
      );
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        arrow(Icons.chevron_left_rounded, i - 1),
        AppText('${capitalize(mois[m - 1])} $y', size: 14),
        arrow(Icons.chevron_right_rounded, i + 1),
      ]),
    );
  }
}
