import 'package:shared_preferences/shared_preferences.dart';

import '../layers/functional/Savings/data/shared_prefs_accounts_gateway.dart';
import '../layers/functional/Savings/domain/entities/account.dart';
import '../layers/functional/Savings/domain/entities/account_type.dart';
import '../layers/functional/Spending/data/shared_prefs_spending_gateway.dart';
import '../layers/functional/Spending/domain/entities/spend_category.dart';
import '../layers/functional/Spending/domain/gateways/spending_gateway.dart';
import '../layers/technical/Formatting/formatters.dart';
import 'demo_data.dart';

Account _account(String id, AccountType type, String name, List<double> monthly, String today) {
  final end = IsoDate.parse(today);
  final last = monthly.length - 1;
  final history = [
    for (var i = 0; i < last; i++) BalancePoint(isoDate(DateTime(end.y, end.m - (last - i)).year, DateTime(end.y, end.m - (last - i)).month, 1), monthly[i]),
    BalancePoint(today, monthly[last]),
  ];
  return Account(id: id, type: type, name: name, balance: monthly[last], updated: today, history: history);
}

Future<void> seedDemoIfEmpty(SharedPreferences prefs) async {
  final spending = SharedPrefsSpendingGateway(prefs);
  if (await spending.load() != null) return;
  final today = todayIso();
  await spending.save(SpendingSnapshot(
    entries: sampleTransactions(today: today),
    budgets: const {SpendCategory.alim: 320, SpendCategory.resto: 180, SpendCategory.transport: 100, SpendCategory.shop: 120, SpendCategory.loisirs: 60},
    lastImport: 'demo.csv',
  ));
  await SharedPrefsAccountsGateway(prefs).save([
    _account('d1', AccountType.courant, 'Compte courant', [1240, 980, 1415, 1190], today),
    _account('d2', AccountType.livreta, 'Livret A', [4800, 5000, 5200, 5400], today),
    _account('d3', AccountType.pel, 'PEL', [6100, 6100, 6100, 6100], today),
    _account('d4', AccountType.pea, 'PEA', [3200, 3550, 3490, 3920], today),
  ]);
}
