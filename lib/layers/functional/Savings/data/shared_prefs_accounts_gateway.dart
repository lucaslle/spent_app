import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/account.dart';
import '../domain/entities/account_type.dart';
import '../domain/gateways/accounts_gateway.dart';

class SharedPrefsAccountsGateway implements AccountsGateway {
  SharedPrefsAccountsGateway(this._prefs);

  static const _key = 'accounts_v1';
  final SharedPreferences _prefs;

  @override
  Future<List<Account>?> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          Account(
            id: e['id'] as String,
            type: AccountType.byName(e['type'] as String),
            name: e['name'] as String,
            balance: (e['balance'] as num).toDouble(),
            updated: e['updated'] as String,
            history: [for (final h in e['history'] as List) BalancePoint(h['date'] as String, (h['balance'] as num).toDouble())],
          ),
      ];
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(List<Account> accounts) {
    return _prefs.setString(
      _key,
      jsonEncode([
        for (final a in accounts)
          {
            'id': a.id,
            'type': a.type.name,
            'name': a.name,
            'balance': a.balance,
            'updated': a.updated,
            'history': [for (final h in a.history) {'date': h.date, 'balance': h.balance}],
          },
      ]),
    );
  }
}
