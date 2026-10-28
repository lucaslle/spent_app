import '../../../technical/Formatting/formatters.dart';
import 'categorizer.dart';
import 'entities/spend_category.dart';
import 'entities/transaction_entry.dart';

class CategoryStat {
  const CategoryStat({required this.category, required this.amount, required this.count, required this.budget});

  final SpendCategory category;
  final double amount;
  final int count;
  final double budget;

  double get ratio => budget > 0 ? amount / budget : (amount > 0 ? 2 : 0);
  bool get over => amount > budget;
}

class MerchantStat {
  const MerchantStat({required this.name, required this.amount, required this.count, required this.category});

  final String name;
  final double amount;
  final int count;
  final SpendCategory category;
}

class MonthStat {
  const MonthStat({required this.key, required this.month, required this.income, required this.out});

  final String key;
  final int month;
  final double income;
  final double out;
}

class SpendingStats {
  const SpendingStats({
    required this.ref, required this.year, required this.month, required this.day, required this.weekday, required this.daysInMonth,
    required this.prevMonth, required this.isToday, required this.yesterday, required this.spent, required this.income, required this.incomeEntry,
    required this.daily, required this.dailyVariable, required this.prevDaily, required this.prevTotal, required this.vsPrev,
    required this.budgetTotal, required this.averageVariable, required this.projection, required this.daysLeft, required this.remaining,
    required this.perDay, required this.todayEntries, required this.todaySpent, required this.vsAverage, required this.categories,
    required this.merchants, required this.weekdayAverages, required this.months,
  });

  final String ref;
  final int year;
  final int month;
  final int day;
  final int weekday;
  final int daysInMonth;
  final int prevMonth;
  final bool isToday;
  final String yesterday;
  final double spent;
  final double income;
  final TransactionEntry? incomeEntry;
  final List<double> daily;
  final List<double> dailyVariable;
  final List<double> prevDaily;
  final double prevTotal;
  final double vsPrev;
  final double budgetTotal;
  final double averageVariable;
  final double projection;
  final int daysLeft;
  final double remaining;
  final double perDay;
  final List<TransactionEntry> todayEntries;
  final double todaySpent;
  final double vsAverage;
  final List<CategoryStat> categories;
  final List<MerchantStat> merchants;
  final List<double> weekdayAverages;
  final List<MonthStat> months;

  double get pace => day / daysInMonth;
}

double _sum(Iterable<double> a) => a.fold(0, (x, y) => x + y);
double _sumAbs(Iterable<TransactionEntry> a) => a.fold(0, (x, t) => x - t.amount);

String _defaultReference(List<TransactionEntry> tx, String today) {
  final latest = tx.map((t) => t.date).reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
  final inCurrentMonth = latest.substring(0, 7).compareTo(today.substring(0, 7)) >= 0;
  return inCurrentMonth && today.compareTo(latest) > 0 ? today : latest;
}

/// Mois (AAAA-MM) consultables, du plus ancien au plus récent.
List<String> availableMonths(List<TransactionEntry> tx, String today) {
  if (tx.isEmpty) return const [];
  final months = {for (final t in tx) t.date.substring(0, 7), _defaultReference(tx, today).substring(0, 7)}.toList()..sort();
  return months;
}

