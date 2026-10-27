import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../domain/account_math.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../cubit/accounts_cubit.dart';
import '../views/accounts_sheet.dart';

class AccountBreakdownBar extends StatelessWidget {
  const AccountBreakdownBar({super.key, required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final positive = accounts.where((a) => a.balance > 0).toList();
    return SizedBox(
      height: 8,
      child: Row(children: [
        for (var i = 0; i < positive.length; i++)
          Expanded(
            flex: (positive[i].balance * 100).round(),
            child: Container(margin: EdgeInsets.only(right: i == positive.length - 1 ? 0 : 3), decoration: BoxDecoration(color: positive[i].type.color, borderRadius: BorderRadius.circular(4))),
          ),
      ]),
    );
  }
}

class WealthCard extends StatelessWidget {
  const WealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountsCubit>().state;
    final total = accountTotal(accounts);
    final series = totalSeries(accounts);
    final delta = series.isEmpty ? 0.0 : total - series.first.value;
    final groups = [('Courant', AccountGroup.cash), ('Épargne', AccountGroup.save), ('Investi', AccountGroup.invest)];
    return AppCard(
      color: AppColors.wealth,
      border: AppColors.line,
      onTap: () => showAccountsSheet(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          AppText('Patrimoine · ${accounts.length} compte${accounts.length > 1 ? 's' : ''}', size: 13, weight: FontWeight.w600, color: AppColors.soft),
          const AppText('Gérer ›', size: 13, color: AppColors.accent),
        ]),
        const SizedBox(height: 6),
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 6, children: [
          AppText(context.money(total), size: 30, weight: FontWeight.w800),
          if (series.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
              child: AppText('${context.money(delta, sign: true, decimals: 0)} depuis le ${shortDate(series.first.date)}', size: 11, color: delta >= 0 ? AppColors.pos : AppColors.neg),
            ),
        ]),
        const SizedBox(height: 14),
        AccountBreakdownBar(accounts: accounts),
        const SizedBox(height: 14),
        Row(children: [
          for (final (label, g) in groups)
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppText(label, size: 11, weight: FontWeight.w600, color: AppColors.muted),
              AppText(context.money(groupTotal(accounts, g), decimals: 0)),
            ])),
        ]),
      ]),
    );
  }
}
