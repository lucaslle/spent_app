import 'entities/account.dart';
import 'entities/account_type.dart';

const _dates = ['2026-05-01', '2026-06-01', '2026-07-01', '2026-08-01', '2026-09-01'];

List<BalancePoint> _history(List<double> vals, double last, String lastDate) =>
    [for (var i = 0; i < _dates.length; i++) BalancePoint(_dates[i], vals[i]), BalancePoint(lastDate, last)];

List<Account> defaultAccounts() => [
      Account(id: 'a1', type: AccountType.courant, name: 'Compte courant', balance: 1842.3, updated: '2026-10-27', history: _history([1520, 1980, 1410, 2105, 1690], 1842.3, '2026-10-27')),
      Account(id: 'a2', type: AccountType.livreta, name: 'Livret A', balance: 6450, updated: '2026-10-01', history: _history([5400, 5600, 5800, 6000, 6200], 6450, '2026-10-01')),
      Account(id: 'a3', type: AccountType.ldds, name: 'LDDS', balance: 2100, updated: '2026-10-01', history: _history([2000, 2000, 2050, 2050, 2100], 2100, '2026-10-01')),
      Account(id: 'a4', type: AccountType.pea, name: 'PEA', balance: 4380.55, updated: '2026-10-20', history: _history([3500, 3640, 3580, 3890, 4020], 4380.55, '2026-10-20')),
    ];