SpendingStats? computeSpendingStats(List<TransactionEntry> tx, Map<SpendCategory, double> budgets, String today, {String? month}) {
  if (tx.isEmpty) return null;
  var ref = _defaultReference(tx, today);
  if (month != null && month != ref.substring(0, 7)) {
    final y = int.parse(month.substring(0, 4));
    final m = int.parse(month.substring(5));
    ref = isoDate(y, m, daysInMonth(y, m));
  }
  final r = IsoDate.parse(ref);
  final days = daysInMonth(r.y, r.m);
  final ym = ref.substring(0, 7);
  final py = r.m == 1 ? r.y - 1 : r.y;
  final pm = r.m == 1 ? 12 : r.m - 1;
  final pym = '$py-${pad2(pm)}';
  final prevDays = daysInMonth(py, pm);
  final yesterday = r.d > 1 ? isoDate(r.y, r.m, r.d - 1) : isoDate(py, pm, prevDays);

  final mTx = tx.where((t) => t.date.startsWith(ym)).toList();
  final pTx = tx.where((t) => t.date.startsWith(pym)).toList();
  final spent = _sumAbs(mTx.where((t) => t.isSpend));
  final incomes = mTx.where((t) => t.isIncome).toList()..sort((a, b) => b.amount.compareTo(a.amount));

  final daily = List<double>.filled(days, 0);
  final dailyVar = List<double>.filled(days, 0);
  final prevDaily = List<double>.filled(prevDays, 0);
  for (final t in mTx.where((t) => t.isSpend)) {
    final i = int.parse(t.date.substring(8)) - 1;
    daily[i] -= t.amount;
    if (!t.category.isFixed) dailyVar[i] -= t.amount;
  }
  for (final t in pTx.where((t) => t.isSpend)) {
    prevDaily[int.parse(t.date.substring(8)) - 1] -= t.amount;
  }

  final prevToDate = _sum(prevDaily.take(r.d < prevDays ? r.d : prevDays));
  final vsPrev = prevToDate > 0 ? (spent - prevToDate) / prevToDate : 0.0;

  final budgetTotal = _sum(SpendCategory.spending.map((k) => budgets[k] ?? 0));
  final varM = _sum(dailyVar.take(r.d));
  final avgVar = varM / r.d;
  final projection = spent - varM + avgVar * days;
  final daysLeft = days - r.d;
  final remaining = budgetTotal - spent;

  final todayEntries = tx.where((t) => t.date == ref).toList();
  final todayVar = _sumAbs(todayEntries.where((t) => t.isVariableSpend));

  final cats = [
    for (final c in SpendCategory.spending)
      () {
        final list = mTx.where((t) => t.isSpend && t.category == c).toList();
        return CategoryStat(category: c, amount: _sumAbs(list), count: list.length, budget: budgets[c] ?? 0);
      }(),
  ]..sort((a, b) => b.amount.compareTo(a.amount));

  final groups = <String, MerchantStat>{};
  for (final t in mTx.where((t) => t.isSpend)) {
    final name = merchantName(t.raw);
    final g = groups[name];
    groups[name] = MerchantStat(name: name, amount: (g?.amount ?? 0) - t.amount, count: (g?.count ?? 0) + 1, category: g?.category ?? t.category);
  }
  final merchants = (groups.values.toList()..sort((a, b) => b.amount.compareTo(a.amount))).take(5).toList();

  final minD = tx.map((t) => t.date).reduce((a, b) => a.compareTo(b) <= 0 ? a : b);
  final dowCount = List<int>.filled(7, 0);
  final dowSum = List<double>.filled(7, 0);
  final end = DateTime.utc(r.y, r.m, r.d);
  final m0 = IsoDate.parse(minD);
  for (var t = DateTime.utc(m0.y, m0.m, m0.d); !t.isAfter(end); t = t.add(const Duration(days: 1))) {
    dowCount[t.weekday % 7]++;
  }
  for (final t in tx.where((t) => t.isVariableSpend && t.date.compareTo(ref) <= 0)) {
    dowSum[IsoDate.parse(t.date).weekday] -= t.amount;
  }
  final weekdayAverages = [1, 2, 3, 4, 5, 6, 0].map((i) => dowCount[i] > 0 ? dowSum[i] / dowCount[i] : 0.0).toList();

  final keys = (tx.map((t) => t.date.substring(0, 7)).toSet().toList()..sort());
  final months = keys.map((key) {
    final list = tx.where((t) => t.date.startsWith(key) && !t.excluded).toList();
    return MonthStat(key: key, month: int.parse(key.substring(5)), income: _sum(list.where((t) => t.isIncome).map((t) => t.amount)), out: _sumAbs(list.where((t) => t.isSpend)));
  }).toList();

  return SpendingStats(
    ref: ref, year: r.y, month: r.m, day: r.d, weekday: r.weekday, daysInMonth: days, prevMonth: pm, isToday: ref == today, yesterday: yesterday,
    spent: spent, income: _sum(incomes.map((t) => t.amount)), incomeEntry: incomes.isEmpty ? null : incomes.first,
    daily: daily, dailyVariable: dailyVar, prevDaily: prevDaily, prevTotal: _sum(prevDaily), vsPrev: vsPrev,
    budgetTotal: budgetTotal, averageVariable: avgVar, projection: projection, daysLeft: daysLeft, remaining: remaining,
    perDay: daysLeft > 0 ? remaining / daysLeft : remaining, todayEntries: todayEntries, todaySpent: _sumAbs(todayEntries.where((t) => t.isSpend)),
    vsAverage: avgVar > 0 ? (todayVar - avgVar) / avgVar : 0, categories: cats, merchants: merchants, weekdayAverages: weekdayAverages, months: months,
  );
}
