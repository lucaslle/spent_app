import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/spend_category.dart';
import '../domain/entities/transaction_entry.dart';
import '../domain/gateways/spending_gateway.dart';

class SharedPrefsSpendingGateway implements SpendingGateway {
  SharedPrefsSpendingGateway(this._prefs);

  static const _key = 'spending_v1';
  final SharedPreferences _prefs;

  @override
  Future<SpendingSnapshot?> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return SpendingSnapshot(
        entries: [for (final e in j['tx'] as List) _fromJson(e as Map<String, dynamic>)],
        budgets: {for (final e in (j['budgets'] as Map<String, dynamic>).entries) SpendCategory.byName(e.key): (e.value as num).toDouble()},
        lastImport: j['lastImport'] as String,
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(SpendingSnapshot s) {
    return _prefs.setString(
      _key,
      jsonEncode({
        'tx': [for (final t in s.entries) _toJson(t)],
        'budgets': {for (final e in s.budgets.entries) e.key.name: e.value},
        'lastImport': s.lastImport,
      }),
    );
  }

  Map<String, dynamic> _toJson(TransactionEntry t) => {'id': t.id, 'date': t.date, 'raw': t.raw, 'amount': t.amount, 'cat': t.category.name, 'excl': t.excluded, 'manual': t.manual};

  TransactionEntry _fromJson(Map<String, dynamic> j) => TransactionEntry(
        id: j['id'] as String,
        date: j['date'] as String,
        raw: j['raw'] as String,
        amount: (j['amount'] as num).toDouble(),
        category: SpendCategory.byName(j['cat'] as String),
        excluded: j['excl'] as bool? ?? false,
        manual: j['manual'] as bool? ?? false,
      );
}
