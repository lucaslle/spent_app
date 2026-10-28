import 'package:spent_app/layers/functional/Spending/domain/categorizer.dart';
import 'package:spent_app/layers/functional/Spending/domain/entities/transaction_entry.dart';
import 'package:spent_app/layers/technical/Formatting/formatters.dart';

class _Lcg {
  _Lcg(this._seed);
  int _seed;

  double next() {
    _seed = (_seed * 16807) % 2147483647;
    return _seed / 2147483647;
  }

  T pick<T>(List<T> a) => a[(next() * a.length).floor()];
}

(int, int) _shiftMonth(int y, int m, int by) {
  final index = y * 12 + (m - 1) + by;
  return (index ~/ 12, index % 12 + 1);
}

List<TransactionEntry> sampleTransactions({String today = '2026-10-27'}) {
  final end = IsoDate.parse(today);
  final r = _Lcg(11);
  final out = <TransactionEntry>[];
  var id = 0;
  void add(String date, String label, double amount) {
    final a = (amount * 100).round() / 100;
    out.add(TransactionEntry(id: 's${id++}', date: date, raw: label, amount: a, category: categorize(label, a)));
  }

  const fixed = <(int, String, double)>[
    (2, 'PRLV SEPA NAVIGO ANNUEL', -86.4), (3, 'PRLV SEPA FONCIA LOYER', -720), (5, 'PRLV SEPA FREE MOBILE', -19.99),
    (8, 'CB NETFLIX.COM', -13.49), (10, 'PRLV SEPA EDF CLIENTS', -64.2), (12, 'CB SPOTIFY P', -10.99),
    (15, 'PRLV SEPA BASIC FIT', -29.99), (25, 'VIR SEPA SALAIRE ACME SAS', 2150),
  ];

  for (final (y, m) in [for (final by in [-2, -1, 0]) _shiftMonth(end.y, end.m, by)]) {
    final last = y == end.y && m == end.m ? end.d : daysInMonth(y, m);
    for (final (d, l, a) in fixed) {
      if (d <= last) add(isoDate(y, m, d), l, a);
    }
    for (var d = 1; d <= last; d++) {
      final date = isoDate(y, m, d);
      final dd = ' ${pad2(d)}/${pad2(m)}';
      final dow = IsoDate.parse(date).weekday;
      final we = dow == 0 || dow == 6;
      if (r.next() < 0.55) add(date, 'CB ${r.pick(['BOULANGERIE PAUL', 'BOULANGERIE LA FOURNEE', 'STARBUCKS', 'COLUMBUS CAFE'])}$dd', -(2.5 + r.next() * 6));
      if (r.next() < (we ? 0.5 : 0.28)) add(date, 'CB ${r.pick(['MONOPRIX', 'CARREFOUR CITY', 'LIDL', 'FRANPRIX', 'PICARD'])}$dd', -(9 + r.next() * 58));
      if (r.next() < (dow >= 4 || dow == 0 ? 0.4 : 0.16)) add(date, 'CB ${r.pick(['UBER EATS', 'DELIVEROO', 'LE PETIT BISTROT', 'SUSHI SHOP', 'BIG MAMMA'])}$dd', -(14 + r.next() * 32));
      if (r.next() < 0.12) add(date, 'CB ${r.pick(['UBER TRIP', 'BOLT', 'TOTALENERGIES', 'SNCF INTERNET'])}$dd', -(8 + r.next() * 40));
      if (r.next() < 0.1) add(date, 'CB ${r.pick(['AMAZON EU', 'ZARA', 'FNAC', 'DECATHLON', 'UNIQLO', 'VINTED'])}$dd', -(12 + r.next() * 70));
      if (r.next() < 0.06) add(date, 'CB ${r.pick(['UGC CINE CITE', 'STEAM GAMES', 'FNAC SPECTACLES', 'BAR LE PERCHOIR'])}$dd', -(9 + r.next() * 30));
      if (r.next() < 0.04) add(date, 'CB ${r.pick(['PHARMACIE CENTRALE', 'DOCTOLIB MEDECIN'])}$dd', -(6 + r.next() * 25));
      if (r.next() < 0.05) add(date, 'VIR LYDIA ${r.pick(['THOMAS', 'CAMILLE', 'LEA'])}', (r.next() < 0.5 ? -1 : 1) * (10 + r.next() * 30));
    }
  }
  void addDated(int monthsBack, int day, String label, double amount) {
    final (y, m) = _shiftMonth(end.y, end.m, -monthsBack);
    add(isoDate(y, m, day), '$label ${pad2(day)}/${pad2(m)}', amount);
  }

  addDated(2, 18, 'CB HELLOASSO', -25);
  addDated(1, 12, 'CB SQ *ATELIER VAUGIRARD', -42);
  addDated(0, 4, 'PAIEMENT CB SUMUP *KIOSQUE', -8.5);
  addDated(0, 21, 'CB SQ *ATELIER VAUGIRARD', -38);
  for (final (label, amount) in const [('CB BOULANGERIE PAUL', -3.2), ('CB MONOPRIX', -23.45), ('CB UBER TRIP', -12.8)]) {
    add(today, '$label ${pad2(end.d)}/${pad2(end.m)}', amount);
  }
  out.sort(compareByDateDesc);
  return out;
}

String sampleCsv() {
  final lines = sampleTransactions().map((t) {
    final p = IsoDate.parse(t.date);
    return '${pad2(p.d)}/${pad2(p.m)}/${p.y};${t.raw};${t.amount.toString().replaceFirst('.', ',')}';
  });
  return 'Date;Libellé;Montant\n${lines.join('\n')}';
}
