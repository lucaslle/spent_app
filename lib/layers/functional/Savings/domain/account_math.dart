import 'entities/account.dart';
import 'entities/account_type.dart';

double accountTotal(List<Account> accounts) => accounts.fold(0, (s, a) => s + a.balance);

double groupTotal(List<Account> accounts, AccountGroup g) => accounts.where((a) => a.type.group == g).fold(0, (s, a) => s + a.balance);

class SeriesPoint {
  const SeriesPoint(this.date, this.value);

  final String date;
  final double value;
}

List<SeriesPoint> totalSeries(List<Account> accounts) {
  final dates = {for (final a in accounts) for (final h in a.effectiveHistory) h.date}.toList()..sort();
  double at(Account a, String d) => a.effectiveHistory.fold(0, (b, h) => h.date.compareTo(d) <= 0 ? h.balance : b);
  return [for (final d in dates) SeriesPoint(d, accounts.fold(0.0, (s, a) => s + at(a, d)))];
}

Account upsertAccount(List<Account> accounts, {String? id, required AccountType type, required String name, required double balance, required String today}) {
  final cleanName = name.trim().isEmpty ? type.label : name.trim();
  if (id == null) {
    return Account(id: 'a${DateTime.now().millisecondsSinceEpoch}', type: type, name: cleanName, balance: balance, updated: today, history: [BalancePoint(today, balance)]);
  }
  final old = accounts.firstWhere((a) => a.id == id);
  final h = [...old.effectiveHistory];
  if (h.isNotEmpty && h.last.date == today) {
    h[h.length - 1] = BalancePoint(today, balance);
  } else if (h.isEmpty || h.last.balance != balance) {
    h.add(BalancePoint(today, balance));
  }
  return Account(id: id, type: type, name: cleanName, balance: balance, updated: today, history: h);
}

